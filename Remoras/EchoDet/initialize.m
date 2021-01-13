global REMORA HANDLES

% initialization script for label tracking remora

REMORA.ec.menu = uimenu(HANDLES.remmenu,'Label','&EchoDet',...
    'Enable','on','Visible','on');

%run echosounder detector
uimenu(REMORA.ec.menu, 'Label', 'Run Echosounder Detector',...
    'Callback','ec_pulldown(''create_echoDet'')');
% create ID file
uimenu(REMORA.ec.menu, 'Label', 'Create ID File per Folder', ...
    'Callback', 'ec_pulldown(''create_IDfiles'')');



if ~isfield(REMORA,'fig')
    REMORA.fig = [];
end