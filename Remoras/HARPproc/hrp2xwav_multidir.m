% hrp2xwav_multidir
%
% called from hrppd in HARPproc Remora in Triton
%
% script to get user input and process HRP files into
% XWAV including decimation) files.
%
% LTSA stuff does not work, so need to take it out...
% LTSAs are made with mk_ltsa_multidir
%

global PARAMS REMORA gui_cancel
% there has to be a better way to prevent residual REMORA structures from
% hanging around after a run and impacting future runs without Triton
% restare
REMORA.hrp.files = [];

% load in parameters to use in processing
hrp2xwav_paramA;

if gui_cancel; disp_msg(sprintf('Processing cancelled.\n')); return; end;

% profile on;

% numbers that will be the same
headblk = 12;
PARAMS.fromProc = true;


% make shorter names for all of the global variables
% file info
files = REMORA.hrp.files; % used to be PARAMS.proc.hrpFiles
path = REMORA.hrp.path; % used to be PARAMS.proc.path
disks = REMORA.hrp.disks;
dataID = REMORA.hrp.dataID;
% headerfile = REMORA.hrp.headerfile;

% location to save different processing-related files
proc_save = REMORA.hrp.proc_save;

% bools
rmfifo = REMORA.hrp.rmfifo;
fixTimes = REMORA.hrp.fixTimes;
resumeDisk = REMORA.hrp.resumeDisk;
diary_bool = REMORA.hrp.diary_bool;
use_mod = REMORA.hrp.use_mod;

% rf start/end
rf_ends = REMORA.hrp.rf_end;
rf_starts = REMORA.hrp.rf_start;
rf_skips = REMORA.hrp.rf_skip;

% vectors
[REMORA.hrp.dfs, order] = sort(REMORA.hrp.dfs);
temp = cell(1, length(REMORA.hrp.dfs));
for k = 1:length(order)
    temp(order(k)) = REMORA.hrp.saveloc(k);
end
REMORA.hrp.saveloc = temp;
dfs = REMORA.hrp.dfs;
% ltsas = REMORA.hrp.ltsas;
clear temp;

% names of resume disk files
rd_mat = fullfile(proc_save,'resumeDisk.mat');
% rd_struct = fullfile(path,'resumeStruct.mat');
rd_mat_back = fullfile(proc_save,'resumeDisk_back.mat');
% rd_struct_back = fullfile(path,'resumeStruct_BAK.mat');

% % enable diary?
% if diary_bool
%     dfile = fullfile(proc_save, sprintf('%s_disk%s_log.txt', dataID, disk));
%     fclose(fopen(dfile, 'w'));
%     diary(dfile);
% end

% check to see whether necessary resume disk files are there
if resumeDisk
    if ~exist(rd_mat_back, 'file')
        disp('Can''t find resume disk mat file. Exiting.');
        return
        %     elseif ~exist(rd_struct_back, 'file');
        %         disp('Can''t find resume disk param file. Exiting.');
        %         return
    else
        fclose('all');
        load(rd_mat_back);
        %         PARAMS.ltsa = ltsa;
        %         rf_start = rf_start_ind;
        %         clear ltsa
    end
else
    disk_start = 1;
    rf_start_ind = rf_starts(disk_start); % which file we're starting processing from
end

tic % start stop watch

% read in metadata from .hrd/.prm file TODO this is stupid and there should
% be a better way of doing it
% read_xwavHDRfile(headerfile,0);

% for each disk being processed

%%%% Loop over disks 
for i = disk_start:size(files, 1)
    disk = disks(i, :);
    rf_start = rf_starts(i);
    rf_end = rf_ends(i);
    rf_skip = rf_skips{i};

    % enable diary?
    if diary_bool
        dfile = fullfile(proc_save, sprintf('%s_disk%s_log.txt', dataID, disk));
        fclose(fopen(dfile, 'a'));  % 'a' appends to file ('w' writes over)
        diary(dfile);
    end
    % text to start log file
    fprintf('\n*************************************************************************************\n')
    if diary_bool, fprintf('Diary log file: %s\n',dfile); end
    fprintf('Start : %s\n',datestr(now));
    fprintf('Disk %s\n', disk);
    fprintf('*************************************************************************************\n')

    % version / PC info to user included in every disk's logfile
    ver matlab % print out matlab version info
    if ispc
        netbName = getenv('computername');
        fprintf('Computer NetBIOS name: %s\n', netbName);
    end
    p = mfilename('fullpath');
    fprintf('%s\n', p); % print out runninb file/version

    % dump some info to user
    fprintf('Data ID = %s\n', dataID);
    % fprintf('\tParam File = %s\n', headerfile);
    fprintf('Decimation factors:\n');
    fprintf('\t%d\n', REMORA.hrp.dfs);

    fprintf('Source HARP File Directories:\n');
    for k = 1:size(path, 1)
        fprintf('\t%s\n', path(k, :));
    end

    fprintf('Source HRP File Name:\n');
    %     for k = 1:size(REMORA.hrp.files, 1)
    %         fprintf('\t%s\n', REMORA.hrp.files(k, :));
    %     end
    fprintf('\t%s\n', REMORA.hrp.files(i, :));


    fprintf('Destination XWAV Directories:\n');
    for k = 1:size(REMORA.hrp.saveloc, 2)
        fprintf('\t%s\n', REMORA.hrp.saveloc{k});
    end
    fprintf('\n');

    %
    % load in directory list times and firmware information
    REMORA.hrp.curr = fullfile(path, files(i, :));
    filename = REMORA.hrp.curr;

    if isfield(PARAMS, 'head')
        PARAMS = rmfield(PARAMS, 'head');
    end

    read_rawHARPdir(filename, 0);
    PARAMS.fs = PARAMS.head.samplerate;
    s = ckFirmware;
    if ~s; fclose all; return; end; % do we have the necessary firmware version?

    prefix = sprintf('%s_', dataID);

    % error tracking
    PARAMS.error.csl = 0;
    errMat = fullfile(proc_save, sprintf('%sdisk%s_procErrors.mat', prefix, disk));
    errMat_back = fullfile(proc_save, sprintf('%sdisk%s_procErrors_back.mat', prefix, disk));

    % change channel information if necessary
    if PARAMS.nch == 1
        REMORA.hrp.ch = 1;
    end

    % make necessary directories
    xwavPaths = mk_directories(disk, dataID, dfs);

    % if modified dirlist times already exist in the directory and we want
    % to fix them, load those in
    modName = sprintf('%s_modifiedDirListTimes.mat', files(i, 1:end-4));
    if exist(fullfile(path, modName), 'file') == 2 && use_mod
        load_modhdrs(fullfile(path, modName));
    elseif fixTimes
        fix_dirlistTimes;
    end

    % get the number of raw files per xwav
    [ndir, REMORA.hrp.xwavNums, rfCounts] = get_rfNums(filename, dfs, ...
        rf_end, rf_start, rf_skip);
    REMORA.hrp.rfCounts = rfCounts;

    % set rf_end to last rf if it's 0
    if rf_end == 0 || rf_end > ndir
        rf_end = ndir;
    end

    % set up parameter to keep track of rawfile number of samples
    PARAMS.dc.Tsamplen = zeros(ndir,1);

    % empty array initialization
    fod = zeros(1, length(dfs)); % fods (one for each df)
    if ~resumeDisk
        currXWAV = zeros(1, length(dfs)); % current XWAV being generated/
        xwav_bytelocs = zeros(1, length(dfs)); % end byte location of most recently
        %         ltsa_bytelocs = zeros(length(dfs),length(REMORA.hrp.ch)); % written rf for xwav/ltsa
        xwav_names = cell(1, length(dfs));
    end

    % open raw files
    if str2double(PARAMS.head.firmwareVersion(1)) == 3    % SD HARP:4ch + std??
        ftype = 2;  % SD HARPs
        fid = fopen(fullfile(path, files(i, :)),'r','b');
    else
        ftype = 1;  % SATA/IDE raw disks
        fid = fopen(fullfile(path, files(i, :)));
    end

    % keep track of actual number of rfs processed
    rf_start_ind = rf_starts(i);
    rfidx = zeros(length(dfs),1);   % rawfile index for each xwav file

    % loop over each raw file
    %     for j = rf_start_ind:rf_end  % j = index from start to end
    if rf_start == 0
        J = rf_skip;
        skflag = 0;
        disp('List of RFs to process:')
        disp(num2str(J))
    else
        J = rf_start:rf_end;
        skflag = 1;
        disp(['rf_start = ',num2str(rf_start)])
        disp(['rf_end   = ',num2str(rf_end)])
        disp(['rf_skip  = ',num2str(rf_skip)])
    end

    % IMU stuff 
    % check for IMU subdirectory, when starting disk
    % open file to make concatenated IMU file ( one per disk @ df1 )
    
    % Should this be integrated into ckFirmware + FW table instead?
    if strcmp(PARAMS.head.firmwareVersion(1:4),'3B03') || strcmp(PARAMS.head.firmwareVersion, '3A05250108') % Should this be integrated into ckFirmware + FW table instead?
            % only do this for df1 
            dfi = find(REMORA.hrp.dfs == 1 ); 
            if ~isempty(dfi)
                imu_pn = fullfile(xwavPaths{dfi},'IMU');
                if ~exist(imu_pn,'dir')
                    mkdir(imu_pn);
                end
                imu_fn2 = fullfile(imu_pn ,sprintf('%sdisk%s.imu', prefix, disk));
                fodi2 = fopen(imu_fn2, 'w+');  % file identifier for concatenated imu file ( 1x per disk )
                mk_IMU = 1;
                imuRecSz = 32; % imu record size [bytes]

                if PARAMS.fs==100e3
                    idlen = 4; % bytes per sector of IMU data ( when present )
                elseif PARAMS.fs==200e3
                    idlen = 8; % bytes per sector of IMU data ( when present )
                end

            end
    else
        mk_IMU = 0;
    end

    %%%% Loop over raw files

    %     for j = rf_start:rf_end  % j = index from start to end
    for j = J % j = index from start to end

        if PARAMS.dflag
            disp(['Raw File : ',num2str(j)])
        end

        % if we're skipping this rf
        if skflag && ismember(j, rf_skip)
            disp_msg(sprintf('Skipping rf # %d', j));
            fprintf('Skipping rf # %d\n', j);
            continue;  % this increments j, but not
        end

        % raw file operations, skip to start of raw file
        status = fseek(fid,PARAMS.head.dirlist(j,1)*512,'bof');
        if status ~= 0
            disp(['Error - failed fseek to byte ',num2str(PARAMS.head.dirlist(j,1)*512)])
            fclose('all');
            return
        end

        % raw file reading operations
        if ~PARAMS.cflag % non compression, 4 ch
            % create empty data vector
            data = zeros(PARAMS.nsampPerRawFile, 1);
            if mk_IMU
                idata = zeros(PARAMS.head.dirlist(j, 10) * 8, 1); % preallocate more space than needed
                icnt = 0;
            end
            ns = PARAMS.nsampPerSect; % shorthand for below use
            % loop over sectors in raw file
            imu_block = 0; % flag/counter for sectors w/ imu data
            for m = 1:PARAMS.head.dirlist(j, 10)
                if PARAMS.nch == 4
                    if mk_IMU
                        fseek(fid,8,0);	                            % skip over timing header
                        imua = fread(fid,4,'int8');
                        data((m-1)*ns+1:m*ns) = fread(fid,ns,'uint16') - 32767;
                        imub = fread(fid,4,'int8');

                        % for 200 kHz data, "IM" is bytes 9-10, and IMU data is found in four
                        % sequential sectors in bytes 9-12, and 509-512
                    
                        % for 100 kHz data, "IM" is bytes 509-510, and IMU data is found in
                        % eight sequential sectors in bytes 509-512
                    
                        % we should always know sample rate when processing data right?

                        % would it be better/more consistent to have flags
                        % set in ck_firmware instead? 
% 
%                         if PARAMS.fs==100e3
%                             imu = imub;
%                             ichunk = 4; % bytes per sector of IMU data ( when present ) 
%                         elseif PARAMS.fs==200e3
%                             imu = [ imua;imub ]; 
%                             ichunk = 8; % bytes per sector of IMU data ( when present )
%                         end

                        if idlen == 4
                            imu = imub; % 4x100kHz
                        elseif idlen == 8
                            imu = [ imua;imub ]; % 4x200kHz
                        end

                        if (imu(1)==73 && imu(2)==77) || ( imu_block > 0 )% 'IM' -> imu block 1 
                                                                          % uint8('I') && uint8('M')
                            icnt = icnt + 1;
%                             idlen = length(imu); % would it speed things up to set this once outside of the loop, should be 4 for 100kHz and 8 for 200kHz
                            idata(idlen * (icnt-1) +1: idlen * icnt) = imu;
                            
                            % debugging stuff
%                             fprintf('\timu out idx0 = %d\tidxn = %d\n', idlen * (icnt-1) +1, idlen * icnt);
%                             if j == rf_end
%                                 1;
%                             end


                            imu_block = imu_block+idlen;
                            if imu_block == imuRecSz
                                imu_block = 0;  % we've read a full IMU record, start looking for 'IM' tag again       
                            end
                        end                
                    else
                        fseek(fid, headblk, 0); % skip over header, assume time is good
                        data((m-1)*ns+1:m*ns) = fread(fid,ns,'uint16') - 32767;
                        fseek(fid,PARAMS.tailblk,0);   % skip over tail bytes (=0 for nchan=1, =4 for nchan=4)
                    end
                else
                    fseek(fid, headblk, 0); % skip over header, assume time is good
                    data((m-1)*ns+1:m*ns) = fread(fid,ns,'int16');
                    fseek(fid,PARAMS.tailblk,0);   % skip over tail bytes (=0 for nchan=1, =4 for nchan=4)
                end

            end

            

        else        % compression
            %             data = decompressRawHRP(fid,j,PARAMS.ctype);
            data = decompressRawHRP(fid,j,PARAMS.ctype,'ftype',ftype);
            % save Section timestamps if BWA or sync loss
            if PARAMS.csectFlag == 1
                disp('BWA or Sync Loss: Section TimeStamps saved')

                dSectTS = fullfile(REMORA.hrp.proc_save, 'SectTS');
                if exist(dSectTS,'dir') ~= 7
                    mkdir(dSectTS);
                end

                TSfile = fullfile(dSectTS, sprintf('%s_disk%s_RF%d.mat', dataID, disk, j));
                save(TSfile,'-struct','PARAMS','csectInfo');
            end
        end

        % remove FIFO noise
        if rmfifo
            data = rmFIFO(data);
        end

        % loop over each decimation factor
        for k = 1:length(dfs)
            % count errors
            PARAMS.error.csl = 0;

            rfidx(k) = rfidx(k) + 1;

            % make new xwav file
            if mod(rfidx(k), rfCounts(k)) == 1   % first rf in xwav

                % inc. XWAV # currently making
                currXWAV(k) = currXWAV(k) + 1;

                xwav_names{k} = mk_xwav_name(prefix, dfs(k), j);

                % open new xwav
                fod(k) = fopen(fullfile(xwavPaths{k}, xwav_names{k}), 'w+');
                
                % open new IMU file if applicable and df = 1 
                if mk_IMU && dfs(k) == 1
                    imu_pfx = strsplit(xwav_names{k},'.x.wav');
                    imu_pfx = imu_pfx{1};
                    imu_fn = fullfile(imu_pn, sprintf('%s.imu',imu_pfx)); 
                    fodi = fopen(imu_fn,'w');
                end

                % change nrf for the last file if needed
                if currXWAV(k) == REMORA.hrp.xwavNums(k) && skflag
                    rfCounts(k) = rf_end - j + 1 ...
                        - length(find(rf_skip>j & rf_skip<=rf_end));
                    rfidx(k) = 1;
                end

                if PARAMS.dflag
                    fprintf('\nXWAV Filename: %s \nXWAV file %d out of %d for df %d \n', ...
                        xwav_names{k}, currXWAV(k),...
                        REMORA.hrp.xwavNums(k), dfs(k));
                end

                % write XWAV header info
                write_XWAVhead(fod(k),j,rfCounts(k),k);

            end

            % continuous
            if dfs(k) ~= 1
                wr_data = decimate(data, dfs(k));
            else
                wr_data = data;
            end

            % total number of samples read in decompressRawHRP for rf j
            nsamp = length(wr_data);

            % adjust byte we're writing to if resuming processing
            if resumeDisk
                % open file that we need to update
                fod(k) = fopen(fullfile(xwavPaths{k},xwav_names{k}), 'r+');
                fseek(fod(k), xwav_bytelocs(k), 'bof');
    
            end

            % finally, write to xwav
            fwrite(fod(k),wr_data,'int16');
            
            % write imu data if applicable
            if mk_IMU && dfs(k) == 1  %  Should put Average IMU data into XWAV header at some point
                idata2 = idata(1:icnt*idlen); % don't write out unused preallocated space in array
                fwrite(fodi,idata2,'int8'); % write to smaller imu file ( one per xwav @ df1 )
                fwrite(fodi2,idata2,'int8'); % write to concatenated imu file ( one per disk @ df1 )
            end

            %             if PARAMS.cflag % only change header for compression (i.e., possible sync loss)
            % update xwav rawfile header
            modXWAVhead_rfhd(fod(k),rfidx(k),rfCounts(k),j,nsamp);
            %             end


            % if making ltsas
            %             if ltsas(k)
            % removed ltsa stuff to simplify ...
            % finished writing this rf to xwav; record ending byte loc
            xwav_bytelocs(k) = ftell(fod(k));

            if mod(rfidx(k), rfCounts(k)) == 0   % last rawfile in xwav
                %                 if PARAMS.cflag % only change header for compression (i.e., possible sync loss)
                modXWAVhead_size(fod(k),rfCounts(k));
                %                 end
                fclose(fod(k));

                % close imu file if applicable and df = 1
                if mk_IMU && dfs(k) == 1 
                    fclose(fodi);
                end

            end
            % need to close file after last rawfile read
            if j == rf_end
                %                 if PARAMS.cflag % only change header for compression (i.e., possible sync loss)
                %                     modXWAVhead_size(fod(k),REMORA.hrp.rfCounts(k));
                %                 end
                %                 fclose(fod(k));
            elseif j > rf_end
                disp('That is weird, counter is greater than number of rawfiles')
            end
        end

        % after each raw file is completely done being processed, save
        % byte locations, curr rf #, and curr xwav #
        % backup file from previous iteration
        if exist(rd_mat, 'file')
            copyfile(rd_mat, rd_mat_back);
        end
        %         ltsa = PARAMS.ltsa;
        rf_start_ind = j+1;  % not sure why this is here ... I guess to start on the next one when resumed
        disk_start = i;
        save(rd_mat, 'rf_start_ind', 'disk_start', 'xwav_bytelocs',...
            'currXWAV', 'xwav_names');
        %         clear ltsa;

        % reset resumeDisk so we just continue writing for the next raw file
        if resumeDisk
            resumeDisk = false;
        end
    end

    fclose(fid);

    % close concatenated imu file ( 1x per disk )   
    if mk_IMU
        fclose(fodi2);
    end

end
fclose('all');

% disable diary if we were using it
if diary_bool
    diary off;
end

% reset fromProc variable so other triton functions can be used normally
PARAMS = rmfield(PARAMS, 'fromProc');

toc
% profile off;
% profsave(profile('info'), fullfile(proc_save, 'decimate_normal'));


function hrp2xwav_paramA
% hrp2xwav_paramA
%
% get input from user for hrp2xwav_multi processing.
% in Triton Remora HARPproc
%
% load previously saved processing parameter file for speedy processing retry
% or get info on processing parameters to use for this run:
% select HRP files for processing
% get and set XWAV static header metadata like lat/lon/z
% proess all rawfiles? if no, get/set which ones
% save processing parameters for another run later
%
global REMORA PARAMS gui_cancel

gui_cancel = 0;

figPos = [0.05 0.75 0.2 0.05];

% use preloaded parameters file
% use_param = questdlg('Load processing parameter file?', 'Load HRP Processing Parameters', ...
%     'Yes', 'Yes; resume processing', 'No', 'Yes');
use_param = questdlg('Load processing parameter file?', 'Load HRP Processing Parameters', ...
    'Yes', 'No', 'Yes');
if ~isempty(findstr(use_param, 'Yes'))
    [file, path] = uigetfile('.mat', 'Select a processing parameter file.');
    if isequal(file, 0) || isequal(path, 0)
        gui_cancel = 1;
        return;
    else
        load(fullfile(path, file));
    end

    if strcmp(use_param, 'Yes; resume processing')
        REMORA.hrp.resumeDisk = 1;
    end
elseif strcmp(use_param, 'No')
    % collect processing parameters
    hrp2xwav_paramB
    if gui_cancel == 1
        return
    end
else
    gui_cancel = 1;
    return
end

%% get and set processing parameters since a processing parameter files was not loaded
% if ~isfield(PARAMS, 'xhd')
if isempty(REMORA.hrp.files)
    % load hrp files
    [files, path] = uigetfile('*.hrp', 'MultiSelect', 'on', 'Select HRP Files for processing');
    files = char(files);

    % pull out data ID from files
    pattern = '^[\w-_]+(?=_disk)';
    dataID = regexp(files(1, :), pattern, 'match');
    dataID = char(dataID(1, :));

    % pull out disk numbers from files
    disks = [];
    for k = 1:size(files, 1)
        pattern = 'disk(\d{2})';
        num = regexp(files(k, :), pattern, 'tokens');
        disks = [disks; char(num{1})];
    end

    %% XWAV header parameters
    % instrument/deployment info
    good_entries = 0;
    % default settings
    dinfo{1} = 'Y';     % load header file
    dinfo{2} = 'EXPER001'; % experiment name - 8 chars
    dinfo{3} = 'ST01';           % site name - 4 chars
    dinfo{4} = 'HRP5';       % harp instrument number - 4 chars
    dinfo{5} = '-11722859';	% DDD.ddddd decimal degrees or DDD MM.mmm ?
    dinfo{6} = '3253550';		% DD.ddddd decimal degrees or DD MM.mmm ?
    dinfo{7} = '999';			% meters down is positive
    while ~good_entries
        prompt = {'Load XWAV Header File (Y/N):';...
            'Experiment name (8 chars):';...
            'Site name (4 chars):';'Instrument ID (4 chars):';...
            'Longitude in degrees minutes:';...
            'Latitude in degrees minutes:';...
            'Depth in meters:'};
        title = 'Deployment Info';
        info = inputdlg(prompt, title, 1, dinfo);

        % if figure closed
        if isempty(info); gui_cancel = 1; return; end;

        if strcmp(info{1},'Y')  % load XWAV header hdr file
            [file, hpath,FilterIndex] = uigetfile('.hdr', 'Select XWAV header parameter file',path);
            if FilterIndex > 0
                disp(['XWAV header parameters set by hdr file : ',fullfile(hpath,file)])
                [fid,~] = fopen(fullfile(hpath,file), 'r');
                % read each line of the hdrfile and evaluate it
                while ~feof(fid)            % not EOF
                    tline=fgets(fid);
                    eval(tline)
                end
                fclose(fid);    % close hdr file

                % fill info structure for evaluating format
                info{2} = PARAMS.xhd.ExperimentName;
                info{3} = PARAMS.xhd.SiteName;
                info{4} = PARAMS.xhd.InstrumentID;
                info{5} = num2str(PARAMS.xhd.Longitude);
                info{6} = num2str(PARAMS.xhd.Latitude);
                info{7} = num2str(PARAMS.xhd.Depth);
            end

        elseif strcmp(info{1},'N')
            disp('XWAV header parameters set by user input')
        end

        % check format
        if length(info{2}) == 8 && length(info{3}) == 4 && ...
                length(info{4}) == 4 && str2num(info{5}) && ...
                str2num(info{6}) && str2num(info{7})
            good_entries = 1;
        else
            f = warndlg('Make sure formats on XWAV header parameter entries are correct');
            uiwait(f);
        end
    end   % end while ~good_entries

    % set XWAV header parameters
    PARAMS.xhd.ExperimentName = info{2};
    PARAMS.xhd.SiteName = info{3};
    PARAMS.xhd.InstrumentID = info{4};
    PARAMS.xhd.Longitude = str2num(info{5});
    PARAMS.xhd.Latitude = str2num(info{6});
    PARAMS.xhd.Depth = str2num(info{7});


    %% first check if we just want to process whole disk for each .hrp
    REMORA.hrp.disks = disks;
    REMORA.hrp.rf_start = ones(1, size(disks, 1));
    REMORA.hrp.rf_end = zeros(1, size(disks, 1));
    REMORA.hrp.rf_skip = cell(1, size(disks, 1));

    answer = questdlg('Process all rfs in each disk?', '', 'Yes', 'No', 'No');
    if strcmp(answer, 'No')

        % new gui for selecting start/end/rfs to skip for each
        mycolor = [.8 .8 .8];
        c = 4;
        r = 3 + size(disks, 1);

        h = 0.02*r; % panel width and height
        w = 0.04*c;

        bh = 1/r; % button/element width/height
        bw = 1/c;

        % make x and y locations in plot control window (relative units)
        y = zeros(1, r);
        for ri = 1:r
            if ri == 1
                y(ri) = 0;
            else
                y(ri) = 1/r + y(ri-1);
            end
        end

        x = zeros(1, r);
        for ci = 1:c
            if ci == 1
                x(ci) = 0;
            else
                x(ci) = 1/c + x(ci-1);
            end
        end

        %         btnPos = [0,0,w,h];
        figPos = [figPos(1) figPos(2) w h];
        REMORA.hrpfig.main = figure('Name', 'RF nums', 'Units', 'Normalized',...
            'MenuBar', 'none', 'NumberTitle', 'off', 'Position', figPos,...
            'CloseRequestFcn', 'hrp2xwav_paramC(''close_cancel'')');
        %         movegui(gcf,'center');

        % label info
        labelStr = 'Choose start/end rfs and rfs to skip';
        btnPos = [x(1), y(end), 1, bh];
        uicontrol(REMORA.hrpfig.main, 'Units', 'normalized','BackgroundColor',mycolor,...
            'Position',btnPos,'Style','text','String',labelStr,'HorizontalAlign',...
            'left');

        % labels for each field
        labelStr = 'Start RF';
        btnPos = [x(2), y(end-1), bw, bh];
        uicontrol(REMORA.hrpfig.main,'Units','normalized','BackgroundColor',...
            mycolor,'Position',btnPos,'Style','text','String',labelStr,...
            'HorizontalAlign','left');


        labelStr = 'End RF';
        btnPos = [x(3), y(end-1), bw, bh];
        uicontrol(REMORA.hrpfig.main,'Units','normalized','BackgroundColor',...
            mycolor,'Position',btnPos,'Style','text','String',labelStr,...
            'HorizontalAlign','left');

        labelStr = 'RFs to skip';
        btnPos = [x(4), y(end-1), bw, bh];
        uicontrol(REMORA.hrpfig.main,'Units','normalized','BackgroundColor',...
            mycolor,'Position',btnPos,'Style','text','String',labelStr,...
            'HorizontalAlign','left');

        % empty figure handles
        REMORA.hrpfig.rf_start = cell(1, size(disks, 1));
        REMORA.hrpfig.rf_end = cell(1, size(disks, 1));
        REMORA.hrpfig.rf_skip = cell(1, size(disks, 1));

        % populate iteratively for each disk
        for k = 1:size(disks, 1)

            % disk name
            labelStr = sprintf('Disk %s:', disks(k,:));
            btnPos = [x(1), y(end-k-1), bw, bh];
            uicontrol(REMORA.hrpfig.main,'Units','normalized','BackgroundColor',...
                mycolor,'Position',btnPos,'Style','text','String',labelStr,...
                'HorizontalAlign','left');

            % rf start
            btnPos = [x(2), y(end-k-1), bw, bh];
            REMORA.hrpfig.rf_start{k} = uicontrol(REMORA.hrpfig.main,'Units',...
                'normalized','Position',btnPos,'Style','edit',...
                'HorizontalAlign','left');

            % rf end
            btnPos = [x(3), y(end-k-1), bw, bh];
            REMORA.hrpfig.rf_end{k} = uicontrol(REMORA.hrpfig.main,'Units',...
                'normalized','Position',btnPos,'Style','edit',...
                'HorizontalAlign','left');

            % rfs to skip
            btnPos = [x(4), y(end-k-1), bw, bh];
            REMORA.hrpfig.rf_skip{k} = uicontrol(REMORA.hrpfig.main,'Units','normalized','Position',btnPos,...
                'Style','edit','HorizontalAlign','left');

        end

        % continue button
        btnPos = [x(2)+0.5*bw,y(1),bw,bh];
        labelStr = 'Continue';
        uicontrol(REMORA.hrpfig.main,'String',labelStr,...
            'Style','push','Units','normalized','Position',btnPos,...
            'Callback','hrp2xwav_paramC(''ctn_rf'')');

        uiwait; if gui_cancel; return; end;

    elseif strcmp(answer, '')
        hrp2xwav_paramC('close_cancel');
    end

    % globalize file info
    REMORA.hrp.files = files; % used to be PARAMS.proc.hrpFiles
    REMORA.hrp.path = path; % used to be PARAMS.proc.path
    REMORA.hrp.dataID = dataID;
    REMORA.hrp.proc_save = fullfile(REMORA.hrp.path, 'ProcessingFiles');
    % make processing directory for log, errors, resume, etc
    if exist(REMORA.hrp.proc_save) ~= 7
        mkdir(REMORA.hrp.proc_save);
    end

    dialog_title = 'Choose directory for Processing Outputs';
    REMORA.hrp.proc_save = uigetdir(REMORA.hrp.proc_save,dialog_title);

    try
        % processing parameters
        name = fullfile(REMORA.hrp.proc_save, sprintf('%s_procparams_diskinfo', dataID));
        savefile = uiputfile('*.mat', 'Save processing parameter file',name);
        save(fullfile(REMORA.hrp.proc_save, savefile), 'REMORA', 'PARAMS');
    catch
        disp('Invalid file selected or cancel button pushed.')
        gui_cancel = 1;
        return;
    end

    % save your current parameters (disk + processing params)?
    %     save_param = questdlg('Save your current parameters?');
    %     if strcmp(save_param, 'Yes')
    %         try
    %             % make processing directory for log, errors, resume, etc
    %             if exist(REMORA.hrp.proc_save) ~= 7
    %                 mkdir(REMORA.hrp.proc_save);
    %             end
    %
    %             name = fullfile(REMORA.hrp.proc_save, sprintf('%s_procparams_diskinfo', dataID));
    %             savefile = uiputfile('*.mat', 'Save processing parameter file',name);
    %             save(fullfile(REMORA.hrp.proc_save, savefile), 'REMORA', 'PARAMS');
    %         catch
    %             disp('Invalid file selected or cancel button pushed.')
    %             gui_cancel = 1;
    %             return;
    %         end
    %     end
    % but need to do mkdir if not saving just the parameters:
    % make processing directory for log, errors, resume, etc
    %     if exist(REMORA.hrp.proc_save) ~= 7
    % %         mkdir(REMORA.hrp.guiC_save);
    %             disp('hmmm, need to make directory if not saving just parameters??')
    %     end
end


end

function hrp2xwav_paramB
%% hrp2xwav_paramB
%
% called by hrp2xwav_paramA in HARPproc Remora in Triton
%
% function to get/set user input for processing HRP files into
% XWAV(including decimation) files.
%
% get info on decimation factors
% get/set info on XWAV (including decimation) destination folders
%
% LTSA stuff does not work, so it was taken out.
% LTSAs are made with mk_ltsa_multidir
%
% radio button window for choosing processing 'extra' parameters:
% fix dir times, rm fifo, resume processing,
% display output to MATLAB command window
% make a diary logfile (text)
% save processing parameters
% start processing, GO!!!
%
global REMORA PARAMS gui_cancel

% figure/dialog box position, size, color
mycolor = [.8,.8,.8];
figPos = [0.05 0.75 0.2 0.15];



%% load dfs fig
prompt = inputdlg('Enter desired decimation factors (comma separated):',...
    'DF Selection', 1, {'1, 20, 100'});
prompt = strsplit(char(prompt), {',',', '});
REMORA.hrp.dfs = [];

% close/cancel button was pushed
if isempty(prompt{1})
    gui_cancel = 1;
    return
end

% format input dfsz
for k = 1:length(prompt)
    df = str2num(prompt{k});
    REMORA.hrp.dfs = [REMORA.hrp.dfs, df];
end

% shorthand dfs alias
dfs = REMORA.hrp.dfs;

%% dfs save locations fig
% color
% mycolor = [.8,.8,.8];
r = length(dfs) + 2;
c = 5;
h = 0.02*r; % panel width and height
w = 0.025*c;

bh = 1/r; % button/element width/height
bw = 1/c;

% make x and y locations in plot control window (relative units)
y = zeros(1, r);
for ri = 1:r
    if ri == 1
        y(ri) = 0;
    else
        y(ri) = 1/r + y(ri-1);
    end
end

x = zeros(1, r);
for ci = 1:c
    if ci == 1
        x(ci) = 0;
    else
        x(ci) = 1/c + x(ci-1);
    end
end


REMORA.hrpfig.main = figure('Name', 'XWAV Destination Folders', 'Units', ...
    'normalized', 'Position', figPos, 'MenuBar', 'none', 'NumberTitle', 'off',...
    'CloseRequestFcn', 'hrp2xwav_paramC(''close_cancel'')');

% movegui(gcf, 'center');


% Title
labelStr = 'Select DF Destination Folders:';
btnPos = [x(1),y(end), 5*bw, bh];
uicontrol(REMORA.hrpfig.main, 'Units', 'normalized','BackgroundColor', mycolor,...
    'Position', btnPos,'Style','text','String',labelStr);

% list of dfs
for k = 1:length(dfs)
    labelStr = sprintf('%d : ', dfs(k));
    btnPos = [x(1),y(end-k),bw,bh];
    uicontrol(REMORA.hrpfig.main, 'Units', 'normalized', 'BackgroundColor', mycolor,...
        'Position', btnPos,'Style', 'text', 'String', labelStr);

    labelStr = 'Browse';
    btnPos = [x(4), y(end-k),2*bw,bh];
    REMORA.hrpfig.browsebois{k} = uicontrol(REMORA.hrpfig.main, 'Units', 'normalized', 'Position', btnPos,...
        'String', labelStr, 'Style', 'pushbutton', 'Callback', sprintf('hrp2xwav_paramC(''get'', %d)', k));

    btnPos = [x(2),y(end-k),2*bw,bh];
    REMORA.hrpfig.disk_handles{k} = uicontrol(REMORA.hrpfig.main, 'Units', 'normalized', 'Position', btnPos,...
        'Style', 'edit', 'BackgroundColor', 'white', 'HorizontalAlignment',...
        'left');
end

% continue
labelStr = 'Continue';
btnPos = [x(2)+.5*x(2), y(1), bw*2, bh];
uicontrol(REMORA.hrpfig.main, 'Units', 'normalized', 'Position', btnPos, ...
    'String', labelStr, 'Callback', 'hrp2xwav_paramC(''ctn_disk'');');

uiwait;  % this requires function hrp2xwav_paramC to be outside function hrp2xwav_paramB

if gui_cancel; return; end

%% Build Window/dialog box to allow user to choose processing options
% with radio button i.e., Boolean options

c = 4;
r = 9;

h = 0.02*r; % panel width and height
w = 0.04*c;

bh = 1/r; % button/element width/height
bw = 1/c;

% make x and y locations in plot control window (relative units)
y = zeros(1, r);
for ri = 1:r
    if ri == 1
        y(ri) = 0;
    else
        y(ri) = 1/r + y(ri-1);
    end
end

x = zeros(1, r);
for ci = 1:c
    if ci == 1
        x(ci) = 0;
    else
        x(ci) = 1/c + x(ci-1);
    end
end

% btnPos = [0,0,w,h];
figPos = [figPos(1) 0.65 w h];
REMORA.hrpfig.main = figure('Name', 'Select Options', 'Units', 'Normalized',...
    'MenuBar', 'none', 'NumberTitle', 'off', 'Position', figPos,...
    'CloseRequestFcn', 'hrp2xwav_paramC(''close_cancel'')');
% movegui(gcf,'center');

% label info
btnPos = [x(1),y(end),1,bh];
labelStr = '   Other options';
uicontrol(REMORA.hrpfig.main,'Units','normalized','BackgroundColor',mycolor,...
    'Position',btnPos,'Style','text','String',labelStr,'HorizontalAlign',...
    'left');

% radio buttons

% fix directory times
btnPos = [x(1),y(end-1),1,bh];
labelStr = '   Fix directory list times';
REMORA.hrpfig.fix_rad = uicontrol(REMORA.hrpfig.main,'Units','normalized',...
    'Position',btnPos,'String',labelStr,'Style','radio',...
    'BackgroundColor',mycolor,'Callback','hrp2xwav_paramC(''enb'')');

btnPos = [.5*x(2),y(end-2),3/c,bh];
labelStr = 'Use modified dirlist time files';
REMORA.hrpfig.fix_files_rad = uicontrol(REMORA.hrpfig.main,'Units','normalized',...
    'Position',btnPos,'String',labelStr,'Style','radio',...
    'BackgroundColor',mycolor,'Enable','off');

% rmfifo
btnPos = [x(1),y(end-3),1,bh];
labelStr = '   Remove FIFO noise';
REMORA.hrpfig.rmfifo_rad = uicontrol(REMORA.hrpfig.main,'Units','normalized',...
    'Position',btnPos,'String',labelStr,'Style','radio',...
    'BackgroundColor',mycolor);

% resume guiCessing
btnPos = [x(1),y(end-4),1,bh];
labelStr = '   Resume guiCessing';
REMORA.hrpfig.resume_rad = uicontrol(REMORA.hrpfig.main,'Units','normalized',...
    'Position',btnPos,'String',labelStr,'Style','radio',...
    'BackgroundColor',mycolor);

% display output to command window
btnPos = [x(1),y(end-5),1,bh];
labelStr = '   Display output to command window';
REMORA.hrpfig.disp_rad = uicontrol(REMORA.hrpfig.main,'Units','normalized',...
    'Position',btnPos,'String',labelStr,'Style','radio','Value',1,...
    'BackgroundColor',mycolor);

% create diary log of output
btnPos = [x(1), y(end-6),1,bh];
labelStr = '   Create diary log of output';
REMORA.hrpfig.diary_rad = uicontrol(REMORA.hrpfig.main,'Units','normalized',...
    'Position',btnPos,'String',labelStr,'Style','radio','Value',1,...
    'BackgroundColor',mycolor);

% save parameters
btnPos = [x(1)+.25*x(2),y(1),1.5*bw,1.5*bh];
labelStr = 'Save params';
uicontrol(REMORA.hrpfig.main,'Units','normalized','Position',btnPos,...
    'String',labelStr,'Style','push','Enable','off','Callback','hrp2xwav_paramC(''save'')');

% continue button
btnPos = [x(4)-.75*x(2),y(1),1.5*bw,1.5*bh];
labelStr = 'Continue';
uicontrol(REMORA.hrpfig.main,'Units','normalized','Position',btnPos,...
    'String',labelStr,'Style','push','Callback','hrp2xwav_paramC(''go'')');

uiwait; if gui_cancel; return; end;



end  % end function hrp2xwav_paramB

