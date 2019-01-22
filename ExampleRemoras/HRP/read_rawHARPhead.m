function read_rawHARPhead(filename,d)
%
% usage: >> read_rawHARPhead(filename,d)
%       if d = 1, then display header values in command window
%
% function to read raw HARP disk header info from raw HARP datafile (*.hrp)
% and put disk header info into global variable structure PARAMS
%
% FYI: one sector = 512 bytes
%
% note: at the hardware level of the processors & hard disk the
% odd and even bytes are swapped between datalogger processor
% Motorola MC68xxx (Big Endian) and processing machine - PC (Intel = Little Endian) processor
% i.e., as if 2-byte words converted from big-endian to little-endian
% byteswap for header info is accomplished with:
% sector_swap = reshape(circshift(reshape(sector,2,256),1),512,1);
% use big-endian format for 2-byte data: fid = fopen(filename,'r','b'); or
% x = fread(fid,250,'int16','b');
%
% HARP raw disk structure is:
% sector 0 => Disktype and Disk Number + empty space
% sector 1 => empty
% sector 2 => Disk Header - directory structure information + empty space
% sector 3-7 => empty
% sector 8 => Directory Listing of disk writes + some empty space
% sector 181 => Start of Data for 80 GB disk & HARP firmware version 1.17
%               Data are written in sectors with the first 12 bytes timing
%               info and the next 500 bytes = 250 2-byte(16bit) samples.
%
% smw 050916 - 050917
%
% revised 051108 smw for trashed disk headers
%

global PARAMS

PARAMS.head = [];

% display flag: display values = 1
if d
    dflag = 1;
else
    dflag = 0;
end

% check to see if file exists - return if not
if ~exist(filename)
    disp_msg(['Error - no file ',filename])
    return
end

% open raw HARP file
fid = fopen(filename,'r'); % little Endian is default for PC

% read first 3 sectors:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sector0
sector0 = fread(fid,512,'uint8');

% swap byte locations for other file type
sector0_swap = reshape(circshift(reshape(sector0,2,256),1),512,1);

% figure out Endianess
dt1 = char(sector0_swap(1:4))';     % file type 1 = USB read file
dt2 = char(sector0(1:4))';          % file type 2 = FTP read file (no byte swapping needed?)

% disk type 'HARP'
if strcmp(dt1,'HARP')
    PARAMS.head.ftype = 1;
    sect0 = sector0_swap;
    PARAMS.head.disktype = dt1;
elseif strcmp(dt2,'HARP')
    PARAMS.head.ftype = 2;
    sect0 = sector0;
    PARAMS.head.disktype = dt2;
else
    disp_msg('Error: not HARP')
    return
end

if dflag
    if PARAMS.head.ftype == 1
        disp_msg('filetype 1: USB file')
    elseif PARAMS.head.ftype == 2
        disp_msg('filetype 2: FTP file')
    else
        disp_msg('error: unknow type')
        disp_msg(['dt1= ',dt1,'  dt2= ',dt2])
        return
    end
end

% disk number
PARAMS.head.disknumberSector0 = str2num(char(sect0(13:14))');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sector 1 is empty
sector1 = fread(fid,512,'uint8');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sector 2 = disk header - directory location info
sector2 = fread(fid,512,'uint8');
% swap byte locations
s2s = reshape(circshift(reshape(sector2,2,256),1),512,1);

if PARAMS.head.ftype == 1
    sect2 = s2s;
elseif PARAMS.head.ftype == 2
    sect2 = sector2;
end
% PARAMS.nextSector = s2s(4) + 2^8 * s2s(3) + 2^16 * s2s(2) + 2^24 * s2s(1);
% units for HARP raw disk are bytes, sectors, and files
% 1 byte == 8 bits
% 1 sector == 512 bytes
% 1 file == 60000 sectors
%
% write-block       - next sector to be written on disk
PARAMS.head.nextFileSector = little2big_4byte(sect2(1:4));
% dir_start         - directory start sector
PARAMS.head.firstDirSector = little2big_4byte(sect2(13:16));
% if PARAMS.head.firstDirSector == 8
% dir_size          - number of sectors in directory
PARAMS.head.maxFile = little2big_4byte(sect2(17:20));
% dir_block         - current directory sector
PARAMS.head.currDirSector = little2big_4byte(sect2(21:24));
% dir_count         - next directory entry
PARAMS.head.nextFile = little2big_4byte(sect2(25:28));
% data_start        - sector number where data starts
PARAMS.head.firstFileSector = little2big_4byte(sect2(61:64));
% sample_rate       - current sample rate
PARAMS.head.samplerate = little2big_4byte(sect2(65:68));
% disk number       - disk drive position; 1=drive1, 2=drive2
PARAMS.head.disknumberSector2 = little2big_2byte(sect2(69:70));
% soft_version[10]  - firmware version number
PARAMS.head.firmwareVersion = char(sect2(71:80))';
% description[80]   - unused
PARAMS.head.description = char(sect2(81:160))';
% disk_size         - size of disk in 512 byte sectors
PARAMS.head.disksizeSector = little2big_4byte(sect2(173:176));
% avail_sects       - unused sectors on drive
PARAMS.head.unusedSector = little2big_4byte(sect2(177:180));


if dflag
    disp_msg(' ')
    disp_msg('Sector 0: ')
    disp_msg(['Disk Type = ',PARAMS.head.disktype])
    disp_msg(['Disk Number = ',num2str(PARAMS.head.disknumberSector0)])
    disp_msg(' ')
    
    disp_msg('Sector 2: ')
    disp_msg(['First Directory Location [Sectors] = ',num2str(PARAMS.head.firstDirSector)])
    disp_msg(['Current Directory Location [Sectors] = ',num2str(PARAMS.head.currDirSector)])
    disp_msg(' ')
    disp_msg(['First File Location [Sectors] = ',num2str(PARAMS.head.firstFileSector)])
    disp_msg(['Next File Location [Sectors] = ',num2str(PARAMS.head.nextFileSector)])
    disp_msg(' ')
    disp_msg(['Max Number of Files = ',num2str(PARAMS.head.maxFile)])
    disp_msg(['Next File = ',num2str(PARAMS.head.nextFile)])
    disp_msg(' ')
    disp_msg(['Sample rate = ',num2str(PARAMS.head.samplerate)])
    disp_msg(['Disk Number = ',num2str(PARAMS.head.disknumberSector2)])
    disp_msg(['Firmware Version = ',PARAMS.head.firmwareVersion])
    disp_msg(['Description = ',PARAMS.head.description])
    disp_msg(['Disk Size [Sectors] = ',num2str(PARAMS.head.disksizeSector)])
    disp_msg(['Unused Disk [Sectors] = ',num2str(PARAMS.head.unusedSector)])
end
% close raw HARP file
fclose(fid);