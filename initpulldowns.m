function initpulldowns
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% initpulldowns.m
%
% generate figure pulldown menus
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global HANDLES PARAMS

% 'File' pulldown
HANDLES.filemenu = uimenu(HANDLES.fig.ctrl,'Label','&File');
%
uimenu(HANDLES.filemenu,'Label','&Open LTSA File','Callback','filepd(''openltsa'')');
uimenu(HANDLES.filemenu,'Label','Open &XWAV File','Callback','filepd(''openxwav'')');
uimenu(HANDLES.filemenu,'Label','Open &WAV File','Callback','filepd(''openwav'')');
%
HANDLES.exportdata = uimenu(HANDLES.filemenu, 'Separator','on','Label',...
    '&Export Plotted Data To','Enable','off');
%
uimenu(HANDLES.exportdata,'Label','&normalized WAV File',...
    'Callback','filepd(''export_normwav'')');
uimenu(HANDLES.exportdata,'Label','&WAV File',...
    'Callback','filepd(''export_wav'')');
uimenu(HANDLES.exportdata,'Label','&XWAV File',...
    'Callback','filepd(''export_xwav'')');
uimenu(HANDLES.exportdata, 'Label', '&MATLAB File *.mat',...
    'Callback', 'miscpd(''export_mat'')');
%
HANDLES.savefig = uimenu(HANDLES.filemenu,'Label',...
    'Save Plot Window As','Enable','off');
uimenu(HANDLES.savefig,'Label','&JPEG File',...
    'Callback','filepd(''savejpg'')');
%
uimenu(HANDLES.savefig,'Label','&PDF File',...
    'Callback','filepd(''savepdf'')');
%
uimenu(HANDLES.savefig,...
    'Label','MATLAB File *.fig',...
    'Callback','filepd(''savefigureas'')');

%
HANDLES.exportparams = uimenu(HANDLES.filemenu, 'Label', '&Export PARAMS as MATLAB File *.mat',...
    'Callback', 'miscpd(''export_params'')');

HANDLES.saveimageas = uimenu(HANDLES.filemenu,'Label','Save Spectrogram As &Image',...
    'Visible','off',...
    'Enable','off','Callback','filepd(''saveimageas'')');

uimenu(HANDLES.filemenu,'Separator','on','Label','E&xit',...
    'Callback','filepd(''exit'')');

%Settings pulldown
HANDLES.setmenu = uimenu(HANDLES.fig.ctrl, 'Label', '&Settings');
uimenu(HANDLES.setmenu, 'Label', '&Save Current Window Positions',...
    'Callback', 'miscpd(''save_settings'')');
uimenu(HANDLES.setmenu, 'Label', '&Load Window Positions',...
    'Callback', 'miscpd(''load_settings'')');
uimenu(HANDLES.setmenu, 'Label', '&Set Current Window Positions for Startup',...
    'Callback', 'miscpd(''set_startup'')');
uimenu(HANDLES.setmenu, 'Label', '&Load Triton Default Window Positions',...
    'Callback', 'miscpd(''default_windows'')');
uimenu(HANDLES.setmenu,'Separator','on','Label', '&Save, Load, or Change Plot Parameters',...
    'Callback', 'miscpd(''plot_params'')');
uimenu(HANDLES.setmenu,'Label', '&Set Default Parameters',...
    'Callback', 'miscpd(''default_params'')');

% 'Tools' Pulldown
HANDLES.toolmenu = uimenu(HANDLES.fig.ctrl,'Label','&Tools',...
    'Enable','on');
uimenu(HANDLES.toolmenu,'Separator','on','Label','&Convert Single HARP Raw File to XWAV',...
    'Callback','toolpd(''convertfile'')');

uimenu(HANDLES.toolmenu,'Label','Load Transfer Function File',...
    'Enable','on','Callback','toolpd(''loadTF'')');

% Decimate ops
HANDLES.decimenu = uimenu(HANDLES.toolmenu,'Label','Decimate XWAV/WAV Files');
uimenu(HANDLES.decimenu,'Label','&Decimate Single XWAV File',...
    'Enable','on','Callback','toolpd(''decimatefile'')');
uimenu(HANDLES.decimenu,'Label','&Decimate All XWAV Files in Directory',...
    'Enable','on','Callback','toolpd(''decimatefiledir'')');
uimenu(HANDLES.decimenu,'Separator','on','Label','&Decimate Single WAV File',...
    'Enable','on','Callback','toolpd(''decimatewavfile'')');
uimenu(HANDLES.decimenu,'Label','&Decimate All WAV Files in Directory',...
    'Enable','on','Callback','toolpd(''decimatewavfiledir'')');

uimenu(HANDLES.toolmenu,'Label','&Make LTSA from Directory of Files',...
    'Enable','on','Callback','toolpd(''mkltsa'')');

if ~isdeployed  % don't initilalize remora pull down if compiled
    % 'Remora' Pulldown
    HANDLES.remmenu = uimenu(HANDLES.fig.ctrl,'Label','&Remoras','Enable','on');
    uimenu(HANDLES.remmenu,'Separator','on','Label','&Add Remora',...
        'Enable','on','Callback','remorapd(''add_remora'')');
    HANDLES.removerems = uimenu(HANDLES.remmenu,'Label','&Remove Remora',...
        'Enable','off','Callback','remorapd(''rem_remora'')');
    % HANDLES.listrems = uimenu(HANDLES.remmenu, 'Label', '&List Installed Remoras',...
    %     'Enable', 'off','Callback', 'toolpd(''list_remoras'')');
    %   TritonPath = fileparts(which('triton'));
    %   RemoraConfFile = fullfile(TritonPath, 'Settings',...
    %     'InstalledRemoras.cnf');
    RemoraConfFile = fullfile(PARAMS.path.Settings,'InstalledRemoras.cnf');
    fid = fopen(RemoraConfFile);
    fseek(fid, 0, 'bof');
    beginningpos = ftell(fid);
    fseek(fid, 0, 'eof');
    endpos = ftell(fid);
    fclose(fid);
    if beginningpos ~= endpos
        set(HANDLES.removerems,'Enable','On')
        %     set(HANDLES.listrems, 'Enable', 'On')
    end
    
end
% 'Help' pulldown
HANDLES.helpmenu = uimenu(HANDLES.fig.ctrl,'Label','&Help',...
    'Enable','on');
uimenu(HANDLES.helpmenu,'Label','&About Triton',...
    'Callback','miscpd(''dispAbout'')');
uimenu(HANDLES.helpmenu, 'Label','&Triton User Manual',...
    'Callback','open_TritonManual');


% Message window pulldown
HANDLES.msgmenu = uimenu(HANDLES.fig.msg,'Label','&File');
HANDLES.openpicks = uimenu(HANDLES.msgmenu,'Separator','off','Label','&Open Picks',...
    'Enable','on','Visible','on','Callback','filepd(''openpicks'')');
HANDLES.savepicks = uimenu(HANDLES.msgmenu,'Separator','off','Label','Save &Picks',...
    'Enable','off','Callback','filepd(''savepicks'')');
HANDLES.savemsgs = uimenu(HANDLES.msgmenu,'Separator','on','Label','Save &Messages',...
    'Enable','on','Callback','filepd(''savemsgs'')');
HANDLES.clrmsgs = uimenu(HANDLES.msgmenu,'Separator','off','Label','Clear Messages',...
    'Enable','on','Callback','filepd(''clrmsgs'')');


% some window stuff?
set(gcf,'Units','pixels');
axis off
% axHndl1=gca;

if ~isdeployed   % standard in MATLAB mode
    % Read contents of InstalledRemoras.cnf and initialize those that are
    % installed
    oldDir = pwd;
    % tritonDir = fileparts(which('triton'));
    % settingDir = fullfile(tritonDir,'Settings');
    % cnf_file = fullfile(settingDir,'InstalledRemoras.cnf');
    cnf_file = fullfile(PARAMS.path.Settings,'InstalledRemoras.cnf');
    % cd(tritonDir)
    % cd(PARAMS.path.Triton)
    %goes to Remora directory
    % if exist('Remora', 'dir')
    if exist(PARAMS.path.Remoras, 'dir')
        %   dirs = dir('Remora');
        %   cd Remora;
        cd(PARAMS.path.Remoras)
        fid = fopen(cnf_file, 'r+');
        remorapath = fgetl(fid);
        pwd0 = pwd;
        if ~isempty(remorapath)
            while ischar(remorapath)
                remora_init = fullfile(remorapath,'initialize');
                if exist(remora_init) ~= 2
                    disp_msg(sprintf('File %s does not exist, or missing from matlab''s path', ...
                        remora_init));
                else
                    cd(remorapath);
                    eval('initialize');
                end
                remorapath = fgetl(fid);
            end
        end
        fclose(fid);
        cd(pwd0)
    else
        disp_msg('Remoras folder not found, restart Triton!')
        return
    end
    
    if exist(oldDir,'dir')
        cd(oldDir)
    else
        %   cd(tritonDir)
        cd(PARAMS.path.Triton)
    end
end