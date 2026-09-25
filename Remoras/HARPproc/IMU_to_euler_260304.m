function IMU_to_euler_260304(iffns)
% IMU_2_euler_YYMMDD.m
%
%   iffns = string or cell array containing fully resolved filenames of raw
%           IMU files ( path + filename + ext ) 
%
% Processes raw IMU data files
%  - Applies calibration coefficients ( AGM ) 
%  - Calculate Euler angles ( YPR ) 
%  - Save processed & raw data to mat files ( 2x mat files per 1x raw IMU ) 
%  - Decimation needs to be fixed since BJT changes...dimension mismatch...AGM
%       dims not changing?
%
% Tweaked version of IMU_eval_241028
%   - IMU files do not include zero padding now
%   - file i/o has been updated, much faster now
%
% cleaned up version, saves mat files at the end of D, AGM, YPR matrix -
% 10/28/2024 BJT
%
% things to add / change: 
%       - general code cleanup, remove redundant or unused variables, stuff like
%       that
%       - smarter reads on large imu files...do reads in predefined chunk sizes
%       & append mat file as we go.  Currently approach is a memory hog for 100
%       kHz x 4CH ( raw imu file is 700-800MB )
%       - double check that we're not throwing away an IMU record at the end (
%       off by one problem ) 
%
% 260220 BJT - removing decimation blocks & variable naming ( still need to
%               complete this )
%            - converted to a function
%

% average samples before applying calibration or converting Euler Angles

decF = 1; % decimate factor for IMU data - average to lower number of samples / computational time
            % decF = 5, 10 or 20

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if iscell(iffns)
    % sort by filenames
    [~,ind]=sort(iffns);
    iffns = iffns(ind);
else
    iffns{1} = iffns; % if only one imu file is selected
end

%% make a diary file 

[ p1, fn1, ~ ] = fileparts(iffns{1});
% try to do something smart and look for HARP disk naming convention in path
% REGION_SITE_ITERATION_*_disk[0-9][0-9]
re = '(?<=\\)[^\\]*_disk\d+';
pnt = regexp(p1, re, 'match');
if isempty(pnt)
    fprintf('\tBad match on path, using first filename for logfile\n');
    lfn = sprintf('%s_Imu2Euler_%s.log', fn1, datestr(now,'yymmdd_HHMMSS'));
else
    lfn = sprintf('%s_Imu2Euler_%s.log', pnt{end}, datestr(now,'yymmdd_HHMMSS'));
end
lffn = fullfile(p1, lfn);

% check if diary running already...turn off, make sure we use the file we want
if strcmp(get(0,'Diary'),'on')
    diary off
end

diary(lffn)

dt_fmt = 'mm/dd/yyyy HH:MM:SS.FFF';

[ret, hname] = system('hostname');
[v, d] = version;
IMUprocInfo = struct;
IMUprocInfo.mfilename = mfilename;
IMUprocInfo.datetime = now;
IMUprocInfo.computer = hname;
IMUprocInfo.matlab = v;

% print some stuff for the log
fprintf('\t%s\n',datestr(IMUprocInfo.datetime, dt_fmt));
fprintf('\tComputer = %s\n', IMUprocInfo.computer ); 
fprintf('\tMatlab Version = %s\n', IMUprocInfo.matlab );
fprintf('\tM-file = %s\n', IMUprocInfo.mfilename );
fprintf('\tLogging to file %s\n', lffn);

E = exist('decF'); %#ok<*EXIST>
if E ~= 1
    decF = 1;
end
if decF == 5
    fprintf('Decimation factor set to 5 \n') 
elseif decF == 10
    fprintf('Decimation factor set to 10 \n') 
elseif decF == 20
    fprintf('Decimation factor set to 20 \n') 
elseif decF ~= 1
    decF = 1;
    fprintf('Decimation factor not set to 5, 10 or 20, defaulting to no decimation \n')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IMU calibration constants 
Acal = 2 / 2^15;
Gcal = 2000 / 2^15;
Mcal = [1150, 1150, 2250] ./2^15;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fprintf('Processing %d imu file(s):\n', length(iffns))

% provide some user updates for sanity
% do some sort of (approximate) percentage 
perc_bin = 5; % how many percent between updates?
perc_cnt = round(perc_bin*.01*length(iffns));

% read and process data for each imu file
for k = 1:length(iffns)
    
    [ p, f, e ] = fileparts(iffns{k});
     
    % metadata in mat file 
    IMUprocInfo.inputDir = p;
    IMUprocInfo.inFile = sprintf('%s%s',f,e);

    fn =iffns{k};
    finfo = dir(fn);

    nblk = finfo.bytes/32; % number of IMU sample blocks, where each block is 32 bytes long

%     fprintf('\t%s ( %d IMU records )\n', IMUprocInfo.inFile, nblk);

    fid = fopen(fn,'r','l');
    ID = fread(fid, [ 2, nblk ], '2*uint8',30);  
    fseek(fid,2,'bof');
    fs = fread(fid, [ 1, nblk ], '1*uint16',30);
    fseek(fid,4,'bof');
    T = fread(fid, [ 6, nblk ], '6*uint8',26);
    fseek(fid,10,'bof');
    ms = fread(fid, [ 1, nblk ], '1*uint16',30);
    fseek(fid, 12,'bof');
    ctr = fread(fid, [ 1, nblk ], '1*uint16',30);
    fseek(fid, 14,'bof');
    mag = fread(fid, [ 3, nblk ], '3*int16',26);
    fseek(fid, 20, 'bof');
    gyr = fread(fid, [ 3, nblk ], '3*int16', 26);
    fseek(fid, 26, 'bof');
    acc = fread(fid, [ 3, nblk ], '3*int16', 26);
    fclose(fid);

    D = [ ID', fs', T', ms', ctr', mag', gyr', acc' ];
    
    nrec = size(D,1);
    if nrec ~= nblk
        fprintf('IMU record count doesn''t match file size!\n');
        return;
    end

    %%%%% process data %%%%%
    
    % time
    tvec = [D(:,4:8), D(:,9) + 0.001 .* D(:,10)];
    tdnum = datenum(tvec);
    stime =  {sprintf('%u',tvec(1,1:3)),sprintf('%u',tvec(1,4:5)),sprintf('%.f',tvec(1,6))};

    mx_non = D(:,12);


    % decimate if applicable
    val = 0;
    % pre-allocate...tweaking indexing and for loop to make these matrices might
    % be more maintainable in the future

    % does it make sense to not bother looping for df == 1 ?  @ df = 1 mean()
    % accounts for about 50% of processing time

%    tdnum_decF = zeros(round(nrec/decF)-1,1);
%     ax = zeros(nrec-1,1); % should this be -1...are we throwing away our last imu record?
%     ay = ax;
%     az = ax;
%     gx = ax;
%     gy = ax;
%     gz = ax;
%     mx = ax;
%     my = ax;
%     mz = ax;
%     for ii = 1:decF:(nrec-decF)
%         tdnum_decF(val+1,1) = mean(tdnum(ii:ii+decF-1));
%         mx(val+1,1)= mean(D(ii:ii+decF-1,12));
%         my(val+1,1)= mean(D(ii:ii+decF-1,13));
%         mz(val+1,1)= mean(D(ii:ii+decF-1,14));
%         gx(val+1,1)= mean(D(ii:ii+decF-1,15));
%         gy(val+1,1)= mean(D(ii:ii+decF-1,16));
%         gz(val+1,1)= mean(D(ii:ii+decF-1,17));
%         ax(val+1,1)= mean(D(ii:ii+decF-1,18));
%         ay(val+1,1)= mean(D(ii:ii+decF-1,19));
%         az(val+1,1)= mean(D(ii:ii+decF-1,20));
%         val = val+1;
%     end
   
    if 0 
        % this doubles up on big arrays for large imu files
        % should do a check to decide if we should chunk through files instead
        % and append the mat file as we go...for now we'll just try and call directly
        % from D
        mx = D(:,12);
        my = D(:,13);
        mz = D(:,14);
        gx = D(:,15);
        gy = D(:,16);
        gz = D(:,17);
        ax = D(:,18);
        ay = D(:,19);
        az = D(:,20);
    
        % apply calibration factor to samples
        A = [ax , ay, az] .* Acal;
        G = [gx , gy, gz] .* Gcal;
        M = [mx , my, mz] .* Mcal;
    
    else
        % hopefully this helps
        A = [ D(:,18:20) ] .* Acal;
        G = [ D(:,15:17) ] .* Gcal;
        M = [ D(:,12:14) ] .* Mcal;
       
    end

%     X = [A, G, M];
    
    tdnum_decF = tdnum; 
    rotationSequence = 'ZYX';
    rotationType = 'frame';
    qe = ecompass(A, M); % make quarternion: 4-D hyper-complex space vector
    Ang = eulerd(qe,rotationSequence,rotationType); % convert to Euler Angles in degrees

    df_str = ['df',sprintf('%.0f',decF)];
  
    
    %%%% save stuff
    IMUprocInfo.rotationSequence = rotationSequence;
    IMUprocInfo.rotationType = rotationType;
    IMUprocInfo.decF = decF;

    % one mat file to rule them all

    % Accelerometer, Gyroscope, Magnetometer data with time
    % This is raw data with calibration coefficients applied
    tAGM = [ tdnum_decF,A,G,M ];

    % roll pitch yaw with time (decimated) 
    tYPR = [ tdnum_decF,Ang ];

    ofn = fullfile(p, sprintf('%s_procIMU_df%d.mat',f, decF) );
    save(ofn, 'IMUprocInfo','D','tAGM','tYPR','-v7.3');

% 
%     % save D matrix with all the datas 
%     ofn_D = fullfile(inpath, sprintf('%s_Dmatrix.mat',ofn_pfx)); 
%     save(ofn_D,'D');
%     
%     % save A, G, M with time (decimated) 
%     tAGM = [ tdnum_decF,A,G,M ];
% 
%     ofn_tAGM = fullfile( inpath, sprintf('%s_tAGM_df%d.mat',ofn_pfx, decF) );
%     save(ofn_tAGM,'tAGM');
%     
%     % save roll pitch yaw with time (decimated) 
%     tYPR = [ tdnum_decF,Ang ]; % make new matrix with time and rpy
%     ofn_tYPR = fullfile( inpath, sprintf('%s_tYPR_df%d.mat', ofn_pfx, decF) );
%     save(ofn_tYPR,'tYPR');

    % update user we're making progress
    if rem(k, perc_cnt) == 0
        fprintf('\t%d %%  (%d/%d)\n', perc_bin*(k/perc_cnt),k, length(iffns));
    end

end
fprintf('\tDone!\n')
% stop log
diary off

end
