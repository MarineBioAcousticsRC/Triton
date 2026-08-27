% TimeCheck_dirlist.m
% script, may become a function
%
% get the dirlist (RF) times from one or a group of *.hrp file(s).
% files can be *.head.hrp or full raw disk images.
%
% add into HARPproc Remora starting at 220930
%
% 220916 smw
%
global PARAMS


%% get/set:
% hrp and output directory
% number of hrp files
% data ID string
% disk number
%
% if ~exist(hpath,'dir')
hpath=uigetdir('*.hrp','Select HRP directory for Dirlist Time Check');
if ~hpath
    disp('Canceled select HRP directory for Dirlist Time Check')
    return
end
% end
hrpdir = hpath;

% number of hrp files
hf = dir(fullfile(hrpdir,'*.hrp'));
nhf = size(hf,1);

% data ID string and disk number vector
diskVecstr = '';
for k = 1:nhf
    fn = char(hf(k).name);
    [sI,eI] = regexp(fn,'_disk');
    if k == 1
        dataID = fn(1:sI-1);
    end
    diskVecstr = [diskVecstr,' ',num2str(str2num(fn(eI+1:eI+2)))];
end

%% let user change settings/parameters
%
outdir = fullfile(hpath,[dataID,'_timeCheck']);

sampleRate = 200;
interval = 0;
duration = 0;

% default settings
dinfo{1} = hrpdir;
dinfo{2} = dataID;
dinfo{3} = diskVecstr;
dinfo{4} = num2str(sampleRate);
dinfo{5} = num2str(interval);
dinfo{6} = num2str(duration);
dinfo{7} = outdir;

prompt = {'HRP file Directory: ';...
    'Data file ID name: ';...
    'Disk Number Vector: ';...
    'Sample Rate (kHz): ';...
    'Duty-cycle Interval: ';...
    'Duty-cycle Duration: ';...
    'TimeCheck Output file Directory: '};

title = 'Time Check Parameters';

info = inputdlg(prompt, title, [1 50], dinfo);

% if input dialog box closed
if isempty(info); return; end;

% it would be good to check info{} for validity

hrpdir = info{1};
dataID = info{2};
diskVecstr = info{3};
diskVec = str2num(diskVecstr);
sampleRate = str2num(info{4});
interval = str2num(info{5});
duration = str2num(info{6});
outdir = info{7};

disp(' ')
disp('Time Check hrp files dirlists')
disp(' ')
disp(['hrp file directory : ', hrpdir])
disp(['dataID : ', dataID])
disp(['disk(s) : ', diskVecstr])
disp(['sampleRate : ', num2str(sampleRate) , ' kHz'])
disp(['interval : ',num2str(interval),' (min) ;    duration : ', num2str(duration),' (min)'])
disp(['output directory : ',outdir])


%% PARAMS needed for difftime_dirlist
PARAMS.rec.sr = sampleRate;  % the code should be able to figure this out from the disk header, but what if it was intialize at a different sample rate
PARAMS.rec.int = interval;
PARAMS.rec.dur = duration;

%%
% check/make output directory

if ~exist(outdir,'dir')
    fprintf('Making root output directory %s\n',outdir);
    mkdir(outdir);
end

disp(' ')

% diary
outlog = sprintf('%s_timeCheck_d%02d-%02d.txt',...
    dataID, diskVec(1), diskVec(end));

dfn = fullfile(outdir,outlog);
diary(dfn);
fprintf('Diary file: %s\n',dfn);

fprintf('Current datetime: %s\n', datestr(now,'mm/dd/yyyy HH:MM:SS'));
fprintf('Time Check Code: %s\n\n',mfilename('fullpath'));


%%  output from the dirlist TimeCheck will go to the Triton Message Window
% which is saved after TimeCheck
%
%clear messages
lStr(1) = {['Triton ',PARAMS.ver]};
lStr(2) = {'messages displayed here' };
set(HANDLES.msg,'String',lStr,'Value',2);

%% loop over each hrp file:
%  difftime_dirlist = take first difference of dirlist times
%               if any time errors, report
%  mk_headSummary = fill up PARAMS.headall raw disk info
%  disp_headSummary = Show results of timing evaluation and errors


%user feedback
disp(['Acquiring dirlist time check summary for ' dataID])

ndV = length(diskVec);
% get the summary
for k = 1:ndV
%         disp(['Disk ' PARAMS.diskVec(k,:)])
    %     difftime_dirlist(fullfile(PARAMS.inpath,fn(k,:)),0);
%     hrpfile = sprintf('%s_disk%02d.hrp',dataID, diskVec(k));
    hrpfile = char(hf(k).name);
    fn = fullfile(hrpdir,hrpfile);
    fprintf('%s\n',fn);
    difftime_dirlist(fn,0);
    if k == 1
        disp(['rawfile duration = ', num2str(PARAMS.rec.dtime1),' (s)'])
        disp(['duration between duty-cycle starts = ', num2str(PARAMS.rec.dtime2),' (s)'])
    end
    mk_headSummary(k);
end
disp_headSummary(ndV);

%user feedback
disp(['Acquiring individual disk dirlist time check for ' dataID])

% get the individual disk time and sector checks
for k = 1:ndV
    %     disp(['Disk ' PARAMS.diskVec(k,:)])
    % difftime_dirlist(fullfile(PARAMS.inpath,fn(k,:)),2);
%     hrpfile = sprintf('%s_disk%02d.hrp',dataID, diskVec(k));
    hrpfile = char(hf(k).name);
    fn = fullfile(hrpdir,hrpfile);
    fprintf('%s\n',fn);
    difftime_dirlist(fn,2);
end

%% get the Text from the Triton Message Window and save to output file
% save the summary to an ascii file
% timeck = [PARAMS.drive.hrp1 PARAMS.dataID '_timeck.txt'];
ofn = sprintf('%s_timeck.txt',dataID);
timeck = fullfile(outdir,ofn);
disp('   ')
disp(['Time Check Message File: ' timeck])

msgs = char(get(HANDLES.msg,'String'));
[mr,mc] = size(msgs);
fid = fopen(timeck,'w');
for k = 1:mr
    fprintf(fid,'%s\r\n',msgs(k,:));
end
fclose(fid);
open(timeck);

disp('Done')
diary('off')




