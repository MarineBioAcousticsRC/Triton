function sp_ui_select_detector_settings

global REMORA

if ~isfield(REMORA.spice_dt,'detParams')
    settings_detector_xwav_default
    REMORA.spice_dt.detParams = detParams;
end
hFigure = figure('Position',[560,528,200,200],...
    'NumberTitle','off','Name','Spice Detector Batch Run - v1.0');
clf
set(hFigure, 'MenuBar', 'none');
set(hFigure, 'ToolBar', 'none');

t1 = uicontrol('Style','text',...
    'String','Select detector settings source:',...
    'Position',[10 150 180 30],...
    'HandleVisibility','on',...
    'FontSize',10);

bg = uibuttongroup('Visible','on',...
    'Position',[0 0 1 .70],...
    'SelectionChangeFcn',@bselection);

b1 = uicontrol(bg,'Style','pushbutton',...
    'String','Load from file',...
    'Position',[10 100 180 30],...
    'HandleVisibility','off',...
    'Callback',{@ui_load_params_from_mfile,hFigure});


b2 = uicontrol(bg,'Style','pushbutton',...
    'String','Use current (interactive) settings',...
    'Position',[10 50 180 30],...
    'HandleVisibility','off',...
    'Callback',{@sp_ui_check_detParams,hFigure});
% need to add callback here

bg.Visible = 'on';


end

function ui_load_params_from_mfile(hObject,eventdata,hFigure)
global REMORA

dialogTitle = 'Choose detector settings file';

thisPath = mfilename('fullpath');

detParamsFile = uigetfile(fullfile(fileparts(fileparts(thisPath)),...
    'settings\*.m*'),dialogTitle);
detParams = [];
[~,~,ext] = fileparts(detParamsFile);
if strcmp(ext,'.mat')
    load(detParamsFile)
elseif strcmp(ext,'.m')
    run(detParamsFile)
else
    error('Unrecognized input file type')
end
% merge imported params with existing params
if isfield(REMORA.spice_dt,'detParams')
    detParams = sp_merge_detParams(detParams,REMORA.spice_dt.detParams);
end
REMORA.spice_dt.detParams = detParams;
%close(hFigure)
sp_ui_check_detParams([],[],hFigure)
end