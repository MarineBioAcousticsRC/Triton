function plot_hrpSectorTimes(~)
%
% 101105 smw stolen from read_rawHARPdataTimes.m
%
% called from Triton Tools-> HRP file -> plot Sector Times
%
% 080904 smw stolen from read_rawHARPdataTimes.m to output each of the
% time stamps in one raw data file (i.e., 60000 per raw file - not the dirlist times)
%
% usage: >> [dvec] = read_rawHARPdata(filename,d,numFile)
%       dvec == date vector -> format: [yyyy mm dd HH MM SS.mmm]
%       data == one raw HARP file of 2-byte data
%       filename == FileSystem file name for raw HARP disk data
%       d = 1 -> display some stuff in command window, = 0 then no display
%       numFile == file number per raw HARP disk data
%
% this function reads one raw HARP disk data file, typically 60000 sectors
% the first timing header will be read and used.  Use a data header (not
% directory listing) timing checker to see if each sector (block) is
% contiguous
%
%   smw 050919
%
% units for HARP raw disk are bytes, sectors, and files
% 1 byte == 8 bits
% 1 sector == 512 bytes
% 1 file == 60000 sectors

global PARAMS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% open file stuff
inpath = PARAMS.inpath;             % some place to start
cd(inpath);                         % go there
filterSpec1 = '*.hrp';
% user interface retrieve file to open through a dialog box
boxTitle1 = 'Choose HRP file to plot sector times';
[infile,inpath]=uigetfile(filterSpec1,boxTitle1);
filename = [inpath,infile];
disp_msg('Opened File: ')
disp_msg([inpath,infile])
% if the cancel button is pushed, then no file is loaded
% so exit this script
if infile == 0
    disp_msg('Cancel Open File')
    return
end
fid = fopen([inpath,infile],'r'); %for usb file
if fid == -1
    disp_msg('Error: no such file')
    return
end
% check to see if file exists - return if not
if ~exist(filename)
    disp(['Error - no file ',filename])
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get user input
dflag = 1;
numFile = 1;
nrawFiles = 1;
nch = 1;
% user input dialog box
prompt={'Display Flag : no = 0,  yes = 1',...
    'First Raw File Number : ',...
    'Number of Raw Files to Process ',...
    'Enter number of Channels (1 or 4) : '};
def={num2str(dflag),...
    num2str(numFile),...
    num2str(nrawFiles),...
    num2str(nch)};
dlgTitle='Set Sector Plot Parameters';
lineNo=1;
AddOpts.Resize='on';
AddOpts.WindowStyle='normal';
AddOpts.Interpreter='tex';
in=inputdlg(prompt,dlgTitle,lineNo,def,AddOpts);
if isempty(in)	% if cancel button pushed
    return
end
%%%%%%%%%%%%%%%%%%%%%%%
dflag = str2num(deal(in{1}));
numFile = str2num(deal(in{2}));
nrawFiles = str2num(deal(in{3}));
nch = str2num(deal(in{4}));
if nch == 1
    ftype = 1;
elseif nch == 4
    ftype = 2;
else
    ftype = 3;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read raw HARP dirlist (and disk header from within read_rawHARPdir)
read_rawHARPdir(filename,0);

if numFile > PARAMS.head.nextFile
    disp(['Error - last raw file = ',num2str(PARAMS.head.nextFile)])
    disp(['You chose filenumber = ', num2str(numFile)])
    return
end

% open raw HARP file
fid = fopen(filename,'r');

% skip to 1st dir sector of data (raw file number)
fseek(fid,512*PARAMS.head.dirlist(numFile,1),'bof');

tic
% loop over the number of sectors for this file

% ftype = 2;
if ftype == 1
    nSectPerRaw = 60000;
    nBytesPerSect = 500;
    tailblk = 0;
elseif ftype == 2
    nSectPerRaw = 58000;
    nBytesPerSect = 496;
    tailblk = 4;    % skip the last two 'samples' ie 4 bytes
else
    disp(['Error - incorrect file type: ',num2str(ftype)])
    return
end

% nrawFiles = 1;
nsect = nrawFiles * nSectPerRaw;   % number of sectors to check
dvec = zeros(nsect,7);
dvec2 = zeros(nsect,6);
count = 1;

dv = fread(fid,12,'uint8');
dvec(1,1:7) = [dv(2) dv(1) dv(4) dv(3) dv(6) dv(5) ...
    little2big_2byte([dv(8) dv(7)])];

for ii = 2:nsect
    fseek(fid,nBytesPerSect,0);
    fseek(fid,tailblk,0);
    dv = fread(fid,12,'uint8');
    dvec(ii,1:7) = [dv(2) dv(1) dv(4) dv(3) dv(6) dv(5) ...
        little2big_2byte([dv(8) dv(7)])];
    
    count = count + 1;
    if dflag && count == nSectPerRaw
        disp(['data block [sector] = ',num2str(ii)])    % give the user some feed back during this long process
        count = 0;
    end
end

dvec2 = [dvec(:,1:5) dvec(:,6)+ 0.001.*dvec(:,7)];

PARAMS.hrp.dvec = dvec;
PARAMS.hrp.dvec2 = dvec2;

% close FileSystem file
fclose(fid);
% fclose(fod);

if dflag
    figure(555)
    tflag = 1;
    if tflag
        plot(datenum(dvec2))
        hold on
        v = axis;
        rfy = ones(nrawFiles,1) * [v(3) v(4)];
        rfx =  [0:nSectPerRaw:nSectPerRaw*(nrawFiles-1)]' * ones(1,2);
        plot(rfx',rfy','r-')

        datetick('y',13)
        hold off
    else
        plot(dvec(:,6)+ 0.001.*dvec(:,7))
    end
    grid on
    xlabel('Sector #')
    ylabel('Time')
    tstr{1} = filename;
    tstr{2} = ['Sector Time Stamp - buffer write ',num2str(numFile),' - ',num2str(numFile + nrawFiles - 1)];
    title(tstr)
    
    figure(556)
    ddnum = diff(datenum(dvec2)).*(24*60*60);
    plot(ddnum)
    
    xlabel('Sector #')
    ylabel('Time Difference (s)')
    title(['Sector Time Stamp - buffer write ',num2str(numFile),' - ',num2str(numFile + nrawFiles - 1)])
    
end


toc