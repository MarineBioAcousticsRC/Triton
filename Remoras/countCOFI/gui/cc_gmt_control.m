function cc_gmt_control(action)
% made by SGB 20240717
% Shelby G. Bloom (sbloom@ucsd.edu)
% modified/based on Soundscape-Metrics Remora gui folder code by Simone Baumann-Pickering

% Do something in response to GUI window update action:

global REMORA

if strcmp(action, '')

% Change Directory Settings:

elseif strcmp(action,'GPSFilePathSel')
    REMORA.cc.verify.GPSFilePath.String = uigetdir(REMORA.cc.gmt.GPSFilePath,'Select GPS File');
    REMORA.cc.gmt.GPSFilePath = REMORA.cc.verify.GPSFilePath.String;

elseif strcmp(action,'SightingDirSel')
    REMORA.cc.verify.SightingDir.String = uigetdir(REMORA.cc.gmt.SightingDir,'Select Directory with Species Sighting Files');
    REMORA.cc.gmt.SightingDir = REMORA.cc.verify.SightingDir.String;
    
elseif strcmp(action,'OutputDirSel')
    REMORA.cc.verify.OutputDir.String = uigetdir(REMORA.cc.gmt.OutputDir,'Select Directory for Output Plots');
    REMORA.cc.gmt.OutputDir = REMORA.cc.verify.OutputDir.String;

    
% Directory Settings:

elseif strcmp(action,'setGPSFilePath')
    REMORA.cc.gmt.GPSFilePath = get(REMORA.cc.verify.GPSFilePath,'String');
    
elseif strcmp(action,'setSightingDir')
    REMORA.cc.gmt.SightingDir = get(REMORA.cc.verify.SightingDir, 'String');
    
elseif strcmp(action,'setOutputDir')
    REMORA.cc.gmt.OutputDir = get(REMORA.cc.verify.OutputDir,'String');
    
    
% Running Computation:

elseif strcmp(action,'rungmt')
    close(REMORA.fig.cc.gmt)
    cc_gmt_Maps;
    
    
% Loading Settings:

elseif strcmp(action,'cc_gmt_settingsLoad')
    thisPath = mfilename('fullpath');
    settingsPath = fullfile(fileparts(fileparts(thisPath)));
    dialogTitle1 = 'Open GMT Maps Settings File';
    
    [REMORA.cc.gmt.paramFile,REMORA.cc.gmt.paramPath] = ...
        uigetfile(fullfile(settingsPath,'*.m*'),dialogTitle1);
    
    % Give user some feedback
    if isscalar(REMORA.cc.gmt.paramFile)
        return    % User cancelled
    end
    if strfind(REMORA.cc.gmt.paramFile,'.m')
        run(fullfile(REMORA.cc.gmt.paramPath,REMORA.cc.gmt.paramFile));
    else
        warning('Unknown file type detected.')
    end

    cc_gmt_params_window
    
elseif strcmp(action,'cc_gmt_settingsSave')
    thisPath = mfilename('fullpath');
    settingsPath = fullfile(fileparts(fileparts(thisPath)));
    dialogTitle2 = 'Save GMT Maps Settings';
    [REMORA.cc.gmt.paramFileOut,REMORA.cc.gmt.paramPathOut] = ...
        uiputfile(fullfile(settingsPath,'*.m'),dialogTitle2);
    
    % if the cancel button is pushed, then no file is loaded
    % so exit this script
    if 0 == REMORA.cc.gmt.paramFileOut
        return
    end
    
    cc_gmt_create_settings_file
    
else
    warning('Action %s is unspecified.',action)
end
