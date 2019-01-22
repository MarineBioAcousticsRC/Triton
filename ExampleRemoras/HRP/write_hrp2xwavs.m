function write_hrp2xwavs(infilename,hdrfilename,outdir,d)
%
% usage: >>write_hrp2xwavs(infilename,hdrfilename,outdir,d)
%       infilename == 64-bit FileSystem file name for raw HARP disk data (*.hrp)
%       hdrfilename == header parameter info file name (*.hdr) ascii text
%       outdir == FAT32 FileSystem directory for XWAV (*.x.wav) files
%       d == display on =1, display off = 0
%
% This function writes multiple XWAV (*.x.wav) files (~1GB) from single raw
% HARP disk file (*.hrp). The HRP files are generated on linux 64-bit
% macine using:
% $ dd if=/dev/hdd of=filename.hrp
% or
% $ dd if=/dev/hdd of=filename.hrp bs=1M
% which may be faster by ~ 30%... more bench testing is needed for
% optimizing (speeding up) the backup process.  HRP files saved onto ext3
% linux disk type - this will allow for large files above the 32-bit
% indexing limit.  The XWAV files will be written to FAT32 large capacity
% disks so that Windows OS can read - i.e., triton, ishmael, matlab, etc.
%
% the HDR (*.hdr) file includes info specific to the HRP file. For
% instance, Instrument ID, Experiment name, Lat, Lon, Depth
%
%
% smw 050920 - 051129
% smw 060126
%
global PARAMS

tic % start stopwatch timer

% check to see if files and directory exist - return if not
if ~exist(infilename)
    disp(['Error - no file ',infilename])
    return
end
if ~exist(hdrfilename)
    disp(['Error - no file ',hdrfilename])
    return
end
if ~exist(outdir)
    disp(['Error - no directory ',outdir])
    return
end

% display flag: display values = 1
if d
    dflag = 1;
else
    dflag = 0;
end

% read raw HARP dirlist (and disk header from within read_rawHARPdir)
read_rawHARPdir(infilename,0);

% check firmware for compression or multiple channels
ckFirmware;

% check for dirlist timing problems and fix
fix_dirlistTimes(dflag)

% Error counter for rawfiles reads/decompress
PARAMS.error.csl = 0;   % count sync losses

% check for schedule over-run
sflag = 0;
% check if directory overrun because of scheduled data and non-full raw
% files or other timing problems
% note: 16 dirlists (ie raw file info) per sector in disk header
if PARAMS.head.currDirSector >= PARAMS.head.firstFileSector
    ndir = (PARAMS.head.firstFileSector - PARAMS.head.firstDirSector) * 16;
    disp(' ')
    disp(['Schedule Over-Run on file ',infilename])
    disp(['PARAMS.head.nextFile =',num2str(PARAMS.head.nextFile)])
    disp(['PARAMS.head.maxFile =', num2str(PARAMS.head.maxFile)])
    disp(['PARAMS.head.currDirSector =',num2str(PARAMS.head.currDirSector)])
    disp(['PARAMS.head.firstFileSector =',num2str(PARAMS.head.firstFileSector)])
    sflag = 1;
    disp(' ')
    disp(['Set number of files to : ',num2str(ndir)])
    disp(' ')
    disp('Need more software development to handle this situation')
    % return
else
    ndir = PARAMS.head.nextFile;
end



% after the disk header and directory listing in the raw HRP file the data
% are arranged in 512 byte sectors (or blocks):
headblk = 12;   % data block header length in bytes
if PARAMS.nch == 1
    datasamp = 250; % number of samples per data block
    tailblk = 0;
elseif PARAMS.nch == 4
    datasamp = 248;   % number of samples per data block
    tailblk = 4;    % skip the last two 'samples' ie 4 bytes
end

% Calculate the number of XWAV files to write. Since each raw file (within
% the HRP file) is about 30 MB and using an integer number of raw files to
% make one xwav file, let's use 30 raw files (or about 900 MB) to keep
% the XWAV file around 1GB - nice size, not too small (ie too many XWAV
% files generated), not too large (ie can't be written to a FAT32 system)
% Note: each raw file (ie disk writes) = 60000 sectors (or blocks) x 512
% bytes per block = 30720000 bytes.  In each sector, 12 bytes are timing
% head info and the other 500 bytes are 250 x 2-byte samples. So, each XWAV
% file will have 900,000,000 bytes (450x10^6 samples) of data + some
% header.  The last XWAV file made from an HRP file will likely have less
% than 30 raw files (disk writes) in it...

NRF = 30;
nhrp = NRF;  % 30 raw files
% dxwav = PARAMS.nextFile/nhrp;   % total decimal number of XWAV files
dxwav = ndir/nhrp;   % total decimal number of XWAV files
nxwav = ceil(dxwav); % number of XWAV files

% Generate XWAV file name prefix based on Experiment, Site or Instrument
% date/time of 1st data sample info will be used in latter part of name
%
% Example: SoCal01_FR05_050730_223017.x.wav
%
% read XWAV header file info - need this first
read_xwavHDRfile(hdrfilename,0);
%
% remove blanks
ename = deblank(PARAMS.xhd.ExperimentName);
sname = deblank(PARAMS.xhd.SiteName);
if strcmp(sname,'XXXX')
    prefix = [ename,'_'];
else
    prefix = [ename,'_',sname,'_'];
end

% open raw HARP file
fid = fopen(infilename,'r');

bflag = 0;
% loop over the XWAV files
for k = 1:nxwav
%for k = 1:1
    % special case loops
    % for k = nxwav:nxwav
    % for k = 78:109
%     for k = 70:70
    % first raw file header in XWAV
    fhdr = NRF * (k -1) + 1;
    % gnerate XWAV file name based on date/time of first raw file header
    date_name = num2str([PARAMS.head.dirlist(fhdr,2),PARAMS.head.dirlist(fhdr,3),PARAMS.head.dirlist(fhdr,4)],'%02d');
    time_name = num2str([PARAMS.head.dirlist(fhdr,5),PARAMS.head.dirlist(fhdr,6),PARAMS.head.dirlist(fhdr,7)],'%02d');
    name = [prefix,date_name,'_',time_name,'.x.wav'];
    if ispc % if PC/Windows OS
        fname = [outdir,'\',name];
    else
        fname = [outdir,name];
    end
    if dflag
        disp(' ')
        disp(['Filename = ',fname])
        disp(' ')
        disp(['XWAV File ',num2str(k),' out of ',num2str(nxwav)])
        disp(' ')
    end
    % open XWAV file
    fod = fopen(fname,'w');
    % change nhrp for last file, if needed
    if k == nxwav && nxwav ~= dxwav
        nhrp = round((dxwav - (nxwav - 1)) * nhrp);
    end
    % write XWAV header info
    write_XWAVhead(fod,fhdr,nhrp)
    % loop over raw files and get the data into XWAV file
    for h = 1:nhrp
        % skip to start of raw file
        status = fseek(fid,PARAMS.head.dirlist(fhdr+h-1,1)*512,'bof');
        if status ~= 0
            disp(['Error - failed fseek to byte ',num2str(PARAMS.head.dirlist(fhdr+h-1,1)*512)])
            fclose('all')
            bflag = 1;
            break
        end
        if dflag
            disp(['Raw File : ',num2str(h)])
        end
        % check for data type and read/write data
        if ~PARAMS.cflag     % non-compression and 4 channel
            % loop over sectors in harp raw file
            for m = 1:PARAMS.head.dirlist(fhdr+h-1,10)
                fseek(fid,headblk,0);	% skip over header, assume time is good
                % (ie only dirlisting for timing)
                if PARAMS.nch == 4
                    fwrite(fod,fread(fid,datasamp,'uint16')-32767,'int16');
                else
                    fwrite(fod,fread(fid,datasamp,'int16'),'int16');
                end
                fseek(fid,tailblk,0);   % skip over tail bytes (=0 for nchan=1, =4 for nchan=4)
            end
        else        % compression
            fwrite(fod,decompressRawHRP(fid,h + NRF*(k-1),PARAMS.ctype),'int16');
        end
    end  % end for h, loop over raw files
    % close XWAV file
    fclose(fod);
    if bflag
        break
    end
end
% close raw HRP file
fclose(fid);
disp(' ')
disp('Done')
disp(' ')
t = toc; % get elasped time
disp(['Elasped time for making ',num2str(k),' XWAV files ',num2str(t),' secs'])




