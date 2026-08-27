function read_rawHARPdir(filename,dflag)
%
% usage: >> read_rawHARPdir(filename,dflag)
%       if dflag = 1, then display directory listing values in command window
%
% this function calls the function read_rawHARPhead to get disk header values
% then reads the directory list, rearranges values and puts values in
% global PARAMS variable
%
% raw directory listing format:
%
% dirlist loc    name          bytes   byte number
% 2              year          1       1
% 3              month         1       2
% 4              day           1       3
% 5              hour          1       4
% 6              min           1       5
% 7              secs          1       6
% 8              msecs         2       7-8
% 1              blk_number    4       9-12        - starting sector number of data
% 10             num_blocks    4       13-16       - number of sectors recorded
% 11             rec_length    4       17-20       - number of bytes recorded
% 9              sample_rate   4       21-24       - sample rate
% n/a            unused        2       25-26
%                Voltage       2       27-28      - mV after diode ~(-0.8V)
% n/a            spare         6       27-32
%
%
% last modified
% 220222 smw
%

global PARAMS

% check to see if file exists - return if not
if ~exist(filename) %#ok<EXIST>
    disp(['Error - no file ',filename])
    return
end

% read raw HARP disk header info if need be
if ~isfield(PARAMS, 'head')
    read_rawHARPhead(filename,dflag)
end

if PARAMS.head.firstDirSector ~= 8
    return
end

% open raw HARP file
fid = fopen(filename,'r'); % default little Endian for PC

% skip to 1st dir sector
fseek(fid,512*PARAMS.head.firstDirSector,'bof');

dirflag = 0;  % switch to reconstruct lost dirlist
% check if directory overrun because of scheduled data and non-full raw
% files or other timing problems
% note: 16 dirlists (ie raw file info) per sector in disk header
if PARAMS.head.currDirSector >= PARAMS.head.firstFileSector
    disp('Warning: Directory Overrun !')
    disp_msg('Warning: Directory Overrun !')
    ndir = (PARAMS.head.firstFileSector - PARAMS.head.firstDirSector - 1) * 16;
    if PARAMS.head.nextFile >= ndir    % lost dirlist, need to reconstruct
       dirflag = 1; 
    end
else
    ndir = PARAMS.head.nextFile;
end

% read directory listings
for idir = 1:ndir
    
    % read, then swap even and odd bytes
    if PARAMS.head.ftype == 1
        dl = fread(fid, 32, 'uint8');
        dl = reshape(circshift(reshape(dl,2,16),1),32,1);
    elseif PARAMS.head.ftype == 2
        dl = fread(fid,32,'uint8');
    end
    % store data in the following format:
    % (1) data start sector, (2:8) date/time, (9) sample rate,
    % (10) # of sectors, (11) # of bytes
    %     if ~strcmp(deblank(PARAMS.head.firmwareVersion),'1.14c') && ~strcmp(deblank(PARAMS.head.firmwareVersion),'1.14e') %...
    %         %    & ~strcmp(deblank(PARAMS.firmwareVersion),'1.16')
    %         PARAMS.head.dirlist(idir,:) = [little2big_4byte(dl(9:12))' dl(1:6)' little2big_2byte(dl(7:8))'...
    %             little2big_4byte(dl(21:24))' little2big_4byte(dl(13:16))' little2big_4byte(dl(17:20))'];
    %     else
    %         PARAMS.head.dirlist(idir,:) = [little2big_4byte(dl(9:12))' dl(1:6)' little2big_2byte(dl(7:8))'...
    %             PARAMS.head.samplerate' little2big_4byte(dl(13:16))' little2big_4byte(dl(17:20))'];
    %     end
    if str2double(PARAMS.head.firmwareVersion(1)) == 3  % for SD HARPs
        if ~strcmp(PARAMS.head.firmwareVersion,'3B02220110') ...
                && ~strcmp(PARAMS.head.firmwareVersion,'3B01211021')
            ticks = (dl(7)*2^8)' + dl(8)';  % this is backwards for older firmware, but should be fixed with newer 3A/3B (March 2022)
        else
            ticks = (dl(8)*2^8)' + dl(7)';  % for ver = 3B02220110 & 3B01211021
        end
        mvolts = (dl(27)*2^8)' + dl(28)';
    else % for SATA and most IDE HARPs
        ticks = little2big_2byte(dl(7:8))';
        mvolts = 0;
    end
    PARAMS.head.dirlist(idir,:) = [little2big_4byte(dl(9:12))' dl(1:6)' ticks...
        little2big_4byte(dl(21:24))' little2big_4byte(dl(13:16))' little2big_4byte(dl(17:20))' ...
        mvolts];
    
end

% close file
fclose(fid);

% specifically for ARCTIC02B & 03B directory overrun - modify if for other
% firmware versions etc...
if dirflag && strcmp(deblank(PARAMS.head.firmwareVersion),'1.17')
    dnum0 = datenum(PARAMS.head.dirlist(ndir,2:7));  % last dirlist datenum
    ddrf = dnum0 - datenum(PARAMS.head.dirlist(ndir-1,2:7));  % time difference between last two dirlist datenums
    Ndir = PARAMS.head.nextFile;  % total number of dirlist (rf) entries
    add0 = PARAMS.head.dirlist(ndir,1);
    sr = PARAMS.head.dirlist(ndir,9);
    nsect = PARAMS.head.dirlist(ndir,10);
    nbytes = PARAMS.head.dirlist(ndir,11);
    mvolts = 0;
    for k = ndir+1:Ndir
        dnum = dnum0 + ddrf;
        addi = add0 + nsect;
        dv = [datevec(dnum,'yy mm dd HH MM SS') 0];
        PARAMS.head.dirlist(k,:) = [addi dv sr nsect nbytes mvolts];
        dnum0 = dnum;
        add0 = addi;
    end
end

if dflag
    disp(' ')
    disp(num2str([(1:size(PARAMS.head.dirlist,1))', PARAMS.head.dirlist]))
end


