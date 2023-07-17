function ag_detector_control(action)
% Do something in response to GUI window update action:

global REMORA

if strcmp(action, '')
    
% Top of window controls:

elseif strcmp(action,'setbaseDir')
    baseDir = get(REMORA.ag.verify.baseDirEdTxt,'String');
    REMORA.ag.detect_params.baseDir = baseDir;
    
elseif strcmp(action,'recursSearch')
    recursSearch = get(REMORA.ag.verify.recursSearch, 'Value');
    REMORA.ag.detect_params.recursSearch = recursSearch;
    
elseif strcmp(action,'setOutDir')
    outDir = get(REMORA.ag.verify.outDirEdTxt, 'string');
    REMORA.ag.detect_params.outDir = outDir;    
    
elseif strcmp(action,'setDataType')
    datatype.val = get(REMORA.ag.verify.datatype, 'Value');
    datatype.opt = get(REMORA.ag.verify.datatype, 'string');
    datachoice = datatype.opt{datatype.val};
    REMORA.ag.detect_params.datatype = datachoice;

% First Column Settings:

elseif strcmp(action,'setThresh')
    threshold = str2double(get(REMORA.ag.verify.threshEdTxt,'String'));
    REMORA.ag.detect_params.threshold = threshold;  
    
elseif strcmp(action,'setThreshOffset')
    c2_offset = str2double(get(REMORA.ag.verify.thresholdOffsetEdTxt,'String'));
    REMORA.ag.detect_params.c2_offset = c2_offset; 
    
elseif strcmp(action,'setMinTime')
    diff_s = str2double(get(REMORA.ag.verify.minTimeEdTxt,'String'));
    REMORA.ag.detect_params.diff_s = diff_s; 
    
elseif strcmp(action,'setNoiseSamp')
    nSamples = str2double(get(REMORA.ag.verify.noiseSampEdText,'String'));
    REMORA.ag.detect_params.nSamples = nSamples; 

elseif strcmp(action,'setRMSNoiseAfter')
    rmsAS = str2double(get(REMORA.ag.verify.rmsNoiseAfterEdText,'String'));
    REMORA.ag.detect_params.rmsAS = rmsAS; 
    
% Second column settings:
    
elseif strcmp(action,'setRMSNoiseBefore')
    rmsBS = str2double(get(REMORA.ag.verify.rmsNoiseBeforeEdText,'String'));
    REMORA.ag.detect_params.rmsBS = rmsBS; 
    
elseif strcmp(action,'setPPNoiseAfter')
    ppAS = str2double(get(REMORA.ag.verify.ppNoiseAfterEdText,'String'));
    REMORA.ag.detect_params.ppAS = ppAS;
    
elseif strcmp(action,'setPPNoiseBefore')
    ppBS = str2double(get(REMORA.ag.verify.ppNoiseBeforeEdText,'String'));
    REMORA.ag.detect_params.ppBS = ppBS;
    
elseif strcmp(action,'setDurAfter')
    durLong_s = str2double(get(REMORA.ag.verify.durAfterEdText,'String'));
    REMORA.ag.detect_params.durLong_s = durLong_s;
    
elseif strcmp(action,'setDurBefore')
    durShort_s = str2double(get(REMORA.ag.verify.durBeforeEdText,'String'));
    REMORA.ag.detect_params.durShort_s = durShort_s;
    
elseif strcmp(action,'plotOn')
    plotOn = get(REMORA.ag.verify.plotOn, 'Value');
    REMORA.ag.detect_params.plotOn = plotOn;
    
% Running detector:

elseif strcmp(action,'runAirgunDetector')
    d = ag_status_dialog('Airgun detector in progress.\n   Details in MatLab console.');
    if strcmp(REMORA.ag.detect_params.datatype, 'HARP')
    ag_airgun_detector(REMORA.ag.detect_params);
    elseif strcmp(REMORA.ag.detect_params.datatype, 'Sound Trap')
        ag_airgun_detector_ST(REMORA.ag.detect_params);
    end
    
% Loading settings:

elseif strcmp(action,'ag_detector_settingsLoad')
    thisPath = mfilename('fullpath');
    settingsPath = fullfile(fileparts(fileparts(thisPath)));
        %'settings');% User interface retrieve file to open through a dialog box.
    dialogTitle1 = 'Open Detector Settings File';
    
    [REMORA.ag.detector.paramFile,REMORA.ag.detector.paramPath] = ...
        uigetfile(fullfile(settingsPath,'*.m*'),dialogTitle1);
    % Give user some feedback
    if isscalar(REMORA.ag.detector.paramFile)
        return    % User cancelled
    end
    if strfind(REMORA.ag.detector.paramFile,'.m')
        run(fullfile(REMORA.ag.detector.paramPath,REMORA.ag.detector.paramFile));
    elseif strfind(REMORA.ag.detector.paramFile,'.mat')
        load(fullfile(REMORA.ag.detector.paramPath,REMORA.ag.detector.paramFile))
    else
        warning('Unknown file type detected.')
    end
    
    REMORA.ag.detect_params = parm;
    ag_init_detector_params_window
    
elseif strcmp(action,'ag_detector_settingsSave')
    thisPath = mfilename('fullpath');
    settingsPath = fullfile(fileparts(fileparts(thisPath)));
        %'settings');% User interface retrieve file to open through a dialog box.
    dialogTitle2 = 'Save Current Airgun Detector Settings As';
    [REMORA.ag.detector.paramFileOut,REMORA.ag.detector.paramPathOut] = ...
        uiputfile(fullfile(settingsPath,'*.mat'),dialogTitle2);
    
    % if the cancel button is pushed, then no file is loaded
    % so exit this script
    if 0 == REMORA.ag.detector.paramFileOut
        return
    end
    
    outFile = fullfile(REMORA.ag.detector.paramPathOut,...
        REMORA.ag.detector.paramFileOut);
    parm = REMORA.ag.detect_params;
    save(outFile,'parm')
    
else
    warning('Action %s is unspecified.',action)
end
