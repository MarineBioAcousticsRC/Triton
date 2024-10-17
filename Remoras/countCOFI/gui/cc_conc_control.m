function cc_conc_control(action)
% made by SGB 20240717
% Shelby G. Bloom (sbloom@ucsd.edu)
% modified/based on Soundscape-Metrics Remora gui folder code by Simone Baumann-Pickering

% Do something in response to GUI window update action:

global REMORA

if strcmp(action, '')

% Change Directory Settings:

elseif strcmp(action,'indirSel')
    REMORA.cc.verify.indir.String = uigetdir(REMORA.cc.conc.indir,'Select Directory With Daily Expanded Files');
    REMORA.cc.conc.indir = REMORA.cc.verify.indir.String;

elseif strcmp(action,'outdirSel')
    REMORA.cc.verify.outdir.String = uigetdir(REMORA.cc.conc.outdir,'Select Directory for Concantenated File');
    REMORA.cc.conc.outdir = REMORA.cc.verify.outdir.String;

    
% Directory Settings:

elseif strcmp(action,'setindir')
    REMORA.cc.conc.indir = get(REMORA.cc.verify.indir,'String');
    
elseif strcmp(action,'setoutdir')
    REMORA.cc.conc.outdir = get(REMORA.cc.verify.outdir, 'String');
       
% Running Computation:

elseif strcmp(action,'runconc')
    close(REMORA.fig.cc.conc)
    cc_conc_concatenate;
    
% Loading Settings:

elseif strcmp(action,'cc_conc_settingsLoad')
    thisPath = mfilename('fullpath');
    settingsPath = fullfile(fileparts(fileparts(thisPath)));
    dialogTitle1 = 'Open Concatenate Daily Expanded Files Settings File';
    
    [REMORA.cc.conc.paramFile,REMORA.cc.conc.paramPath] = ...
        uigetfile(fullfile(settingsPath,'*.m*'),dialogTitle1);
    
    % Give user some feedback
    if isscalar(REMORA.cc.conc.paramFile)
        return    % User cancelled
    end
    if strfind(REMORA.cc.conc.paramFile,'.m')
        run(fullfile(REMORA.cc.conc.paramPath,REMORA.cc.conc.paramFile));
    else
        warning('Unknown file type detected.')
    end

    cc_conc_params_window
    
elseif strcmp(action,'cc_conc_settingsSave')
    thisPath = mfilename('fullpath');
    settingsPath = fullfile(fileparts(fileparts(thisPath)));
    dialogTitle2 = 'Save Concatenated Daily Files Settings';
    [REMORA.cc.conc.paramFileOut,REMORA.cc.conc.paramPathOut] = ...
        uiputfile(fullfile(settingsPath,'*.m'),dialogTitle2);
    
    % if the cancel button is pushed, then no file is loaded
    % so exit this script
    if 0 == REMORA.cc.conc.paramFileOut
        return
    end
    
    cc_conc_create_settings_file
    
else
    warning('Action %s is unspecified.',action)
end
