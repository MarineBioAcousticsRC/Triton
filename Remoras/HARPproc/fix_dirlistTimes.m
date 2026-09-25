function fix_dirlistTimes
%
% fix_dirlistTimes.m
%
% useage: >>fix_dirlistTimes
% for now: choose fix, set display flag, and disk number. 
% will either use currently loaded hrp file (if have previously loaded in
% header and dir list), or will prompt for you to choose a file if no
% metadata detected. 
%
% modified for triton HRP Remora use 1706222 fairlie reese
%
% based on mod_xwavhdrTime.m 091125 smw
%
%
% 100528 smw
%

global PARAMS

ckFirmware  % at lease to get number of channels

% structure PARAMS.proc is not used in HARPproc

PARAMS.proc.bwFix = [true, false]; % TODO turn this into user input

% do we already have everything we need?
if ~isfield(PARAMS, 'fromProc')
%     filename = fullfile(REMORA.hrp.path, PARAMS.proc.currHRP);
% else
    PARAMS.proc.bwFix = [true, false]; % TODO turn this into user input
    PARAMS.dflag = 0;
    
    % choose and load in file
    [fname,fpath]=uigetfile('*.hrp','Select HRP file');
    filename = [fpath,fname];
    
    % if the cancel button is pushed, then no file is loaded so exit this script
    if strcmp(num2str(fname),'0')
        return
    else
        % only need to call this when calling it on its own; calls
        % read_rawHARPhead as well so don't need that extra call
        if isfield(PARAMS, 'head')
            PARAMS = rmfield(PARAMS, 'head');
        end
        read_rawHARPdir(filename,PARAMS.dflag)
    end
end

% hide output?
d = PARAMS.dflag;
d = 1;  % why not show it all, at least for debugging...

% get raw HARP disk header and dir list
% todo: if all the following calls do is create global variables, then I
% don't need to call them if coming from procFun because I already called
% them in procFun
% read_rawHARPhead(filename,d) % todo: does this need to be called? Already called in read_rawHARPdir...

% grab the disk number from the file location
disk = PARAMS.head.fileloc(end-5:end-4); % todo would like to make this into a global

[path, fname, c] = fileparts(PARAMS.head.fileloc);

disp(['Checking for non-sequential times in disk ', fname, c])

% keep count of total number of times modified
chT = 0;
ch = 0;

% raw file start times in days
% y = PARAMS.raw.dnumStart;
y = datenum([PARAMS.head.dirlist(:,2) PARAMS.head.dirlist(:,3)...
    PARAMS.head.dirlist(:,4) PARAMS.head.dirlist(:,5) PARAMS.head.dirlist(:,6) ...
    PARAMS.head.dirlist(:,7)+(PARAMS.head.dirlist(:,8)/1000)]);

% differenced time in seconds
dy = 24*60*60*diff(y);

% find times later than next raw file
% use two different ways of checking for bad times in case of more than one
% bw in a row... would be better to have code loop around if one time is
% changed and re-check the time just prior...
I = [];

% find bad milliseconds suggests minor BWA type 1
if PARAMS.nch == 1
    mserr = 920;
elseif PARAMS.nch == 4
    mserr = 632;
else
    disp(['Error: not supported PARAMS.nch = ',num2str(PARAMS.nch)])
end


if PARAMS.proc.bwFix(1) && PARAMS.proc.bwFix(2) 
    disp('At this time both fixes cannot be done at the same time. Tell Hannah to work on it.')
%     I = find(dy < 0 || PARAMS.xhd.ticks == 920);
elseif PARAMS.proc.bwFix(1) == 1
    I = find(PARAMS.head.dirlist(:,8) == mserr);
elseif PARAMS.proc.bwFix(2) == 1
    I = find(dy < 0);
end

%preallocate
modhdrs = zeros(length(I),16);
saveFile = sprintf('%s_disk%s_modifiedDirlistTimes.mat', fname(1:end-7), disk);
saveFile = fullfile(path, saveFile);

Ilen = length(I);
if ~isempty(I)
%     if size(PARAMS.diskVec,1) > 1
%         firstdisk = PARAMS.diskVec(1,:);
%         lastdisk = PARAMS.diskVec(end,:);
%         newMatFile = ([PARAMS.drive.hrp1 PARAMS.dataID '_disks' firstdisk '-' lastdisk '_modifiedDirlistTimes.mat']);
%     else
%         newMatFile = ([PARAMS.drive.hrp1 PARAMS.dataID '_disk' disk '_modifiedDirlistTimes.mat']);
%     end
     
    if d
        disp([num2str(Ilen),' Raw File Times Later than Next'])
%         disp(num2str(datevec(y(I))))
%         disp(num2str(dy(I)'))
    end
    
    % calculate modified times - code modified by hrb in order to track changes
    for Ival = 1:Ilen
        rfn = I(Ival);  %rfn = raw file number

        if rfn == PARAMS.head.nextFile % may need to be nextFile - 1
            disp('Last raw file on disk. Header time not changed.')
            disp('       ')
            % remove row of zeroes on the end
            modhdrs = modhdrs(1:end-1, :);
        else
            % Get original hdr time of raw file
            ydv = datevec(y); % put old time in date vector
            ydv(:,7) = floor(1000*(ydv(:,6) - floor(ydv(:,6)))); % msec
            ydv(:,6) = floor(ydv(:,6)); % integer seconds

            % Display and save raw file number and old time
            if d
                disp(['Raw file ' num2str(rfn)])
                disp(['Old time: ' num2str(ydv(rfn,:))])
            end

            modhdrs(ch+1,1) = str2double(disk); % disk number
            modhdrs(ch+1,2) = rfn; % raw file number
            modhdrs(ch+1,3) = ydv(rfn,1);  % year
            modhdrs(ch+1,4) = ydv(rfn,2);  % month
            modhdrs(ch+1,5) = ydv(rfn,3);  % day
            modhdrs(ch+1,6) = ydv(rfn,4);  % hour
            modhdrs(ch+1,7) = ydv(rfn,5);  % minute
            modhdrs(ch+1,8) = ydv(rfn,6);  % second
            modhdrs(ch+1,9) = ydv(rfn,7);  % millisecond

            % Modify time
            if PARAMS.nch == 1
                modtime =  datenum([0 0 0 0 0 81.92]);
            elseif PARAMS.nch == 4
                modtime =  datenum([0 0 0 0 0 40.632]);
            else
                    disp(['Error: not supported PARAMS.nch = ',num2str(PARAMS.nch)])
            end
            y(rfn) = y(rfn) - modtime;

            % Get new hdr time
            ydv = datevec(y); % put in date vector
            ydv(:,7) = floor(1000*(ydv(:,6) - floor(ydv(:,6)))); % msec
            ydv(:,6) = floor(ydv(:,6)); % integer seconds
            % 
            % Correct for rounding leaving 1000 msec... could fix, but may
            % have ripple effect to sec...
%             if ydv(:,7) == 1000
%                 ydv(:,7) = 0;
%                 ydv(:,6)= ydv(:,6) + 1;
%             end

            %Display and save new hdr time
            if d
                disp(['New time: ' num2str(ydv(rfn,:))])
            end

            modhdrs(ch+1,10) = ydv(rfn,1); % year
            modhdrs(ch+1,11) = ydv(rfn,2); % month
            modhdrs(ch+1,12) = ydv(rfn,3);  % day
            modhdrs(ch+1,13) = ydv(rfn,4); % hour
            modhdrs(ch+1,14) = ydv(rfn,5);  % minute
            modhdrs(ch+1,15) = ydv(rfn,6);   % second
            modhdrs(ch+1,16) = ydv(rfn,7);   % millisecond

            % modify dirlist time
            PARAMS.head.dirlist(rfn,2:8) = ydv(rfn,1:7);
%             PARAMS.head.dirlist_fixed = PARAMS.head.dirlist;

            % keep count of times changed
            chT = chT + 1;
            ch = ch + 1;
        end
    end
else
    modhdrs=[];
    if d
        disp('No Raw File Times Later than Next')
    end
end

disp(['Save modified header mat-file: ',saveFile])

if exist(saveFile,'file')
    save(saveFile,'modhdrs','-append');
else
    save(saveFile,'modhdrs');
end



