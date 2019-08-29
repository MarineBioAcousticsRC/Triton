function sh_motion_pulldown(action)

global REMORA

thisPath = mfilename('fullpath');
settingsPath = fullfile(fileparts(fileparts(thisPath)),...
        'settings');

if strcmp(action,'settingsLoad')
    settings = [];
    
    % get settings from selected settings file 
    dialogTitle = 'Choose detector settings file';
    settingsFile = uigetfile(fullfile(settingsPath,'*.m'),dialogTitle);
    run(settingsFile)
    
    % set new settings in motion gui
    REMORA.sh.settings = settings;
    sh_init_motion_gui
    sh_settings_to_sec
    
    % run detector on current window
    sh_detector_motion
    
elseif strcmp(action,'settingsSave')
    
    % get path to save settings file 
    dialogTitle2 = 'Select directory to save detector settings file';
    [fileName,filePath] = uiputfile('*.m',dialogTitle2,...
        fullfile(settingsPath,'settings_ship_detector_test.m'));
    
    % if the cancel button is pushed, then no file is loaded
    % so exit this script
    if 0 == fileName
        return
    end
    
    sh_create_settings_file(REMORA.sh.settings,fileName,filePath)
    
    
    
    
    
end