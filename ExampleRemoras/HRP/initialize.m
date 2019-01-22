function initialize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Initialize the HRP file pulldown
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global HANDLES REMORA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%HRP file operations

REMORA.hrpmenu = uimenu(HANDLES.remmenu,'Label','HRP File');
% 'Convert HRP disk file to XWAVS'
 uimenu(REMORA.hrpmenu,'Label','Convert Multiple HRP Files to XWAV Files',...
     'Callback','hrppd(''convert_multiHRP2XWAVS'')','Enable','off');
 uimenu(REMORA.hrpmenu,'Label','Convert HRP File to XWAV Files',...
     'Callback','hrppd(''convert_HRP2XWAVS'')','Enable','on');
% % 'Read Disk HRP file header'
 uimenu(REMORA.hrpmenu,'Label','Get HRP File Disk Header',...
     'Callback','hrppd(''get_HRPhead'')','Enable','on');
% % 'Read HRP Disk file directory listing of raw files'
uimenu(REMORA.hrpmenu,'Label','Get HRP File Directory List',...
    'Enable','on','Callback','hrppd(''get_HRPdir'')','Enable','on');
% check directory listing times in HRP disk file Header
uimenu(REMORA.hrpmenu,'Label','Check Directory List Times',...
    'Enable','on','Callback','hrppd(''ck_dirlist_times'')','Enable','on');
% plot sector times
uimenu(REMORA.hrpmenu,'Label','Plot Sector Times',...
    'Enable','on','Callback','hrppd(''plotSectorTimes'')','Enable','on');

