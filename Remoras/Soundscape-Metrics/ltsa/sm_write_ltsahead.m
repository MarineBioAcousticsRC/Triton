function sm_write_ltsahead(lIdx)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% sm_write_ltsahead.m
%
% setup values for ltsa file and write header + directories for new ltsa
% file
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CMS NOTES: INSERT BREAKPOINT HERE TO STOP CODE AFTER FINISHING A SINGLE
% LTSA!!
global PARAMS

% pull out start/end idx of files to be included in this LTSA
if PARAMS.ltsa.ftype == 1       % do the following for wav files
    PARAMS.ltsa.startIdx = PARAMS.ltsa.ltsaIdx(lIdx,1);
    PARAMS.ltsa.endIdx = PARAMS.ltsa.ltsaIdx(lIdx,2);
else % do this for xwav files
    PARAMS.ltsa.startIdx = PARAMS.ltsahd.ltsaRawIdx(lIdx,1);
    PARAMS.ltsa.endIdx = PARAMS.ltsahd.ltsaRawIdx(lIdx,2);
end

% define LTSA output file name
if lIdx<10
    fnum = ['0',num2str(lIdx)];
else
    fnum = num2str(lIdx);
end
fname = [PARAMS.ltsa.outfname,'_',fnum,'.ltsa'];
PARAMS.ltsa.outfile = fname;

% calculate file header values, open file and fill up header
if PARAMS.ltsa.ftype == 1       % do the following for wav files
    PARAMS.ltsa.nRawFiles = sum(PARAMS.ltsahd.rfileid(PARAMS.ltsa.startIdx:PARAMS.ltsa.endIdx));
else % do this for xwav files
    PARAMS.ltsa.nRawFiles = PARAMS.ltsa.endIdx - PARAMS.ltsa.startIdx + 1;
end
maxNrawfiles = PARAMS.ltsa.nRawFiles + 20;          % maximum number of raw files + a few more
PARAMS.ltsa.nFiles = PARAMS.ltsa.ltsaIdx(lIdx,2)-PARAMS.ltsa.ltsaIdx(lIdx,1)+1;         %number of files in this LTSA


lhsz = 64;         % LTSA header size [bytes]
rhsz = 64 + 40 + 4;    % LTSA rawfile header (directory) size (add 40 bytes for longer (upto 80 char) xwav files names + 4 empty
dirStartLoc = lhsz + 1;                               % directory start location in bytes
dataStartLoc = rhsz * maxNrawfiles + lhsz;           % data start location in bytes

% open output ltsa file
fid = fopen(fullfile(PARAMS.ltsa.outdir,PARAMS.ltsa.outfile),'w');

% LTSA file Header - 64 bytes total
fwrite(fid,'LTSA','char');                  % 4 bytes - file ID type
fwrite(fid,PARAMS.ltsa.ver,'uint8');        % 1 byte - version number
fwrite(fid,'xxx','char');                   % 3 bytes - spare
fwrite(fid,dirStartLoc,'uint32');           % 4 bytes - directory start location [bytes]
fwrite(fid,dataStartLoc,'uint32');          % 4 bytes - data start location [bytes]
fwrite(fid,PARAMS.ltsa.tave,'float32');     % 4 bytes - time bin average for spectra [seconds]
fwrite(fid,PARAMS.ltsa.dfreq,'float32');    % 4 bytes - frequency bin size [Hz]
fwrite(fid,PARAMS.ltsa.fs,'uint32');        % 4 bytes - sample rate [Hz]
fwrite(fid,PARAMS.ltsa.nfft,'uint32');      % 4 bytes - number of samples per fft

if  PARAMS.ltsa.ver == 4
    fwrite(fid,PARAMS.ltsa.nRawFiles,'uint32');    % 4 bytes - total number of raw files from xwavs in LTSA
    nz = 25;
else
    disp_msg(['Error: incorrect version number ',num2str(PARAMS.ltsa.ver)])
    return
end

fwrite(fid,PARAMS.ltsa.nFiles,'uint16');     % 2 bytes - total number of wav/xwav files used
% 36 bytes used, up to here
% add channel ltsa'ed 061011 smw
fwrite(fid,PARAMS.ltsa.ch,'uint8');         % 1 byte - channel number that was ltsa'ed
% pad header for future growth, but backward compatible
fwrite(fid,zeros(nz,1),'uint8');                  % 1 bytes x 25 = 25 bytes - 0 padding / spare
% 64 bytes used - up to here

l = 1;
% Directory - one for each raw file - 104 + 4 bytes for each directory listing
for k = PARAMS.ltsa.startIdx : PARAMS.ltsa.endIdx
    % write time values to directory
    fwrite(fid,PARAMS.ltsahd.year(k) ,'uchar');          % 1 byte - Year
    fwrite(fid,PARAMS.ltsahd.month(k) ,'uchar');         % 1 byte - Month
    fwrite(fid,PARAMS.ltsahd.day(k) ,'uchar');           % 1 byte - Day
    fwrite(fid,PARAMS.ltsahd.hour(k) ,'uchar');          % 1 byte - Hour
    fwrite(fid,PARAMS.ltsahd.minute(k) ,'uchar');        % 1 byte - Minute
    fwrite(fid,PARAMS.ltsahd.secs(k) ,'uchar');          % 1 byte - Seconds
    fwrite(fid,PARAMS.ltsahd.ticks(k) ,'uint16');        % 2 byte - Milliseconds
    % 8 bytes up to here
    %
    % calculate number of spectral averages for this raw file
    % number of samples in this raw file = # sectors in rawfile * # samples/sector:
    if PARAMS.ltsa.ftype ~= 1   % for HARP and ARP data
        Nsamp = (PARAMS.ltsahd.write_length(k) * PARAMS.ltsa.blksz) / PARAMS.ltsa.nch;
    else        % for wav/Ishmael type data
        Nsamp = PARAMS.ltsahd.nsamp(k);
    end
    %
    % number of spectral averages = # samples in rawfile / # samples in fft * compression factor
    % needs to be an integer
    %
    if PARAMS.ltsa.dtype == 5 %SoundTrap has a few more samples than timing allows, hence cut those out
        PARAMS.ltsa.nave(k) = floor(Nsamp/(PARAMS.ltsa.nfft * PARAMS.ltsa.cfact));
    else
        PARAMS.ltsa.nave(k) = ceil(Nsamp/(PARAMS.ltsa.nfft * PARAMS.ltsa.cfact));
    end
    %
    % calculate byte location in ltsa file for 1st spectral
    % average of this raw file
    if l == 1
        ltsaByteLoc = dataStartLoc;
    else
        % ltsa data byte loc = previous loc + # spectral ave (of previous loc) * # freqs in each spectra * # of bytes per spectrum level value
        ltsaByteLoc = ltsaByteLoc +  PARAMS.ltsa.nave(k-1) * PARAMS.ltsa.nfreq * 4;
    end
    
    PARAMS.ltsa.byteloc(k) = ltsaByteLoc;
    
    
    %
    % write ltsa parameters:
    %
    fwrite(fid,PARAMS.ltsa.byteloc(k) ,'uint64');     % 8 byte - Byte location in ltsa file of the spectral averages for this rawfile
    fwrite(fid,PARAMS.ltsa.nave(k) ,'uint32');          % 4 byte - number of spectral averages for this raw file
    % 20 bytes up to here
    fwrite(fid,PARAMS.ltsahd.fname(k,:),'uchar');        % 80 byte - xwav file name for this raw file header
    fwrite(fid,PARAMS.ltsahd.rfileid(k),'uint32');       % 4 byte - raw file id / number for this xwav
    % 104 bytes up to here
    nz = 4;
    fwrite(fid,zeros(nz,1),'uint8');                    % 4 bytes
    % 104 + 4 bytes for each directory listing for each raw file
    
    l = 2;
end

%
% fill up rest of header with zeros before data start
dndir = maxNrawfiles - PARAMS.ltsa.nRawFiles;              % number of directories not used - to be filled with zeros
dfill = zeros(rhsz * dndir,1);
fwrite(fid,dfill,'uint8');

% close file
fclose(fid);
