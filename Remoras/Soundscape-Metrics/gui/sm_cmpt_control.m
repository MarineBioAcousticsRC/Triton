function sm_cmpt_control(action)
% Do something in response to GUI window update action:

global REMORA

if strcmp(action, '')

% Change Directory Settings:

elseif strcmp(action,'indirSel')
    REMORA.sm.verify.indir.String = uigetdir(REMORA.sm.cmpt.indir,'Select Directory With WAV Files');
    REMORA.sm.cmpt.indir = REMORA.sm.verify.indir.String;

elseif strcmp(action,'outdirSel')
    REMORA.sm.verify.outdir.String = uigetdir(REMORA.sm.cmpt.outdir,'Select Directory for LTSA Output Files');
    REMORA.sm.cmpt.outdir = REMORA.sm.verify.outdir.String;

    
% Directory Settings:

elseif strcmp(action,'setindir')
    REMORA.sm.cmpt.indir = get(REMORA.sm.verify.indir,'String');
    
elseif strcmp(action,'setoutdir')
    REMORA.sm.cmpt.outdir = get(REMORA.sm.verify.outdir, 'String');
    

% I/O Settings:

elseif strcmp(action,'setfstart')
    REMORA.sm.cmpt.fstart = str2double(get(REMORA.sm.verify.fstart,'String'));
    
elseif strcmp(action,'setcsvout')
    REMORA.sm.cmpt.csvout = get(REMORA.sm.verify.csvout, 'Value');
    
elseif strcmp(action,'setltsaout')
    REMORA.sm.cmpt.ltsaout = get(REMORA.sm.verify.ltsaout, 'Value');    

    
% Data Analysis Settings:

elseif strcmp(action,'setlfreq')
    REMORA.sm.cmpt.lfreq = str2double(get(REMORA.sm.verify.lfreq,'String'));
    
elseif strcmp(action,'sethfreq')
    REMORA.sm.cmpt.hfreq = str2double(get(REMORA.sm.verify.hfreq,'String'));
    
elseif strcmp(action,'setavgt')
    REMORA.sm.cmpt.avgt = str2double(get(REMORA.sm.verify.avgt,'String'));

elseif strcmp(action,'setavgf')
    REMORA.sm.cmpt.avgf = str2double(get(REMORA.sm.verify.avgf,'String'));
    
elseif strcmp(action,'setperc')
    REMORA.sm.cmpt.perc = str2double(get(REMORA.sm.verify.perc,'String'))/100;
    
elseif strcmp(action,'setbb')
    REMORA.sm.cmpt.bb =get(REMORA.sm.verify.bb,'Value');
    
elseif strcmp(action,'setol')
    REMORA.sm.cmpt.ol = get(REMORA.sm.verify.ol,'Value');
    
elseif strcmp(action,'settol')
    REMORA.sm.cmpt.tol = get(REMORA.sm.verify.tol,'Value');
    
elseif strcmp(action,'setpsd')
    REMORA.sm.cmpt.psd = get(REMORA.sm.verify.psd,'Value');
    
elseif strcmp(action,'setmean')
    REMORA.sm.cmpt.mean = get(REMORA.sm.verify.mean,'Value');
    
elseif strcmp(action,'setmedian')
    REMORA.sm.cmpt.median = get(REMORA.sm.verify.median,'Value');    

elseif strcmp(action,'setprctile')
    REMORA.sm.cmpt.prctile = get(REMORA.sm.verify.prctile,'Value');    

elseif strcmp(action,'setfifo')
    REMORA.sm.cmpt.fifo = get(REMORA.sm.verify.fifo,'Value');    

elseif strcmp(action,'setdw')
    REMORA.sm.cmpt.dw = get(REMORA.sm.verify.dw,'Value');    

elseif strcmp(action,'setstrum')
    REMORA.sm.cmpt.strum = get(REMORA.sm.verify.strum,'Value');

    
% Calibration Settings:
    
elseif strcmp(action,'setcal')
    REMORA.sm.cmpt.cal = get(REMORA.sm.verify.cal,'Value');
    
elseif strcmp(action,'setsval')
    REMORA.sm.cmpt.sval = get(REMORA.sm.verify.sval,'Value');
    
elseif strcmp(action,'setcaldb')
    REMORA.sm.cmpt.caldb = str2double(get(REMORA.sm.verify.caldb,'String'));
    
elseif strcmp(action,'settfval')
    REMORA.sm.cmpt.tfval = get(REMORA.sm.verify.tfval,'Value');
    
elseif strcmp(action,'settfile')
    REMORA.sm.cmpt.tfile = get(REMORA.sm.verify.tfile,'String');
%     REMORA.sm.cmpt.tpath = get(REMORA.sm.verify.tpath,'String');
    
elseif strcmp(action,'tfilesel')
    [REMORA.sm.verify.tfile.String, REMORA.sm.verify.tpath.String]...
        = uigetfile(fullfile(REMORA.sm.cmpt.tpath,REMORA.sm.cmpt.tfile),'Select Transfer Function File');
    REMORA.sm.cmpt.tfile = REMORA.sm.verify.tfile.String;
    REMORA.sm.cmpt.tpath = REMORA.sm.verify.tpath.String;

    
% Running Computation:

elseif strcmp(action,'runcmpt')
    close(REMORA.fig.sm.cmpt)
    sm_cmpt_metrics;
    
% Loading Settings:

elseif strcmp(action,'sm_cmpt_settingsLoad')
    thisPath = mfilename('fullpath');
    settingsPath = fullfile(fileparts(fileparts(thisPath)));
    dialogTitle1 = 'Open Compute Soundscape Metrics Settings File';
    
    [REMORA.sm.cmpt.paramFile,REMORA.sm.cmpt.paramPath] = ...
        uigetfile(fullfile(settingsPath,'*.m*'),dialogTitle1);
    
    % Give user some feedback
    if isscalar(REMORA.sm.cmpt.paramFile)
        return    % User cancelled
    end
    if strfind(REMORA.sm.cmpt.paramFile,'.m')
        run(fullfile(REMORA.sm.cmpt.paramPath,REMORA.sm.cmpt.paramFile));
    else
        warning('Unknown file type detected.')
    end

    sm_cmpt_params_window
    
elseif strcmp(action,'sm_cmpt_settingsSave')
    thisPath = mfilename('fullpath');
    settingsPath = fullfile(fileparts(fileparts(thisPath)));
    dialogTitle2 = 'Save Compute Soundscape Metrics Settings';
    [REMORA.sm.cmpt.paramFileOut,REMORA.sm.cmpt.paramPathOut] = ...
        uiputfile(fullfile(settingsPath,'*.m'),dialogTitle2);
    
    % if the cancel button is pushed, then no file is loaded
    % so exit this script
    if 0 == REMORA.sm.cmpt.paramFileOut
        return
    end
    
    sm_cmpt_create_settings_file
    
else
    warning('Action %s is unspecified.',action)
end
