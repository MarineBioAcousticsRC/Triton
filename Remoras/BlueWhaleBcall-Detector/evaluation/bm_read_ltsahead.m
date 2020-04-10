function [ltsa,ltsahd] = sh_read_ltsahead(handles)
%
% sh_read_ltsahead
%
% read LTSA header and directories portion of the file
%
% open input ltsa file
fid = fopen(fullfile(handles.LtsaPath,handles.LtsaFile),'r');

% LTSA Header - 64 bytes
type = fread(fid,4,'char');                    % 4 bytes - file ID type
ltsa.ver = fread(fid,1,'uint8');                    % 1 byte - version number
spare = fread(fid,3,'char');                   % 3 bytes - spare
ltsa.dirStartLoc = fread(fid,1,'uint32');           % 4 bytes - directory start location [bytes]
ltsa.dataStartLoc = fread(fid,1,'uint32');          % 4 bytes - data start location [bytes]
ltsa.tave = fread(fid,1,'float32');     % 4 bytes - time bin average for spectra [seconds]
ltsa.dfreq = fread(fid,1,'float32');    % 4 bytes - frequency bin size [Hz]
ltsa.fs = fread(fid,1,'uint32');        % 4 bytes - sample rate [Hz]
ltsa.nfft = fread(fid,1,'uint32');      % 4 bytes - number of samples per fft

if ltsa.ver == 1 || ltsa.ver == 2
    ltsa.nrftot = fread(fid,1,'uint16');    % 2 bytes - total number of raw files from all xwavs
    sk = 27;
elseif ltsa.ver == 3 || ltsa.ver == 4
    ltsa.nrftot = fread(fid,1,'uint32');    % 4 bytes - total number of raw files from all xwavs
    sk = 25;
else
    disp_msg(['Error: incorrect version number ',num2str(ltsa.ver)])
    return
end
ltsa.nxwav = fread(fid,1,'uint16');     % 2 bytes - total number of xwavs files used
ltsa.ch = fread(fid,1,'uint8');         % 1 byte - channel number ltsa'ed
fseek(fid,sk,0);                  % 1 bytes x 27 = 27 bytes - 0 padding / spare
% 64 bytes used - up to here

% directory
% define/initialize some vectors first instead of dynamically - this should
% be faster
ltsahd.year = zeros(1,ltsa.nrftot);
ltsahd.month = zeros(1,ltsa.nrftot);
ltsahd.day = zeros(1,ltsa.nrftot);
ltsahd.hour = zeros(1,ltsa.nrftot);
ltsahd.minute = zeros(1,ltsa.nrftot);
ltsahd.secs = zeros(1,ltsa.nrftot);
ltsahd.ticks = zeros(1,ltsa.nrftot);
ltsa.byteloc = zeros(1,ltsa.nrftot);
ltsa.nave = zeros(1,ltsa.nrftot);

if ltsa.ver < 4
    ltsahd.fname = zeros(ltsa.nrftot,40);
else
    ltsahd.fname = zeros(ltsa.nrftot,80);
end

ltsahd.rfileid = zeros(1,ltsa.nrftot);
ltsa.dnumStart = zeros(1,ltsa.nrftot);
ltsa.dvecStart = zeros(ltsa.nrftot,6);
ltsa.dnumEnd = zeros(1,ltsa.nrftot);
ltsa.dvecEnd = zeros(ltsa.nrftot,6);


for k = 1 : ltsa.nrftot
    % write time values to directory
    ltsahd.year(k) = fread(fid,1,'uchar');          % 1 byte - Year
    ltsahd.month(k) = fread(fid,1,'uchar');         % 1 byte - Month
    ltsahd.day(k) = fread(fid,1,'uchar');           % 1 byte - Day
    ltsahd.hour(k) = fread(fid,1,'uchar');          % 1 byte - Hour
    ltsahd.minute(k) = fread(fid,1,'uchar');        % 1 byte - Minute
    ltsahd.secs(k) = fread(fid,1,'uchar');          % 1 byte - Seconds
    ltsahd.ticks(k) = fread(fid,1,'uint16');        % 2 byte - Milliseconds
    % 8 bytes up to here
    %
    ltsa.byteloc(k) = fread(fid,1,'uint32');     % 4 byte - Byte location in ltsa file of the spectral averages for this rawfile
    if ltsa.ver == 3 || ltsa.ver == 4    % ARP data type = ltsa version 3
        ltsa.nave(k) = fread(fid,1,'uint32');          % 2 byte - number of spectral averages for this raw file
        sk = 7;                                         % nz=7 only for ver=3
    elseif ltsa.ver == 1 || ltsa.ver == 2
        ltsa.nave(k) = fread(fid,1,'uint16');          % 2 byte - number of spectral averages for this raw file
        sk = 9;
    else
        disp_msg(['Error: incorrect version number ',num2str(ltsa.ver)])
        return
    end
    % 14 or 16 bytes up to here
    if ltsa.ver < 4
        ltsahd.fname(k,:) = fread(fid,40,'uchar');        % 40 byte - xwav file name for this raw file header
        ltsahd.rfileid(k) = fread(fid,1,'uint8');       % 1 byte - raw file id / number for this xwav
        fseek(fid,sk,0);
    else
        ltsahd.fname(k,:) = fread(fid,80,'uchar');        % 80 byte - xwav file name for this raw file header
        sk = 4;
        ltsahd.rfileid(k) = fread(fid,1,'uint32');       % 1 byte - raw file id / number for this xwav
        fseek(fid,sk,0);
    end
    % 64 + 40 bytes for each directory listing for each raw file
    
    % calculate starting time [dnum => datenum in days] for each ltsa raw
    % file ie write/buffer flush
    ltsa.dnumStart(k) = datenum([ltsahd.year(k) ltsahd.month(k)...
        ltsahd.day(k) ltsahd.hour(k) ltsahd.minute(k) ...
        ltsahd.secs(k)+(ltsahd.ticks(k)/1000)]);
    ltsa.dvecStart(k,:) = [ltsahd.year(k) ltsahd.month(k)...
        ltsahd.day(k) ltsahd.hour(k) ltsahd.minute(k) ...
        ltsahd.secs(k)+(ltsahd.ticks(k)/1000)];
    
    ltsa.dur(k) = ltsa.tave * ltsa.nave(k);
    
    % end of ltsa for each raw file:
    ltsa.dnumEnd(k) = ltsa.dnumStart(k) ...
        + datenum([0 0 0 0 0 (ltsa.dur(k) - 1/ltsa.fs)]);
    ltsa.dvecEnd(k,:) = ltsa.dvecStart(k,:) ...
        + [0 0 0 0 0 (ltsa.dur(k) - 1/ltsa.fs)];
    
end

ltsa.durtot = sum(ltsa.dur);

% close file
fclose(fid);

% number of frequencies in each spectral average:
% ltsa.nf = floor(ltsa.nfft/2) + 1;
if mod(ltsa.nfft,2) % odd
    ltsa.nf = (ltsa.nfft + 1)/2;
else        % even
    ltsa.nf = ltsa.nfft/2 + 1;
end

% initialize the timing parameters
ltsa.start.dnum = ltsa.dnumStart(1);
ltsa.start.dvec = ltsa.dvecStart(1,:);
ltsa.end.dnum = ltsa.dnumEnd(ltsa.nrftot);

% max freq
% ltsa.fmax = floor(ltsa.fs/2);
ltsa.fmax = (ltsa.nf - 1) * ltsa.dfreq;
ltsa.freq = [0:ltsa.dfreq:ltsa.fmax];
ltsa.f = ltsa.freq;

%init limits
ltsa.freq0 = 0;
ltsa.freq1 = ltsa.fmax;