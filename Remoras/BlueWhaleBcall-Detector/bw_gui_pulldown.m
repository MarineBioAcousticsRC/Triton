function bw_gui_pulldown(action)

global REMORA

thisPath = mfilename('fullpath');
settingsPath = fullfile(fileparts(fileparts(thisPath)),...
        'settings');

   
    % get settings from selected settings file 
    dialogTitle = 'Choose detector settings file';
    settingsFile = uigetfile(fullfile(settingsPath,'*.m'),dialogTitle);
    run(settingsFile)
    
    % set new settings in motion gui
    REMORA.bw.settings = settings;
    bw_init_batch_gui
    bw_settings_to_sec 
end

function update_window_settings
global HANDLES REMORA
set(HANDLES.ltsa.time.edtxt3,'string',REMORA.bw.settings.durWind)
set(HANDLES.ltsa.time.edtxt4,'string',REMORA.bw.settings.slide)
control_ltsa('newtseg') %change Triton plot length
control_ltsa('newtstep') %change Triton time step 
% bring motion gui to front
figure(REMORA.fig.bw.motion);