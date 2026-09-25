function initialize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Initialize the HRP file pulldown
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global HANDLES REMORA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hpver = '260304';

%HRP file operations

REMORA.hrpmenu = uimenu(HANDLES.remmenu,'Label','HARPproc');

str = ['HARPproc Version : ',hpver];

uimenu(REMORA.hrpmenu,'Label',str,'Visible','on');
%%
% HRP file tool subsection:
uimenu(REMORA.hrpmenu,'Label','Get HRP File: ',...
    'Separator','on','Enable','on');
% 'Read Disk HRP file header'
uimenu(REMORA.hrpmenu,'Label','  Disk Header',...
    'Callback','hrppd(''get_HRPhead'')','Enable','on');
% 'Read HRP Disk file directory listing of raw files'
uimenu(REMORA.hrpmenu,'Label','  Directory List',...
    'Callback','hrppd(''get_HRPdir'')','Enable','on');
%%
% check stuff
uimenu(REMORA.hrpmenu,'Label','Evaluate HRP File(s): ',...
    'Separator','on','Enable','on');
% 'Check dirlist times of HRP Disk files'
uimenu(REMORA.hrpmenu,'Label','  Check Directory List Times',...
    'Callback','hrppd(''timecheck'')','Enable','on');
% make spot check plot files from HRP file
uimenu(REMORA.hrpmenu,'Label','  Spot Check',...
    'Callback','hrppd(''make_SpotCheck'')','Enable','on');
%%
% 'Convert HRP disk file to XWAVS'
uimenu(REMORA.hrpmenu,'Label','Process: ',...
    'Separator','on','Enable','on');
% image
uimenu(REMORA.hrpmenu,'Label','  Image Raw Disk to HRP',...
    'Callback','hrppd(''image_HRP'')','Enable','of');
% hrp file to xwav files
uimenu(REMORA.hrpmenu,'Label','  HRP to XWAV',...
    'Callback','hrppd(''process_HRP'')','Enable','on');
%
% make LTSAs from directories of xwavs
uimenu(REMORA.hrpmenu,'Label','  XWAV to LTSA',...
    'Callback','hrppd(''make_ltsa_multidir'')','Enable','on');
%%
% check directory listing times in HRP disk file Header
uimenu(REMORA.hrpmenu,'Label','Misc Tools: ',...
    'Separator','on','Enable','on');

% uimenu(REMORA.hrpmenu,'Label','  Check Directory List Times',...
%     'Callback','hrppd(''ck_dirlist_times'')','Enable','off');
% % plot sector times
% uimenu(REMORA.hrpmenu,'Label','  Plot Sector Times',...
%     'Callback','hrppd(''plotSectorTimes'')','Enable','off');
% generate corrected dirlist times
uimenu(REMORA.hrpmenu, 'Label', '  Fix Directory List Times', ...
    'Callback', 'hrppd(''fixtimes'')', 'Enable', 'on');

uimenu(REMORA.hrpmenu,'Label','  Process/Plot raw IMU data ( batch )',...
    'Callback', 'guProcIMU','Enable','on');

uimenu(REMORA.hrpmenu,'Label','  Plot processed IMU data ( manual )',...
    'Callback','plot_AGM_YPR_260220('''')','Enable','on');



