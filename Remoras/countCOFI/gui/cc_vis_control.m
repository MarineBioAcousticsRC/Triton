function cc_vis_control(action)
% made by SGB 20240717
% Shelby G. Bloom (sbloom@ucsd.edu)
% modified/based on Soundscape-Metrics Remora gui folder code by Simone Baumann-Pickering

% Do something in response to GUI window update action:

global REMORA

if strcmp(action, '')

% Change Directory Settings:

elseif strcmp(action,'GPSFilePathSel')
    REMORA.cc.verify.GPSFilePath.String = uigetdir(REMORA.cc.vis.GPSFilePath,'Select GPS File');
    REMORA.cc.vis.GPSFilePath = REMORA.cc.verify.GPSFilePath.String;

elseif strcmp(action,'effFilePathSel')
    REMORA.cc.verify.effFilePath.String = uigetdir(REMORA.cc.vis.effFilePath,'Select Concatenated Daily Expanded File Path');
    REMORA.cc.vis.effFilePath = REMORA.cc.verify.effFilePath.String;

elseif strcmp(action,'oDirSel')
    REMORA.cc.verify.oDir.String = uigetdir(REMORA.cc.vis.oDir,'Select Directory for visEffort Outputs');
    REMORA.cc.vis.oDir = REMORA.cc.verify.oDir.String;

    
% Directory Settings:

elseif strcmp(action,'setGPSFilePath')
    REMORA.cc.vis.GPSFilePath = get(REMORA.cc.verify.GPSFilePath,'String');

elseif strcmp(action,'seteffFilePath')
    REMORA.cc.vis.effFilePath = get(REMORA.cc.verify.effFilePath,'String');
    
elseif strcmp(action,'setoDir')
    REMORA.cc.vis.oDir = get(REMORA.cc.verify.oDir, 'String');
    
    
% Running Computation:

elseif strcmp(action,'runvis')
    close(REMORA.fig.cc.vis)
    cc_vis_Effort;
    
    
% Loading Settings:

elseif strcmp(action,'cc_vis_settingsLoad')
    thisPath = mfilename('fullpath');
    settingsPath = fullfile(fileparts(fileparts(thisPath)));
    dialogTitle1 = 'Open visEffort Settings File';
    
    [REMORA.cc.vis.paramFile,REMORA.cc.vis.paramPath] = ...
        uigetfile(fullfile(settingsPath,'*.m*'),dialogTitle1);
    
    % Give user some feedback
    if isscalar(REMORA.cc.vis.paramFile)
        return    % User cancelled
    end
    if strfind(REMORA.cc.vis.paramFile,'.m')
        run(fullfile(REMORA.cc.vis.paramPath,REMORA.cc.vis.paramFile));
    else
        warning('Unknown file type detected.')
    end

    cc_vis_params_window
    
elseif strcmp(action,'cc_vis_settingsSave')
    thisPath = mfilename('fullpath');
    settingsPath = fullfile(fileparts(fileparts(thisPath)));
    dialogTitle2 = 'Save visEffort Settings';
    [REMORA.cc.vis.paramFileOut,REMORA.cc.vis.paramPathOut] = ...
        uiputfile(fullfile(settingsPath,'*.m'),dialogTitle2);
    
    % if the cancel button is pushed, then no file is loaded
    % so exit this script
    if 0 == REMORA.cc.vis.paramFileOut
        return
    end
    
    cc_vis_create_settings_file
    
else
    warning('Action %s is unspecified.',action)
end
