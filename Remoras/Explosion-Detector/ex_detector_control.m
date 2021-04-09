function ex_detector_control(action)
% Do something in response to GUI window update action:

global REMORA

if strcmp(action, '')
    
% Top of window controls:

elseif strcmp(action,'setbaseDir')
    baseDir = get(REMORA.ex.verify.baseDirEdTxt,'String');
    REMORA.ex.detect_params.baseDir = baseDir;
    
elseif strcmp(action,'recursSearch')
    recursSearch = get(REMORA.ex.verify.recursSearch, 'Value');
    REMORA.ex.detect_params.recursSearch = recursSearch;
    
elseif strcmp(action,'setOutDir')
    outDir = get(REMORA.ex.verify.outDirEdTxt, 'string');
    REMORA.ex.detect_params.outDir = outDir;    

elseif strcmp(action,'setDataType')
    datatype.val = get(REMORA.ex.verify.datatype, 'Value');
    datatype.opt = get(REMORA.ex.verify.datatype, 'string');
    datachoice = datatype.opt{datatype.val};
    REMORA.ex.detect_params.datatype = datachoice;

% First Column Settings:

elseif strcmp(action,'setThresh')
    threshold = str2double(get(REMORA.ex.verify.threshEdTxt,'String'));
    REMORA.ex.detect_params.threshold = threshold;  
    
elseif strcmp(action,'setThreshOffset')
    c2_offset = str2double(get(REMORA.ex.verify.thresholdOffsetEdTxt,'String'));
    REMORA.ex.detect_params.c2_offset = c2_offset; 
    
elseif strcmp(action,'setMinTime')
    diff_s = str2double(get(REMORA.ex.verify.minTimeEdTxt,'String'));
    REMORA.ex.detect_params.diff_s = diff_s; 
    
elseif strcmp(action,'setNoiseSamp')
    nSamples = str2double(get(REMORA.ex.verify.noiseSampEdText,'String'));
    REMORA.ex.detect_params.nSamples = nSamples; 

elseif strcmp(action,'setRMSNoiseAfter')
    rmsAS = str2double(get(REMORA.ex.verify.rmsNoiseAfterEdText,'String'));
    REMORA.ex.detect_params.rmsAS = rmsAS; 
    
% Second column settings:
    
elseif strcmp(action,'setRMSNoiseBefore')
    rmsBS = str2double(get(REMORA.ex.verify.rmsNoiseBeforeEdText,'String'));
    REMORA.ex.detect_params.rmsBS = rmsBS; 
    
elseif strcmp(action,'setPPNoiseAfter')
    ppAS = str2double(get(REMORA.ex.verify.ppNoiseAfterEdText,'String'));
    REMORA.ex.detect_params.ppAS = ppAS;
    
elseif strcmp(action,'setPPNoiseBefore')
    ppBS = str2double(get(REMORA.ex.verify.ppNoiseBeforeEdText,'String'));
    REMORA.ex.detect_params.ppBS = ppBS;
    
elseif strcmp(action,'setDurLong')
    durLong_s = str2double(get(REMORA.ex.verify.durAfterEdText,'String'));
    REMORA.ex.detect_params.durLong_s = durLong_s;
    
elseif strcmp(action,'setDurShort')
    durShort_s = str2double(get(REMORA.ex.verify.durBeforeEdText,'String'));
    REMORA.ex.detect_params.durShort_s = durShort_s;
    
% elseif strcmp(action,'plotOn')
%     plotOn = get(REMORA.ex.verify.plotOn, 'Value');
%     REMORA.ex.detect_params.plotOn = plotOn;
    
% Running detector:

elseif strcmp(action,'runExplosionDetector')
    close(REMORA.fig.ex.detector)
    d = ex_status_dialog('Explosion detector in progress.\n   Details in MatLab console.');
    if strcmp(REMORA.ex.detect_params.datatype, 'HARP')
    ex_xcorr_explosion_p2_v4(REMORA.ex.detect_params);
    elseif strcmp(REMORA.ex.detect_params.datatype, 'Sound Trap')
        ex_xcorr_explosion_p2_v4_ST(REMORA.ex.detect_params);
    end
    close(d)
    
    
% Loading settings:

elseif strcmp(action,'ex_detector_settingsLoad')
    thisPath = mfilename('fullpath');
    settingsPath = fullfile(fileparts(fileparts(thisPath)));
        %'settings');% User interface retrieve file to open through a dialog box.
    dialogTitle1 = 'Open Detector Settings File';
    
    [REMORA.ex.detector.paramFile,REMORA.ex.detector.paramPath] = ...
        uigetfile(fullfile(settingsPath,'*.m*'),dialogTitle1);
    % Give user some feedback
    if isscalar(REMORA.ex.detector.paramFile)
        return    % User cancelled
    end
    if strfind(REMORA.ex.detector.paramFile,'.m')
        run(fullfile(REMORA.ex.detector.paramPath,REMORA.ex.detector.paramFile));
    elseif strfind(REMORA.ex.detector.paramFile,'.mat')
        load(fullfile(REMORA.ex.detector.paramPath,REMORA.ex.detector.paramFile))
    else
        warning('Unknown file type detected.')
    end
    
    REMORA.ex.detect_params = parm;
    ex_init_detector_params_window
    
elseif strcmp(action,'ex_detector_settingsSave')
    thisPath = mfilename('fullpath');
    settingsPath = fullfile(fileparts(fileparts(thisPath)));
        %'settings');% User interface retrieve file to open through a dialog box.
    dialogTitle2 = 'Save Current Airgun Detector Settings As';
    [REMORA.ex.detector.paramFileOut,REMORA.ex.detector.paramPathOut] = ...
        uiputfile(fullfile(settingsPath,'*.mat'),dialogTitle2);
    
    % if the cancel button is pushed, then no file is loaded
    % so exit this script
    if 0 == REMORA.ex.detector.paramFileOut
        return
    end
    
    outFile = fullfile(REMORA.ex.detector.paramPathOut,...
        REMORA.ex.detector.paramFileOut);
    parm = REMORA.ex.detect_params;
    save(outFile,'parm')
    
else
    warning('Action %s is unspecified.',action)
end
