function dt_runFullDetector()

global REMORA

% Load settings or use current settings
ui_select_detector_settings;


detParams = REMORA.spice_dt.detParams;

% Fill in folders, transfer function info


% Call spice detector 
spice_detector(detParams);