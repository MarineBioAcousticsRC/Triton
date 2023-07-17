function bp_gui_pulldown(action)

global REMORA

thisPath = mfilename('fullpath');
settingsPath = fullfile(fileparts(fileparts(thisPath)),...
        'settings');

   
    % get settings from selected settings file 
    dialogTitle = 'Choose detector settings file';
    settingsFile = uigetfile(fullfile(settingsPath,'*.m'),dialogTitle);
    run(settingsFile)
    
    % set new settings in motion gui
    REMORA.bp.settings = settings;
    bp_init_batch_gui
end
