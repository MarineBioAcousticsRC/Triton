function write_ltsahead
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% write_ltsahead.m
%
% setup values for ltsa file and write header + directories for new ltsa
% file
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS

% disp('set up ltsa file')

% get file name
% only if not already specified (in case of batchLTSA remora)
% if making single LTSA through triton gui, prompt for filename
if ~isfield(PARAMS.ltsa, 'outfile')
    filterSpec1 = '*.ltsa';
    boxTitle1 = 'Save LTSA File';
    % user interface retrieve file to open through a dialog box
    PARAMS.ltsa.outdir = PARAMS.ltsa.indir;
    PARAMS.ltsa.outfile = 'LTSAout.ltsa';
    DefaultName = [PARAMS.ltsa.outdir,'\',PARAMS.ltsa.outfile];
    [PARAMS.ltsa.outfile,PARAMS.ltsa.outdir]=uiputfile(filterSpec1,boxTitle1,DefaultName);
    % if the cancel button is pushed, then no file is loaded
    % so exit this script
    if strcmp(num2str(PARAMS.ltsa.outfile),'0')
        PARAMS.ltsa.gen = 0;
        disp_msg('Canceled file creation')
        return
    else
        PARAMS.ltsa.gen = 1;
        disp_msg('Opened File: ')
        disp_msg([PARAMS.ltsa.outdir,PARAMS.ltsa.outfile])
        %     disp(' ')
        cd(PARAMS.ltsa.outdir)
    end
end

% calculate file header values, open file and fill up header
maxNrawfiles = PARAMS.ltsa.nrftot + 100;          % maximum number of raw files + a few more

lhsz = 64;         % LTSA header size [bytes]
rhsz = 64 + 40;    % LTSA rawfile header (directory) size (add 40 bytes for longer (up to 80 char) xwav files names)
dirStartLoc = lhsz + 1;                               % directory start location in bytes
dataStartLoc = rhsz * maxNrawfiles + lhsz;           % data start location in bytes

% open output ltsa file
fid = fopen(fullfile(PARAMS.ltsa.outdir,PARAMS.ltsa.outfile),'w');

% LTSA file Header - 64 bytes total
fwrite(fid,'LTSA','char');                  % 4 bytes - file ID type
fwrite(fid,PARAMS.ltsa.ver,'uint8');                      % 1 byte - version number
fwrite(fid,'xxx','char');                   % 3 bytes - spare
fwrite(fid,dirStartLoc,'uint32');           % 4 bytes - directory start location [bytes]
fwrite(fid,dataStartLoc,'uint32');          % 4 bytes - data start location [bytes]
fwrite(fid,PARAMS.ltsa.tave,'float32');     % 4 bytes - time bin average for spectra [seconds]
fwrite(fid,PARAMS.ltsa.dfreq,'float32');    % 4 bytes - frequency bin size [Hz]
fwrite(fid,PARAMS.ltsa.fs,'uint32');        % 4 bytes - sample rate [Hz]
fwrite(fid,PARAMS.ltsa.nfft,'uint32');      % 4 bytes - number of samples per fft

if  PARAMS.ltsa.ver == 4
    fwrite(fid,PARAMS.ltsa.nrftot,'uint32');    % 4 bytes - total number of raw files from all xwavs
    nz = 25;
else
    disp_msg(['Error: incorrect version number ',num2str(PARAMS.ltsa.ver)])
    return
end

fwrite(fid,PARAMS.ltsa.nxwav,'uint16');     % 2 bytes - total number of xwavs files used
% 36 bytes used, up to here
% add channel ltsa'ed 061011 smw
fwrite(fid,PARAMS.ltsa.ch,'uint8');         % 1 byte - channel number that was ltsa'ed
% pad header for future growth, but backward compatible
fwrite(fid,zeros(nz,1),'uint8');                  % 1 bytes x 27 = 27 bytes - 0 padding / spare
% 64 bytes used - up to here

% Directory - one for each raw file - 64 + 40 bytes for each directory listing
for k = 1 : PARAMS.ltsa.nrftot
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
    if PARAMS.ltsa.ftype ~= 1 && PARAMS.ltsa.ftype ~= 3   % for HARP and ARP data
        Nsamp = (PARAMS.ltsahd.write_length(k) * PARAMS.ltsa.blksz) / PARAMS.ltsa.nch;
    elseif PARAMS.ltsa.ftype == 1 || PARAMS.ltsa.ftype == 3   % for wav/Ishmael type data or flac files 
        Nsamp = PARAMS.ltsahd.nsamp(k);
    end
    %
    % number of spectral averages = # samples in rawfile / # samples in fft * compression factor
    % needs to be an integer
    %
    PARAMS.ltsa.nave(k) = ceil(Nsamp/(PARAMS.ltsa.nfft * PARAMS.ltsa.cfact));
    %
    % calculate byte location in ltsa file for 1st spectral
    % average of this raw file
    if k == 1
        ltsaByteLoc = dataStartLoc;
    else
        % ltsa data byte loc = previous loc + # spectral ave (of previous loc) * # freqs in each spectra * # of bytes per spectrum level value
        ltsaByteLoc = ltsaByteLoc +  PARAMS.ltsa.nave(k-1) * PARAMS.ltsa.nfreq * 1;
    end
    
    PARAMS.ltsa.byteloc(k) = ltsaByteLoc;
    
    
    %
    % write ltsa parameters:
    % test if the data exceeds 32 bit limit of byteloc  @JAH 12-2021
    bytelmax = 2^32;
    if PARAMS.ltsa.byteloc(k) > bytelmax
       disp('Input data exceeds limit, use fewer files in LTSA');
       return
    end
    fwrite(fid,PARAMS.ltsa.byteloc(k) ,'uint32');     % 4 byte - Byte location in ltsa file of the spectral averages for this rawfile
    fwrite(fid,PARAMS.ltsa.nave(k) ,'uint32');          % 4 byte - number of spectral averages for this raw file
    % 16 bytes up to here
    fwrite(fid,PARAMS.ltsahd.fname(k,:),'uchar');        % 80 byte - xwav file name for this raw file header
    nz = 4;
    fwrite(fid,PARAMS.ltsahd.rfileid(k),'uint32');       % 4 byte - raw file id / number for this xwav
    fwrite(fid,zeros(nz,1),'uint8');                    % 4 bytes
    % 64 + 40 bytes for each directory listing for each raw file
end

%
% fill up rest of header with zeros before data start
dndir = maxNrawfiles - PARAMS.ltsa.nrftot;              % number of directories not used - to be filled with zeros
dfill = zeros(rhsz * dndir,1);
fwrite(fid,dfill,'uint8');

% close file
fclose(fid);
