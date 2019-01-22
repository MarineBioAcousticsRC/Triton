% renameXWAVinLTSA.m
%
% rename XWAV files in LTSA header, preserving the date/time info
% XWAV filenames format has to be:
% "Prefix_YYMMDD_HHMMSS.x.wav"
%
% only works for XWAV, but could be easily modified for wav files
%
% 151215 smw
% 
% some user notes:
%
% When the code is run, it counts and displays the XWAV filenames changed 
% in the LTSA, then a black powershell (like dos cmd) window pops up.  
% Wait until a command prompt appears in the black window before all the 
% files have been renamed (xwavs and ltsas) - this takes a couple of minutes.
%
% 1) it is best to have the same prefix for the old LTSA and old XWAV filenames 
% before running the MATLAB renaming script so that the both get changed. 
% If the LTSA name is a bit different, it won't get changed during the script 
% run and you have to do it manually (or with the powershell Rename or similar).
%
% 2) also, best to change name of folders and disk volume before changing XWAV 
% and LTSA names - just to keep it all straight and consistent.
%
% 3) after the xwav filenames in the LTSA are changed (via MATLAB code), 
% and the powershell is started, you can run the rename MATLAB code before 
% the powershell is done. Each powershell is its own execution, so you can 
% run another at the same time (as long as it is not in the same folder - 
% which would likely muck up your process). This makes the process a bit more efficient.
%
% Added ver4 functionality, changed matching to regexp to support decimated
% data 
% 160517 bjt 
%
% clear all
close all

% User select LTSA file
% user interface retrieve file to open through a dialog box
boxTitle1 = 'Open LTSA File';
filterSpec1 = '*.ltsa';
[PARAMS.ltsa.infile,PARAMS.ltsa.inpath]=uigetfile(filterSpec1,boxTitle1);
oldfn = fullfile(PARAMS.ltsa.inpath,PARAMS.ltsa.infile);
% if the cancel button is pushed, then no file is loaded so exit this script
if strcmp(num2str(PARAMS.ltsa.infile),'0')
    disp('cancel button selected')
    return
else % give user some feedback
    disp('Opened File: ')
    disp([PARAMS.ltsa.inpath,PARAMS.ltsa.infile])
    cd(PARAMS.ltsa.inpath)
end

%
% make backup of original LTSA file
newfn = [oldfn,'.bkup'];
cnt = 1;
flag = 1;
while flag
    if exist(newfn) == 2
        newfn = [oldfn,'.bkup',num2str(cnt)];
        cnt = cnt + 1;
    else
        copyfile(oldfn,newfn)
        flag = 0;
    end
end

%
% open LTSA
fid = fopen(oldfn,'r+');  % open file for reading and writing

% LTSA Header - 64 bytes
type = fread(fid,4,'char');                    % 4 bytes - file ID type
PARAMS.ltsa.ver = fread(fid,1,'uint8');                    % 1 byte - version number
spare = fread(fid,3,'char');                   % 3 bytes - spare
PARAMS.ltsa.dirStartLoc = fread(fid,1,'uint32');           % 4 bytes - directory start location [bytes]
PARAMS.ltsa.dataStartLoc = fread(fid,1,'uint32');          % 4 bytes - data start location [bytes]
PARAMS.ltsa.tave = fread(fid,1,'float32');     % 4 bytes - time bin average for spectra [seconds]
PARAMS.ltsa.dfreq = fread(fid,1,'float32');    % 4 bytes - frequency bin size [Hz]
PARAMS.ltsa.fs = fread(fid,1,'uint32');        % 4 bytes - sample rate [Hz]
PARAMS.ltsa.nfft = fread(fid,1,'uint32');      % 4 bytes - number of samples per fft

if PARAMS.ltsa.ver == 1 || PARAMS.ltsa.ver == 2
    PARAMS.ltsa.nrftot = fread(fid,1,'uint16');    % 2 bytes - total number of raw files from all xwavs
    sk = 27;
elseif PARAMS.ltsa.ver == 3 || PARAMS.ltsa.ver == 4
    PARAMS.ltsa.nrftot = fread(fid,1,'uint32');    % 4 bytes - total number of raw files from all xwavs
    sk = 25;
else
    disp(['Error: incorrect version number ',num2str(PARAMS.ltsa.ver)])
    return
end
PARAMS.ltsa.nxwav = fread(fid,1,'uint16');     % 2 bytes - total number of xwavs files used
PARAMS.ltsa.ch = fread(fid,1,'uint8');         % 1 byte - channel number ltsa'ed
fseek(fid,sk,0);                  % 1 bytes x 27 = 27 bytes - 0 padding / spare
% 64 bytes used - up to here

% directory
% define/initialize some vectors first instead of dynamically - this should
% be faster
PARAMS.ltsahd.year = zeros(1,PARAMS.ltsa.nrftot);
PARAMS.ltsahd.month = zeros(1,PARAMS.ltsa.nrftot);
PARAMS.ltsahd.day = zeros(1,PARAMS.ltsa.nrftot);
PARAMS.ltsahd.hour = zeros(1,PARAMS.ltsa.nrftot);
PARAMS.ltsahd.minute = zeros(1,PARAMS.ltsa.nrftot);
PARAMS.ltsahd.secs = zeros(1,PARAMS.ltsa.nrftot);
PARAMS.ltsahd.ticks = zeros(1,PARAMS.ltsa.nrftot);
PARAMS.ltsa.byteloc = zeros(1,PARAMS.ltsa.nrftot);
PARAMS.ltsa.nave = zeros(1,PARAMS.ltsa.nrftot);

if PARAMS.ltsa.ver < 4
    PARAMS.ltsahd.fname = zeros(PARAMS.ltsa.nrftot,40);
else
    PARAMS.ltsahd.fname = zeros(PARAMS.ltsa.nrftot,80);
end


PARAMS.ltsahd.rfileid = zeros(1,PARAMS.ltsa.nrftot);
PARAMS.ltsa.dnumStart = zeros(1,PARAMS.ltsa.nrftot);
PARAMS.ltsa.dvecStart = zeros(PARAMS.ltsa.nrftot,6);
PARAMS.ltsa.dnumEnd = zeros(1,PARAMS.ltsa.nrftot);
PARAMS.ltsa.dvecEnd = zeros(PARAMS.ltsa.nrftot,6);

disp(['Number of RawFiles : ',num2str(PARAMS.ltsa.nrftot)])
disp(['Number of XWAV Files : ',num2str(PARAMS.ltsa.nxwav)])

for k = 1 : PARAMS.ltsa.nrftot
    % write time values to directory
    PARAMS.ltsahd.year(k) = fread(fid,1,'uchar');          % 1 byte - Year
    PARAMS.ltsahd.month(k) = fread(fid,1,'uchar');         % 1 byte - Month
    PARAMS.ltsahd.day(k) = fread(fid,1,'uchar');           % 1 byte - Day
    PARAMS.ltsahd.hour(k) = fread(fid,1,'uchar');          % 1 byte - Hour
    PARAMS.ltsahd.minute(k) = fread(fid,1,'uchar');        % 1 byte - Minute
    PARAMS.ltsahd.secs(k) = fread(fid,1,'uchar');          % 1 byte - Seconds
    PARAMS.ltsahd.ticks(k) = fread(fid,1,'uint16');        % 2 byte - Milliseconds
    % 8 bytes up to here
    %
    PARAMS.ltsa.byteloc(k) = fread(fid,1,'uint32');     % 4 byte - Byte location in ltsa file of the spectral averages for this rawfile
    if PARAMS.ltsa.ver == 3 || PARAMS.ltsa.ver == 4    % ARP data type = ltsa version 3
        PARAMS.ltsa.nave(k) = fread(fid,1,'uint32');          % 2 byte - number of spectral averages for this raw file
        sk = 7;                                         % nz=7 only for ver=3
    elseif PARAMS.ltsa.ver == 1 || PARAMS.ltsa.ver == 2
        PARAMS.ltsa.nave(k) = fread(fid,1,'uint16');          % 2 byte - number of spectral averages for this raw file
        sk = 9;
    else
        disp_msg(['Error: incorrect version number ',num2str(PARAMS.ltsa.ver)])
        return
    end
    % 14 or 16 bytes up to here
    if PARAMS.ltsa.ver < 4
        fnsz = 40;
    else
        fnsz = 80;
        sk = 4;
    end
    fpos0 = ftell(fid);
    PARAMS.ltsahd.fname(k,:) = fread(fid,fnsz,'uchar');        % 40/80 byte - xwav file name for this raw file header
    PARAMS.ltsahd.rfileid(k) = fread(fid,1,'uint8');       % 1 byte - raw file id / number for this xwav
%     fseek(fid,sk,0);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % modify filenames in LTSA and XWAV directory
    xfn = char(PARAMS.ltsahd.fname(k,:));
    xfn2 = deblank(xfn);
%     xfn3 = xfn2(1:end-20);      % this is the key and only works for XWAV files
    pat = '_[0-9]{6}_[0-9]{6}.'; % match timing portion of xwav fname
    [ toks, sidx, eidx ] = regexp(xfn2,pat,'split');
    if isempty(sidx) || isempty(eidx)
        fprintf('Couldn''t match %s for %s\n',pat, xfn2); 
        fprintf('Bad LTSA metadata?'); 
        return;
    end
    pfx0 = toks{1}; % old prefix should be toks{1}
    ext = toks{end}; % extension should be toks{end} or more strictly toks{2}
    xfn3 = pfx0; 
    % ie "_YYMMDD_HHMMSS.x.wav" is 20 chars
    % wav would be 18 chars, so would be easy
    % to modify
    if k ==1
        disp(['old filename prefix ',xfn3])
        % get user input for new filename prefix
        prompt={'Enter New filename prefix : '};
        def={num2str(xfn3)};
        dlgTitle='Set new filename prefix';
        lineNo=1;
        AddOpts.Resize='on';
        AddOpts.WindowStyle='normal';
        AddOpts.Interpreter='tex';
        % display input dialog box window
        in=inputdlg(prompt,dlgTitle,lineNo,def,AddOpts);
        if length(in) == 0	% if cancel button pushed
            disp('cancel button selected')
            return
        else
            yfn3 = deal(in{1});
            disp(['New filename prefix: ',yfn3])
        end
        
    end
    
    % write new filename prefix
    nfn = sprintf('%s%s%s', yfn3,xfn2(sidx:eidx),ext);
    pad_str = [ '%-', num2str(fnsz),'s' ];
    nfnp = sprintf(pad_str,nfn);
    if size(nfnp,2) > fnsz
        fprintf('New filename size %d too long for version %d LTSA\n', size(nfnp,2),PARAMS.ltsa.ver); 
        fprintf('Develop smarter code or remake LTSA %d?\n', PARAMS.ltsa.ver+1)
        fclose(fid);
        return;
    end
    PARAMS.ltsahd.fname(k,1:fnsz) = nfnp;
    
    fseek(fid,fpos0,'bof');   % go back to write over old values
    fwrite(fid,PARAMS.ltsahd.fname(k,:),'uchar');        % 40 or 80 byte - xwav file name for this raw file header
    
    if rem(k,30) == 0
        disp(['XWAV file number : ',num2str(k/30)])
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PARAMS.ltsahd.rfileid(k) = fread(fid,1,'uint8');       % 1 byte - raw file id / number for this xwav
    fseek(fid,sk,0);
    % 64 bytes for each directory listing for each raw file
    
    % calculate starting time [dnum => datenum in days] for each ltsa raw
    % file ie write/buffer flush
    PARAMS.ltsa.dnumStart(k) = datenum([PARAMS.ltsahd.year(k) PARAMS.ltsahd.month(k)...
        PARAMS.ltsahd.day(k) PARAMS.ltsahd.hour(k) PARAMS.ltsahd.minute(k) ...
        PARAMS.ltsahd.secs(k)+(PARAMS.ltsahd.ticks(k)/1000)]);
    PARAMS.ltsa.dvecStart(k,:) = [PARAMS.ltsahd.year(k) PARAMS.ltsahd.month(k)...
        PARAMS.ltsahd.day(k) PARAMS.ltsahd.hour(k) PARAMS.ltsahd.minute(k) ...
        PARAMS.ltsahd.secs(k)+(PARAMS.ltsahd.ticks(k)/1000)];
    
    PARAMS.ltsa.dur(k) = PARAMS.ltsa.tave * PARAMS.ltsa.nave(k);
    
    % end of ltsa for each raw file:
    PARAMS.ltsa.dnumEnd(k) = PARAMS.ltsa.dnumStart(k) ...
        + datenum([0 0 0 0 0 (PARAMS.ltsa.dur(k) - 1/PARAMS.ltsa.fs)]);
    PARAMS.ltsa.dvecEnd(k,:) = PARAMS.ltsa.dvecStart(k,:) ...
        + [0 0 0 0 0 (PARAMS.ltsa.dur(k) - 1/PARAMS.ltsa.fs)];
    
end

fclose(fid);

%
% rename all xwav (and LTSA) files in directory
% !powershell Dir "|" Rename-Item -NewName {$_.name -replace \"AKCB02_01_4\",\"AKCB_07_02_4\"} &
psstr = ['!powershell Dir "|" Rename-Item -NewName ',...
    '{$_.name -replace \"',xfn3,'\",\"',yfn3,'\"} &'];
eval(psstr)

