function [ltsa, ltsahd, result] = ioWriteLTSAHeader(ltsa, ltsahd, dir, ...
                                                  fname, version)
% [ltsa, ltsahd, success] = ioWriteLTSAHeader(ltsa, ltsahd, dir, fname, version)
% Initialize and write LTSA header.
% Inputs:
%       ltsa and ltsahd structures describing the LTSA
%       dir, fname - Describes where the LTSA Header will be written
%       version - Version of the LTSA file to write.  If omitted
%               will write the most recent version.
%
% Do not modify the next line, maintained by CVS
% $Id: ioWriteLTSAHeader.m,v 1.3 2008/02/28 16:23:19 mroch Exp $

error(nargchk(4,5,nargin))
if nargin < 5
  ver = ioVersionInfoLTSA;
else
  ver = ioVersionInfoLTSA(version);
end

result = true;  % Assume okay until we find otherwise
ltsa.ver = ver.version;
ltsa.outdir = dir;
ltsa.outfile = fname;

cd(ltsa.outdir)
disp_msg('Generating LTSA');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate file header values, open file and fill up header
maxNrawfiles = ltsa.nrftot + 100;               % max # of raw files + a few more

dirStartLoc = ver.dir_start_posn;              % directory start location in bytes
dirBytes = maxNrawfiles * ver.dir_entry_bytes;        % # bytes occupied by directory
dataStartLoc = ver.core_hdr_bytes + dirBytes;  % data start location in bytes


% open output ltsa file
LTSAFile = fullfile(ltsa.outdir,ltsa.outfile);
fid = fopen(LTSAFile,'w');

if fid == -1 
  disp_msg(sprintf('LTSA:  Unable to open %s for writing', LTSAFile));
  result = false;
  return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% LTSA file Header - ver.core_hdr_bytes bytes total
%
%
fwrite(fid,'LTSA','char');                  % 4 bytes - file ID type
fwrite(fid, ltsa.ver, 'uint8');             % 1 byte - version number
fwrite(fid,'xxx','char');                   % 3 bytes - spare
fwrite(fid,dirStartLoc,'uint32');           % 4 bytes - directory start location [bytes]

% The data start location field is the first byte after the LTSA header
% which consists of the core header part and a directory of files
% contained in the LTSA.
fwrite(fid, dataStartLoc, 'uint32');    % 4 bytes - start of file data

fwrite(fid,ltsa.tave,'float32');     % 4 bytes - time bin average for spectra [seconds]
fwrite(fid,ltsa.dfreq,'float32');    % 4 bytes - frequency bin size [Hz]
fwrite(fid,ltsa.fs,'uint32');        % 4 bytes - sample rate [Hz]
fwrite(fid,ltsa.nfft,'uint32');      % 4 bytes - number of samples per fft
fwrite(fid,ltsa.nrftot,'uint16');    % 2 bytes - total number of raw files from all xwavs
fwrite(fid,ltsa.nxwav,'uint16');     % 2 bytes - total number of xwavs files used
fwrite(fid,ltsa.nch,'uint8');        % 1 byte - channel number ltsa'd
fwrite(fid,ltsa.ch, 'uint8');        % 1 byte - which channel is used in LTSA

if ver.version > 1
  % Each regular expression is NULL terminated with two consecutive NULLs
  % indicating the final regular expression.
  DateString = '';
  NULL = char(0);
  for idx=1:length(ltsa.fnameTimeRegExp)
    % regular expression + NULL terminator
    DateString = [DateString, ...
                  ltsa.fnameTimeRegExp{idx}, NULL];
  end
  if length(DateString) < ver.date_regexp       
    % Pad remaining space with NULL characters, resulting
    % in the last regular expression having two or more 
    % consecutive NULLs.
    DateString = [DateString, ...
                  NULL(ones(1,ver.date_regexp - length(DateString)))];
  else
    error('Date regular expressions too long')
  end
  fwrite(fid, DateString, 'char*1');
end
    
% pad header for future growth (with backwards compatability)
fwrite(fid, zeros(ver.core_hdr_bytes - ftell(fid), 1), 'uint8');

CurrentPosn = ftell(fid);
if CurrentPosn ~= ver.dir_start_posn
  error('Internal LTSA header corruption - preamble');
end
% ver.cor_hdr_bytes used - up to here

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Directory - one for each raw file
% For any given LTSA version, a constant number of bytes per raw file
% descriptor are used.
%
%       Each entry uses ver.dir_bytes bytes: 
%       date information        8 bytes
%       data start              4 bytes
%       # spectral avgs         2 bytes
%       filename string         ver.fnamelen bytes
%       raw file id             1 byte
%       padding                 ver.dir_pad bytes

for k = 1 : ltsa.nrftot
    % write time values to directory (8 bytes)
    fwrite(fid,ltsahd.year(k) ,'uchar');          % 1 byte - Year
    fwrite(fid,ltsahd.month(k) ,'uchar');         % 1 byte - Month
    fwrite(fid,ltsahd.day(k) ,'uchar');           % 1 byte - Day
    fwrite(fid,ltsahd.hour(k) ,'uchar');          % 1 byte - Hour
    fwrite(fid,ltsahd.minute(k) ,'uchar');        % 1 byte - Minute
    fwrite(fid,ltsahd.secs(k) ,'uchar');          % 1 byte - Seconds
    fwrite(fid,ltsahd.ticks(k) ,'uint16');        % 2 byte - Milliseconds

    % calculate number of spectral averages for this raw file
    % number of samples in this raw file = # sectors in rawfile * # samples/sector:
    if ltsa.ftype ~= 1   % for HARP and ARP data
        Nsamp = ltsahd.write_length(k) * ltsa.blksz;
    else        % for wav/Ishmael type data
        Nsamp = ltsahd.nsamp(k);
    end
    %
    % number of spectral averages = 
    %   # samples in rawfile / # samples in fft * compression factor
    % needs to be an integer
    ltsa.nave(k) = ceil(Nsamp/(ltsa.nfft * ltsa.cfact));
    %
    % calculate byte location in ltsa file for 1st spectral
    % average of this raw file
    if k == 1
      ltsaByteLoc = dataStartLoc;       % First data entry
    else
      % ltsa data byte loc = previous loc + 
      %         # spectral ave (of previous loc) * # freqs in each spectra * 
      %                 # of bytes per spectrum level value
      ltsaByteLoc = ltsaByteLoc +  ltsa.nave(k-1) * ltsa.nfreq * 1;
    end
    ltsa.byteloc(k) = ltsaByteLoc;
    %
    % write ltsa parameters:
    %
    % Byte location in ltsa file of the spectral averages for this rawfile
    fwrite(fid, ltsaByteLoc,'uint32');     % 4 bytes

    % Number of spectral averages for this raw file
    fwrite(fid,ltsa.nave(k) ,'uint16');          % 2 bytes

    % Write audio filename to a fixed length field
    % Only prepending spaces supported, so create field backwards and
    % then flip it.  '    ydwoh' ---> 'howdy    '
    % 
    % Xwavs embed multiple unamed files which are numbered.  One directory
    % entry will be created for each raw file, and the Xwav filename will be
    % repeated each time.  Other audio files are treated as Xwavs with
    % a single raw file.

    % Format string to pad to correct field size, e.g. %40s for 40 byte field
    FormatStr = sprintf('%%%ds', ver.fnamelen);
    
    FilenamePadded = fliplr(sprintf(FormatStr, fliplr(ltsahd.fname{k})));
    fwrite(fid, FilenamePadded, 'uchar');        % filename ver.fnamelen bytes
    fwrite(fid,ltsahd.rfileid(k),'uint8');       % 1 byte raw file id
    fwrite(fid,zeros(ver.dir_pad, 1), 'uint8');  % zero padding / spares
end

%
% fill up unused directory entries with zeros before data start
dndir = maxNrawfiles - ltsa.nrftot;   % number unused directories
dfill = zeros(ver.dir_entry_bytes * dndir, 1);
fwrite(fid,dfill,'uint8');

CurrentPosn = ftell(fid);
if CurrentPosn ~= dataStartLoc;
  error('Internal LTSA header corruption - preamble');
end

% audit header
fclose(fid);    % Header complete, close file

