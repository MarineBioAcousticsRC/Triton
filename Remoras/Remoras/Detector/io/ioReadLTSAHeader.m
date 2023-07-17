function hdr = ioReadLTSAHeader(Filename)
% hdr = ioReadLTSAHeader(Filename)
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

global PARAMS
hdr = init_ltsaparams(PARAMS);

% Populate base directory and LTSA filename
[hdr.ltsa.inpath, fname, ext] = fileparts(Filename);
hdr.ltsa.infile = [fname, ext];

hdr.ltsa.ver = fread(fid,1,'uint8');           % 1 byte - version number
ver = ioVersionInfoLTSA(hdr.ltsa.ver);  % Retrieve LTSA version

spare = fread(fid,3,'char');                   % 3 bytes - spare

hdr.ltsa.dirStartLoc = fread(fid,1,'uint32');           % 4 bytes - directory start location [bytes]
hdr.ltsa.dataStartLoc = fread(fid,1,'uint32');          % 4 bytes - data start location [bytes]
hdr.ltsa.tave = fread(fid,1,'float32');     % 4 bytes - time bin average for spectra [seconds]
hdr.ltsa.dfreq = fread(fid,1,'float32');    % 4 bytes - frequency bin size [Hz]
hdr.ltsa.fs = fread(fid,1,'uint32');        % 4 bytes - sample rate [Hz]
hdr.ltsa.nfft = fread(fid,1,'uint32');      % 4 bytes - number of samples per fft
hdr.ltsa.nrftot = fread(fid,1,'uint16');    % 2 bytes - total number of raw files from all xwavs
hdr.ltsa.nxwav = fread(fid,1,'uint16');     % 2 bytes - total number of xwavs files used
hdr.ltsa.nch = fread(fid,1,'uint8');        % 1 byte - number channels
hdr.ltsa.ch = fread(fid, 1, 'uint8');       % 1 byte - channel LTSA'd
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
  hdr.ltsa.fnameTimeRegExp = restrings;
end
       
fseek(fid, ver.dir_start_posn, 'bof');     % Seek to start of directory entries


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% directory
%
% define/initialize some vectors first instead of dynamically - this should
% be faster

hdr.ltsahd.year = zeros(1,hdr.ltsa.nrftot);
hdr.ltsahd.month = zeros(1,hdr.ltsa.nrftot);
hdr.ltsahd.day = zeros(1,hdr.ltsa.nrftot);
hdr.ltsahd.hour = zeros(1,hdr.ltsa.nrftot);
hdr.ltsahd.minute = zeros(1,hdr.ltsa.nrftot);
hdr.ltsahd.secs = zeros(1,hdr.ltsa.nrftot);
hdr.ltsahd.ticks = zeros(1,hdr.ltsa.nrftot);
hdr.ltsa.byteloc = zeros(1,hdr.ltsa.nrftot);
hdr.ltsa.nave = zeros(1,hdr.ltsa.nrftot);

hdr.ltsahd.fname = cell(hdr.ltsa.nrftot,1);

hdr.ltsahd.rfileid = zeros(1,hdr.ltsa.nrftot);
hdr.ltsa.dnumStart = zeros(1,hdr.ltsa.nrftot);
hdr.ltsa.dvecStart = zeros(hdr.ltsa.nrftot,6);
hdr.ltsa.dnumEnd = zeros(1,hdr.ltsa.nrftot);
hdr.ltsa.dvecEnd = zeros(hdr.ltsa.nrftot,6);


for k = 1 : hdr.ltsa.nrftot
    % write time values to directory
    hdr.ltsahd.year(k) = fread(fid,1,'uchar');          % 1 byte - Year
    hdr.ltsahd.month(k) = fread(fid,1,'uchar');         % 1 byte - Month
    hdr.ltsahd.day(k) = fread(fid,1,'uchar');           % 1 byte - Day
    hdr.ltsahd.hour(k) = fread(fid,1,'uchar');          % 1 byte - Hour
    hdr.ltsahd.minute(k) = fread(fid,1,'uchar');        % 1 byte - Minute
    hdr.ltsahd.secs(k) = fread(fid,1,'uchar');          % 1 byte - Seconds
    hdr.ltsahd.ticks(k) = fread(fid,1,'uint16');        % 2 byte - Milliseconds
    % 8 bytes up to here
    %
    hdr.ltsa.byteloc(k) = fread(fid,1,'uint32');     % 4 byte - Byte location in ltsa file of the spectral averages for this rawfile
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
    hdr.ltsa.nave(k) = fread(fid,1,prcsn);  
    
    % 14 bytes up to here
    
    % Read filename for this entry.
    % Note that if file is an xwav, it may have multiple directory
    % entries, one for each of the embedded raw files.
    hdr.ltsahd.fname{k} = deblank(char(fread(fid, ver.fnamelen, 'uchar')'));
    % Fix directory separator
    if ispc
      % Not mandatory of Windows, accepts / and \, but change to
      % canonical form
      hdr.ltsahd.fname{k} = strrep(hdr.ltsahd.fname{k}, '\', '/');
    else
      % If LTSA created on a Windows box, directories will be separated
      %  with a \.  Change to /.
      hdr.ltsahd.fname{k} = strrep(hdr.ltsahd.fname{k}, '\', '/');
    end
    hdr.ltsahd.rfileid(k) = fread(fid,1,'uint8');       % 1 byte - raw file id
    
    % Rest of entry is padding for expansion of directory entry - skip
    fseek(fid, ver.dir_pad,0);
    
    % stolen from rdxwavhd.m:
    % calculate starting time [dnum => datenum in days] for each ltsa raw
    % file ie write/buffer flush
    hdr.ltsa.dnumStart(k) = datenum([hdr.ltsahd.year(k) hdr.ltsahd.month(k)...
        hdr.ltsahd.day(k) hdr.ltsahd.hour(k) hdr.ltsahd.minute(k) ...
        hdr.ltsahd.secs(k)+(hdr.ltsahd.ticks(k)/1000)]);
    hdr.ltsa.dvecStart(k,:) = [hdr.ltsahd.year(k) hdr.ltsahd.month(k)...
        hdr.ltsahd.day(k) hdr.ltsahd.hour(k) hdr.ltsahd.minute(k) ...
        hdr.ltsahd.secs(k)+(hdr.ltsahd.ticks(k)/1000)];
    
            hdr.ltsa.dur(k) = hdr.ltsa.tave * hdr.ltsa.nave(k);
            
    % end of ltsa for each raw file:
    hdr.ltsa.dnumEnd(k) = hdr.ltsa.dnumStart(k) ...
        + datenum([0 0 0 0 0 (hdr.ltsa.dur(k) - 1/hdr.ltsa.fs)]);
    hdr.ltsa.dvecEnd(k,:) = hdr.ltsa.dvecStart(k,:) ...
        + [0 0 0 0 0 (hdr.ltsa.dur(k) - 1/hdr.ltsa.fs)];
    
end

hdr.ltsa.durtot = sum(hdr.ltsa.dur);

% close file
fclose(fid);

% number of frequencies in each spectral average:
hdr.ltsa.nf = hdr.ltsa.nfft/2 + 1;	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initialize the timing parameters
hdr.ltsa.start.dnum = hdr.ltsa.dnumStart(1);
hdr.ltsa.start.dvec = hdr.ltsa.dvecStart(1,:);
hdr.ltsa.end.dnum = hdr.ltsa.dnumEnd(hdr.ltsa.nrftot);

% max freq
hdr.ltsa.fmax = hdr.ltsa.fs/2;

% frequency bin indices
hdr.ltsa.fimin = 1;
hdr.ltsa.fimax = hdr.ltsa.nf;

% frequency bins
hdr.ltsa.freq = [0:hdr.ltsa.dfreq:hdr.ltsa.fmax];
hdr.ltsa.f = hdr.ltsa.freq;

