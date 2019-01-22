function read_rawHARPdir(filename,d)
%
% usage: >> read_rawHARPdir(filename,d)
%       if d = 1, then display directory listing values in command window
%
% this function calls the function read_rawHARPhead to get disk header values
% then reads the directory list, rearranges values and puts values in
% global PARAMS variable
%
% raw directory listing format:
%
% name          bytes   btye number
% year          1       1
% month         1       2
% day           1       3
% hour          1       4
% min           1       5
% secs          1       6
% msecs         2       7-8
% blk_number    4       9-12        - starting sector number of data
% num_blocks    4       13-16       - number of sectors recorded
% rec_length    4       17-20       - number of bytes recorded
% sample_rate   4       21-24       - sample rate
% unused        2       25-26
% spare         6       27-32
%
%
% smw  050917 - 050919
% smw 060126
%

global PARAMS

% check to see if file exists - return if not
if ~exist(filename) %#ok<EXIST>
    disp(['Error - no file ',filename])
    return
end

% read raw HARP disk header info
read_rawHARPhead(filename,0)

% display flag: display values = 1
if d
    dflag = 1;
else
    dflag = 0;
end


if PARAMS.head.firstDirSector ~= 8
    return
end

% open raw HARP file
fid = fopen(filename,'r'); % default little Endian for PC

% skip to 1st dir sector
fseek(fid,512*PARAMS.head.firstDirSector,'bof');

% check if directory overrun because of scheduled data and non-full raw
% files or other timing problems
% note: 16 dirlists (ie raw file info) per sector in disk header
if PARAMS.head.currDirSector >= PARAMS.head.firstFileSector
    ndir = (PARAMS.head.firstFileSector - PARAMS.head.firstDirSector) * 16;
else
    ndir = PARAMS.head.nextFile;
end

% read directory listings
for idir = 1:ndir
    % read, then swap even and odd bytes
    if PARAMS.head.ftype == 1
        dl = reshape(circshift(reshape(fread(fid,32,'uint8'),2,16),1),32,1);
    elseif PARAMS.head.ftype == 2
        dl = fread(fid,32,'uint8');
    end
    % store data in the following format:
    % (1) data start sector, (2:8) date/time, (9) sample rate,
    % (10) # of sectors, (11) # of bytes
    if ~strcmp(deblank(PARAMS.head.firmwareVersion),'1.14c') && ~strcmp(deblank(PARAMS.head.firmwareVersion),'1.14e') %...
        %    & ~strcmp(deblank(PARAMS.firmwareVersion),'1.16')
        PARAMS.head.dirlist(idir,:) = [little2big_4byte(dl(9:12))' dl(1:6)' little2big_2byte(dl(7:8))'...
            little2big_4byte(dl(21:24))' little2big_4byte(dl(13:16))' little2big_4byte(dl(17:20))'];
    else
        PARAMS.head.dirlist(idir,:) = [little2big_4byte(dl(9:12))' dl(1:6)' little2big_2byte(dl(7:8))'...
            PARAMS.head.samplerate' little2big_4byte(dl(13:16))' little2big_4byte(dl(17:20))'];
    end
end

% close file
fclose(fid);

if dflag
    disp(' ')
    disp(num2str([(1:size(PARAMS.head.dirlist,1))', PARAMS.head.dirlist]))
end


