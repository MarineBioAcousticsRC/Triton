function sh_load_settings(method)

hFigure = figure('Position',[760,500,200,200],...
    'NumberTitle','off','Name','Spice Detector Batch Run - v1.0');
clf
set(hFigure, 'MenuBar', 'none');
set(hFigure, 'ToolBar', 'none');

uicontrol('Style','text',...
    'String','Select detector settings source:',...
    'Position',[10 150 180 30],...
    'HandleVisibility','on',...
    'FontSize',10);

bg = uibuttongroup('Visible','on',...
    'Position',[0 0 1 .70],...
    'SelectionChangeFcn',@bselection);

uicontrol(bg,'Style','pushbutton',...
    'String','Load from file',...
    'Position',[10 100 180 30],...
    'HandleVisibility','off',...
    'Callback',{@ui_load_settings_from_mfile,hFigure,method});


uicontrol(bg,'Style','pushbutton',...
    'String','Use current (interactive) settings',...
    'Position',[10 50 180 30],...
    'HandleVisibility','off',...
    'Enable','off',...
    'Callback',{@ui_check_settings,hFigure});
% need to add callback here

bg.Visible = 'on';
end

function ui_load_settings_from_mfile(hObject,eventdata,hFigure,method)

dialogTitle = 'Choose detector settings file';

thisPath = mfilename('fullpath');

settingsFile = uigetfile(fullfile(fileparts(fileparts(thisPath)),...
    'settings\*.m'),dialogTitle);
settings = [];
run(settingsFile)
global REMORA
REMORA.sh.settings = settings;
close(hFigure)

% open gui window settings 
if strcmp(method,'batch')
    sh_init_batch_gui
    settings_in_seconds
    sh_settings_to_sec
end

end
