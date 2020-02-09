function sm_ltsa_control(action)
% Do something in response to GUI window update action:

global REMORA PARAMS

if strcmp(action, '')

% Change Directory Settings:

elseif strcmp(action,'indirSel')
    REMORA.sm.verify.indir.String = uigetdir(REMORA.sm.ltsa.indir,'Select Directory With WAV Files');
    REMORA.sm.ltsa.indir = REMORA.sm.verify.indir.String;
    PARAMS.ltsa.indir = REMORA.sm.verify.indir.String;

elseif strcmp(action,'outdirSel')
    REMORA.sm.verify.outdir.String = uigetdir(REMORA.sm.ltsa.outdir,'Select Directory for LTSA Output Files');
    REMORA.sm.ltsa.outdir = REMORA.sm.verify.outdir.String;
    PARAMS.ltsa.outdir = REMORA.sm.verify.outdir.String;
    
% Directory Settings:

elseif strcmp(action,'setindir')
    PARAMS.ltsa.indir = get(REMORA.sm.verify.indir,'String');
    
elseif strcmp(action,'setoutdir')
    PARAMS.ltsa.outdir = get(REMORA.sm.verify.outdir, 'String');

elseif strcmp(action,'setoutfname')
    PARAMS.ltsa.outfname = get(REMORA.sm.verify.outfname, 'String');
    
% First Column Settings:

elseif strcmp(action,'settave')
    PARAMS.ltsa.tave = str2double(get(REMORA.sm.verify.tave,'String'));
    
elseif strcmp(action,'setdfreq')
    PARAMS.ltsa.dfreq = str2double(get(REMORA.sm.verify.dfreq,'String'));
    
elseif strcmp(action,'setndays')
    PARAMS.ltsa.ndays = str2double(get(REMORA.sm.verify.ndays,'String'));

elseif strcmp(action,'setnstart')
    PARAMS.ltsa.nstart = str2double(get(REMORA.sm.verify.nstart,'String'));

    
% Second Column Settings:
    
elseif strcmp(action,'setftype')
    PARAMS.ltsa.ftype = str2double(get(REMORA.sm.verify.ftype,'String'));
    
elseif strcmp(action,'setdtype')
    PARAMS.ltsa.dtype = str2double(get(REMORA.sm.verify.dtype,'String'));
    
elseif strcmp(action,'setch')
    PARAMS.ltsa.ch = str2double(get(REMORA.sm.verify.ch,'String'));
    
    
% Running detector:

elseif strcmp(action,'runltsa')
    close(REMORA.fig.sm.ltsa)
    sm_mk_ltsa;
    
% Loading settings:

elseif strcmp(action,'sm_ltsa_settingsLoad')
    thisPath = mfilename('fullpath');
    settingsPath = fullfile(fileparts(fileparts(thisPath)));
        %'settings');% User interface retrieve file to open through a dialog box.
    dialogTitle1 = 'Open Soundscape LTSA Settings File';
    
    [REMORA.sm.ltsa.paramFile,REMORA.sm.ltsa.paramPath] = ...
        uigetfile(fullfile(settingsPath,'*.m*'),dialogTitle1);
    % Give user some feedback
    if isscalar(REMORA.sm.ltsa.paramFile)
        return    % User cancelled
    end
    if strfind(REMORA.sm.ltsa.paramFile,'.m')
        run(fullfile(REMORA.sm.ltsa.paramPath,REMORA.sm.ltsa.paramFile));
    else
        warning('Unknown file type detected.')
    end
    1;
    sm_ltsa_params_window
    
elseif strcmp(action,'sm_ltsa_settingsSave')
    thisPath = mfilename('fullpath');
    settingsPath = fullfile(fileparts(fileparts(thisPath)));
        %'settings');% User interface retrieve file to open through a dialog box.
    dialogTitle2 = 'Save Soundscape LTSA Settings';
    [REMORA.sm.ltsa.paramFileOut,REMORA.sm.ltsa.paramPathOut] = ...
        uiputfile(fullfile(settingsPath,'*.m'),dialogTitle2);
    
    % if the cancel button is pushed, then no file is loaded
    % so exit this script
    if 0 == REMORA.sm.ltsa.paramFileOut
        return
    end
    
    sm_ltsa_create_settings_file
    
else
    warning('Action %s is unspecified.',action)
end
