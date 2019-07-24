function io_readLTSAHeader(Filename)
% hdr = io_readLTSAHeader(Filename)
% Read in information from an long term spectral avg header
%
% Do not modify the following line, maintained by CVS
% $Id: ioReadLTSAHeader.m,v 1.10 2012/03/22 20:05:24 johanna Exp $


fid = fopen(Filename,'r');      % open input ltsa file
if fid == -1
  error('Unable to open %s', Filename);
end

%%%%%%%%%%%%%%%%%%%%%%%%%
%
% LTSA Header - 
%
type = fread(fid,4,'char');                    % 4 bytes - file ID type

global REMORA

ship_init_ltsaParams



% Populate base directory and LTSA filename
[~, fname, ext] = fileparts(Filename);
REMORA.ship_dt.ltsa.infile = [fname, ext];

REMORA.ship_dt.ltsa.ver = fread(fid,1,'uint8');           % 1 byte - version number
ver = ioVersionInfoLTSA(REMORA.ship_dt.ltsa.ver);  % Retrieve LTSA version

spare = fread(fid,3,'char');                   % 3 bytes - spare

REMORA.ship_dt.ltsa.dirStartLoc = fread(fid,1,'uint32');           % 4 bytes - directory start location [bytes]
REMORA.ship_dt.ltsa.dataStartLoc = fread(fid,1,'uint32');          % 4 bytes - data start location [bytes]
REMORA.ship_dt.ltsa.tave = fread(fid,1,'float32');     % 4 bytes - time bin average for spectra [seconds]
REMORA.ship_dt.ltsa.dfreq = fread(fid,1,'float32');    % 4 bytes - frequency bin size [Hz]
REMORA.ship_dt.ltsa.fs = fread(fid,1,'uint32');        % 4 bytes - sample rate [Hz]
REMORA.ship_dt.ltsa.nfft = fread(fid,1,'uint32');      % 4 bytes - number of samples per fft
REMORA.ship_dt.ltsa.nrftot = fread(fid,1,'uint16');    % 2 bytes - total number of raw files from all xwavs
spare2 = fread(fid,1,'uint16'); 
REMORA.ship_dt.ltsa.nxwav = fread(fid,1,'uint16');     % 2 bytes - total number of xwavs files used
REMORA.ship_dt.ltsa.nch = fread(fid,1,'uint8');        % 1 byte - number channels
REMORA.ship_dt.ltsa.ch = fread(fid, 1, 'uint8');       % 1 byte - channel LTSA'd
% 36 bytes used, up to here

if ver.version == 255 % null version
  % Read regular expressions for parsing dates
  REString = char(fread(fid, ver.date_regexp, 'char*1')');
  % Each expression is NULL terminated.  The final expression is
  % terminated by two consecutive NULLs.
  NULL = char(0);
  NULLsAt = find(REString == NULL);
  %  LastNULL = 0;
  nidx = 1;
  Start = 1;
  while NULLsAt(nidx) - Start > 0
    % take string from current posn to just before NULL
    restrings{nidx} = REString(Start:NULLsAt(nidx)-1);
    % Next start just after NULL
    Start = NULLsAt(nidx)+1;
    nidx = nidx + 1;
  end
  REMORA.ship_dt.ltsa.fnameTimeRegExp = restrings;
end
       
fseek(fid, ver.dir_start_posn, 'bof');     % Seek to start of directory entries


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% directory
%
% define/initialize some vectors first instead of dynamically - this should
% be faster

REMORA.ship_dt.ltsahd.year = zeros(1,REMORA.ship_dt.ltsa.nrftot);
REMORA.ship_dt.ltsahd.month = zeros(1,REMORA.ship_dt.ltsa.nrftot);
REMORA.ship_dt.ltsahd.day = zeros(1,REMORA.ship_dt.ltsa.nrftot);
REMORA.ship_dt.ltsahd.hour = zeros(1,REMORA.ship_dt.ltsa.nrftot);
REMORA.ship_dt.ltsahd.minute = zeros(1,REMORA.ship_dt.ltsa.nrftot);
REMORA.ship_dt.ltsahd.secs = zeros(1,REMORA.ship_dt.ltsa.nrftot);
REMORA.ship_dt.ltsahd.ticks = zeros(1,REMORA.ship_dt.ltsa.nrftot);
REMORA.ship_dt.ltsa.byteloc = zeros(1,REMORA.ship_dt.ltsa.nrftot);
REMORA.ship_dt.ltsa.nave = zeros(1,REMORA.ship_dt.ltsa.nrftot);

REMORA.ship_dt.ltsahd.fname = cell(REMORA.ship_dt.ltsa.nrftot,1);

REMORA.ship_dt.ltsahd.rfileid = zeros(1,REMORA.ship_dt.ltsa.nrftot);
REMORA.ship_dt.ltsa.dnumStart = zeros(1,REMORA.ship_dt.ltsa.nrftot);
REMORA.ship_dt.ltsa.dvecStart = zeros(REMORA.ship_dt.ltsa.nrftot,6);
REMORA.ship_dt.ltsa.dnumEnd = zeros(1,REMORA.ship_dt.ltsa.nrftot);
REMORA.ship_dt.ltsa.dvecEnd = zeros(REMORA.ship_dt.ltsa.nrftot,6);


for k = 1 : REMORA.ship_dt.ltsa.nrftot
    % write time values to directory
    REMORA.ship_dt.ltsahd.year(k) = fread(fid,1,'uchar');          % 1 byte - Year
    REMORA.ship_dt.ltsahd.month(k) = fread(fid,1,'uchar');         % 1 byte - Month
    REMORA.ship_dt.ltsahd.day(k) = fread(fid,1,'uchar');           % 1 byte - Day
    REMORA.ship_dt.ltsahd.hour(k) = fread(fid,1,'uchar');          % 1 byte - Hour
    REMORA.ship_dt.ltsahd.minute(k) = fread(fid,1,'uchar');        % 1 byte - Minute
    REMORA.ship_dt.ltsahd.secs(k) = fread(fid,1,'uchar');          % 1 byte - Seconds
    REMORA.ship_dt.ltsahd.ticks(k) = fread(fid,1,'uint16');        % 2 byte - Milliseconds
    % 8 bytes up to here
    %
    REMORA.ship_dt.ltsa.byteloc(k) = fread(fid,1,'uint32');     % 4 byte - Byte location in ltsa file of the spectral averages for this rawfile
    if ismember(ver.version,[1,2,255])
        % 2 byte - number of spectral averages for this raw file
        prcsn = 'uint16';
    elseif ismember(ver.version,[3,4])
        % 4 byte - number of spectral averages for this raw file
        prcsn = 'uint32';
    else 
        errStr = sprintf('Unknown LTSA version %d\n', ver.version); 
        disp(errStr);
        disp_msg(errStr);
    end
    REMORA.ship_dt.ltsa.nave(k) = fread(fid,1,prcsn);  
    
    % 14 bytes up to here
    
    % Read filename for this entry.
    % Note that if file is an xwav, it may have multiple directory
    % entries, one for each of the embedded raw files.
    REMORA.ship_dt.ltsahd.fname{k} = deblank(char(fread(fid, ver.fnamelen, 'uchar')'));
    % Fix directory separator
    if ispc
      % Not mandatory of Windows, accepts / and \, but change to
      % canonical form
      REMORA.ship_dt.ltsahd.fname{k} = strrep(REMORA.ship_dt.ltsahd.fname{k}, '\', '/');
    else
      % If LTSA created on a Windows box, directories will be separated
      %  with a \.  Change to /.
      REMORA.ship_dt.ltsahd.fname{k} = strrep(REMORA.ship_dt.ltsahd.fname{k}, '\', '/');
    end
    REMORA.ship_dt.ltsahd.rfileid(k) = fread(fid,1,'uint8');       % 1 byte - raw file id
    
    % Rest of entry is padding for expansion of directory entry - skip
    fseek(fid, ver.dir_pad,0);
    
    % stolen from rdxwavhd.m:
    % calculate starting time [dnum => datenum in days] for each ltsa raw
    % file ie write/buffer flush
    REMORA.ship_dt.ltsa.dnumStart(k) = datenum([REMORA.ship_dt.ltsahd.year(k) REMORA.ship_dt.ltsahd.month(k)...
        REMORA.ship_dt.ltsahd.day(k) REMORA.ship_dt.ltsahd.hour(k) REMORA.ship_dt.ltsahd.minute(k) ...
        REMORA.ship_dt.ltsahd.secs(k)+(REMORA.ship_dt.ltsahd.ticks(k)/1000)]);
    REMORA.ship_dt.ltsa.dvecStart(k,:) = [REMORA.ship_dt.ltsahd.year(k) REMORA.ship_dt.ltsahd.month(k)...
        REMORA.ship_dt.ltsahd.day(k) REMORA.ship_dt.ltsahd.hour(k) REMORA.ship_dt.ltsahd.minute(k) ...
        REMORA.ship_dt.ltsahd.secs(k)+(REMORA.ship_dt.ltsahd.ticks(k)/1000)];
    
            REMORA.ship_dt.ltsa.dur(k) = REMORA.ship_dt.ltsa.tave * REMORA.ship_dt.ltsa.nave(k);
            
    % end of ltsa for each raw file:
    REMORA.ship_dt.ltsa.dnumEnd(k) = REMORA.ship_dt.ltsa.dnumStart(k) ...
        + datenum([0 0 0 0 0 (REMORA.ship_dt.ltsa.dur(k) - 1/REMORA.ship_dt.ltsa.fs)]);
    REMORA.ship_dt.ltsa.dvecEnd(k,:) = REMORA.ship_dt.ltsa.dvecStart(k,:) ...
        + [0 0 0 0 0 (REMORA.ship_dt.ltsa.dur(k) - 1/REMORA.ship_dt.ltsa.fs)];
    
end

REMORA.ship_dt.ltsa.durtot = sum(REMORA.ship_dt.ltsa.dur);

% close file
fclose(fid);

% number of frequencies in each spectral average:
REMORA.ship_dt.ltsa.nf = REMORA.ship_dt.ltsa.nfft/2 + 1;	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initialize the timing parameters
REMORA.ship_dt.ltsa.start.dnum = REMORA.ship_dt.ltsa.dnumStart(1);
REMORA.ship_dt.ltsa.start.dvec = REMORA.ship_dt.ltsa.dvecStart(1,:);
REMORA.ship_dt.ltsa.end.dnum = REMORA.ship_dt.ltsa.dnumEnd(REMORA.ship_dt.ltsa.nrftot);

% max freq
REMORA.ship_dt.ltsa.fmax = REMORA.ship_dt.ltsa.fs/2;

% frequency bin indices
REMORA.ship_dt.ltsa.fimin = 1;
REMORA.ship_dt.ltsa.fimax = REMORA.ship_dt.ltsa.nf;

% frequency bins
REMORA.ship_dt.ltsa.freq = [0:REMORA.ship_dt.ltsa.dfreq:REMORA.ship_dt.ltsa.fmax];
REMORA.ship_dt.ltsa.f = REMORA.ship_dt.ltsa.freq;

