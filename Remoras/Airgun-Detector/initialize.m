global REMORA HANDLES

% Initialization script for the airgun detector:

REMORA.agDetect.menu = uimenu(HANDLES.remmenu,'Label','&Airgun Detector',...
    'Enable','on','Visible','on');

% Run airgun detector:

uimenu(REMORA.agDetect.menu, 'Label', 'Run Airgun Detector', ...
    'Callback', 'ag_detect_pulldown');
