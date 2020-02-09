function sm_read_ltsahead
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% sm_read_ltsahead.m
%
% read LTSA header and directories portion of the file
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS HANDLES

%this standalone function probably won't work if triton has been opened in
%this current matlab session. Also, won't work if it's run twice in a row.
if 0
    if isstruct(PARAMS)
        % open input ltsa file
        fid = fopen([PARAMS.ltsa.inpath,PARAMS.ltsa.infile],'r');
        blockHANDLES= 0;
    else
        [PARAMS.ltsa.infile, PARAMS.ltsa.inpath] = uigetfile('*.ltsa','Open LTSA File');
        if strcmp(num2str(PARAMS.ltsa.infile),'0')
            PARAMS.ltsa.inpath = 'C';
            PARAMS.ltsa.infile = 'C:';
            return
        else % give user some feedback
            disp('Opened File: ')
            disp([PARAMS.ltsa.inpath,PARAMS.ltsa.infile])
            cd(PARAMS.ltsa.inpath)
        end
        fid = fopen([PARAMS.ltsa.inpath,PARAMS.ltsa.infile],'r');
        blockHANDLES = 1;
    end
end

if ~isstruct(HANDLES)
    blockHANDLES= 0;
else
    blockHANDLES = 1;
end

% open input ltsa file
%   fid = fopen([PARAMS.ltsa.inpath,PARAMS.ltsa.infile],'r');
if isstruct(PARAMS)
    fid = fopen(fullfile(PARAMS.ltsa.inpath,PARAMS.ltsa.infile),'r');
else
    [PARAMS.ltsa.infile, PARAMS.ltsa.inpath] = uigetfile('*.ltsa','Open LTSA File');
    if strcmp(num2str(PARAMS.ltsa.infile),'0')
        PARAMS.ltsa.inpath = 'C';
        PARAMS.ltsa.infile = 'C:';
        return
    else % give user some feedback
        disp('Opened File: ')
        disp([PARAMS.ltsa.inpath,PARAMS.ltsa.infile])
        cd(PARAMS.ltsa.inpath)
    end
    fid = fopen([PARAMS.ltsa.inpath,PARAMS.ltsa.infile],'r');
end


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
    disp_msg(['Error: incorrect version number ',num2str(PARAMS.ltsa.ver)])
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
    PARAMS.ltsa.byteloc(k) = fread(fid,1,'uint64');     % 8 byte - Byte location in ltsa file of the spectral averages for this rawfile
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
    % 18 or 20 bytes up to here
    if PARAMS.ltsa.ver < 4
        PARAMS.ltsahd.fname(k,:) = fread(fid,40,'uchar');        % 40 byte - xwav file name for this raw file header
        PARAMS.ltsahd.rfileid(k) = fread(fid,1,'uint8');       % 1 byte - raw file id / number for this xwav
        fseek(fid,sk,0);
    else
        PARAMS.ltsahd.fname(k,:) = fread(fid,80,'uchar');        % 80 byte - xwav file name for this raw file header
        sk = 4;
        PARAMS.ltsahd.rfileid(k) = fread(fid,1,'uint32');       % 1 byte - raw file id / number for this xwav
        fseek(fid,sk,0);
    end
    % 64 + 40 bytes for each directory listing for each raw file
    
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

PARAMS.ltsa.durtot = sum(PARAMS.ltsa.dur);

% close file
fclose(fid);

% number of frequencies in each spectral average:
% PARAMS.ltsa.nf = floor(PARAMS.ltsa.nfft/2) + 1;
if mod(PARAMS.ltsa.nfft,2) % odd
    PARAMS.ltsa.nf = (PARAMS.ltsa.nfft + 1)/2;
else        % even
    PARAMS.ltsa.nf = PARAMS.ltsa.nfft/2 + 1;
end

% initialize the timing parameters
PARAMS.ltsa.start.dnum = PARAMS.ltsa.dnumStart(1);
PARAMS.ltsa.start.dvec = PARAMS.ltsa.dvecStart(1,:);
PARAMS.ltsa.end.dnum = PARAMS.ltsa.dnumEnd(PARAMS.ltsa.nrftot);

% max freq
% PARAMS.ltsa.fmax = floor(PARAMS.ltsa.fs/2);
PARAMS.ltsa.fmax = (PARAMS.ltsa.nf - 1) * PARAMS.ltsa.dfreq;
PARAMS.ltsa.freq = [0:PARAMS.ltsa.dfreq:PARAMS.ltsa.fmax];
PARAMS.ltsa.f = PARAMS.ltsa.freq;

% if ~blockHANDLES
if blockHANDLES
    % turn on mouse coordinate display
    set(HANDLES.fig.main,'WindowButtonMotionFcn','control(''coorddisp'')');
    set(HANDLES.fig.main,'WindowButtonDownFcn',@pickxyz);
    
    % turn on msg window edit text box for pickxyz display
    set(HANDLES.pick.disp,'Visible','on')
    % turn on pickxyz toggle button
    set(HANDLES.pick.button,'Visible','on')
    % enable msg window File pulldown save pickxyz
    set(HANDLES.savepicks,'Enable','on')
end