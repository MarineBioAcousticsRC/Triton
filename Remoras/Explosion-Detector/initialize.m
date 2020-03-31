global REMORA HANDLES

% Initialization script for the explosion detector:

REMORA.exDetect.menu = uimenu(HANDLES.remmenu,'Label','&Explosion Detector',...
    'Enable','on','Visible','on');

% Run explosion detector:

uimenu(REMORA.exDetect.menu, 'Label', 'Run Explosion Detector', ...
    'Callback', 'ex_detect_pulldown');
