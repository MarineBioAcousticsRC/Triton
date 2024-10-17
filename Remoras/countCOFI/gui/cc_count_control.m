function cc_count_control(action)
% made by SGB 20240717
% Shelby G. Bloom (sbloom@ucsd.edu)
% modified/based on Soundscape-Metrics Remora gui folder code by Simone Baumann-Pickering

% Do something in response to GUI window update action:

global REMORA

if strcmp(action, '')

% Change Directory Settings:

elseif strcmp(action,'indirSel')
    REMORA.cc.verify.indir.String = uigetdir(REMORA.cc.count.indir,'Select Directory With Daily Expanded Files');
    REMORA.cc.count.indir = REMORA.cc.verify.indir.String;

elseif strcmp(action,'outdirSel')
    REMORA.cc.verify.outdir.String = uigetdir(REMORA.cc.count.outdir,'Select Directory for countCOFI Table');
    REMORA.cc.count.outdir = REMORA.cc.verify.outdir.String;

    
% Directory Settings:

elseif strcmp(action,'setindir')
    REMORA.cc.count.indir = get(REMORA.cc.verify.indir,'String');
    
elseif strcmp(action,'setoutdir')
    REMORA.cc.count.outdir = get(REMORA.cc.verify.outdir, 'String');
    
    
% I/O Settings:

elseif strcmp(action,'setGMTdiff')
    REMORA.cc.count.GMTdiff = str2double(get(REMORA.cc.verify.GMTdiff,'String'));
    
    
       
% Running Computation:

elseif strcmp(action,'runcount')
    close(REMORA.fig.cc.count)
    cc_count_table;
    
% Loading Settings:

elseif strcmp(action,'cc_count_settingsLoad')
    thisPath = mfilename('fullpath');
    settingsPath = fullfile(fileparts(fileparts(thisPath)));
    dialogTitle1 = 'Open countCOFI Table Settings File';
    
    [REMORA.cc.count.paramFile,REMORA.cc.count.paramPath] = ...
        uigetfile(fullfile(settingsPath,'*.m*'),dialogTitle1);
    
    % Give user some feedback
    if isscalar(REMORA.cc.count.paramFile)
        return    % User cancelled
    end
    if strfind(REMORA.cc.count.paramFile,'.m')
        run(fullfile(REMORA.cc.count.paramPath,REMORA.cc.count.paramFile));
    else
        warning('Unknown file type detected.')
    end

    cc_count_params_window
    
elseif strcmp(action,'cc_count_settingsSave')
    thisPath = mfilename('fullpath');
    settingsPath = fullfile(fileparts(fileparts(thisPath)));
    dialogTitle2 = 'Save countCOFI Table Settings';
    [REMORA.cc.count.paramFileOut,REMORA.cc.count.paramPathOut] = ...
        uiputfile(fullfile(settingsPath,'*.m'),dialogTitle2);
    
    % if the cancel button is pushed, then no file is loaded
    % so exit this script
    if 0 == REMORA.cc.count.paramFileOut
        return
    end
    
    cc_count_create_settings_file
    
else
    warning('Action %s is unspecified.',action)
end
