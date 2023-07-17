function ct_cb_control(action)
% Do something in response to gui window update action
global REMORA

if strcmp(action, '')
    
elseif strcmp(action,'setDeployName')
    deployName = get(REMORA.ct.CB_verify.deployNameEdTxt,'String');
    REMORA.ct.CB_params.siteName = deployName;
    
elseif strcmp(action,'setTPWSItr')
    TPWSitr = str2double(get(REMORA.ct.CB_verify.TPWSitrEdTxt,'String'));
    REMORA.ct.CB_params.TPWSitr = TPWSitr;
    
elseif strcmp(action,'setMinClustSize')
    minClust = str2double(get(REMORA.ct.CB_verify.minClustEdTxt,'String'));
    REMORA.ct.CB_params.minClust = minClust;
    
elseif strcmp(action,'setPruneThr')
    pruneThr = str2double(get(REMORA.ct.CB_verify.pruneThrEdTxt,'String'));
    REMORA.ct.CB_params.pruneThr = pruneThr;
    
elseif strcmp(action,'setVariableThreshold')
    variableThreshold = get(REMORA.ct.CB_verify.variableThreshold,'Value');
    REMORA.ct.CB_params.variableThreshold = variableThreshold;
    
elseif strcmp(action,'setUseSpectraTF')
    useSpectra = get(REMORA.ct.CB_verify.useSpectra,'Value');
    REMORA.ct.CB_params.useSpectra = useSpectra;
    if useSpectra % toggle visibility of other spectral options
        showSpectraOptions = 'on';
    else
        showSpectraOptions = 'off';
    end
    set(REMORA.ct.CB_verify.linearCheck,'visible',showSpectraOptions)
    set(REMORA.ct.CB_verify.startFreqTxt,'visible',showSpectraOptions)
    set(REMORA.ct.CB_verify.startFreqEdTxt,'visible',showSpectraOptions)
    set(REMORA.ct.CB_verify.endFreqTxt,'visible',showSpectraOptions)
    set(REMORA.ct.CB_verify.endFreqEdTxt,'visible',showSpectraOptions)
    set(REMORA.ct.CB_verify.diffCheck,'visible',showSpectraOptions)
    
elseif strcmp(action,'setUseEnvelopeTF')
    useEnvelope = get(REMORA.ct.CB_verify.useEnvelope,'Value');
    REMORA.ct.CB_params.useEnvelope = useEnvelope;
    
elseif strcmp(action,'setNormalizeTF')
    normalizeTF = get(REMORA.ct.CB_verify.normalizeTF,'Value');
    REMORA.ct.CB_params.normalizeTF = normalizeTF;
    
elseif strcmp(action,'setMaxCWiterations')
    maxCWiterations = str2double(get(REMORA.ct.CB_verify.maxCWitrEdTxt,'String'));
    REMORA.ct.CB_params.maxCWiterations = min(maxCWiterations,100);
    
elseif strcmp(action,'setMergeTF')
    mergeTF = get(REMORA.ct.CB_verify.mergeCheck,'Value');
    REMORA.ct.CB_params.mergeTF = mergeTF;
    
elseif strcmp(action,'setLinearTF')
    linearTF = get(REMORA.ct.CB_verify.linearCheck,'Value');
    REMORA.ct.CB_params.linearTF = linearTF;
    
elseif strcmp(action,'setPlotFlag')
    plotFlag = get(REMORA.ct.CB_verify.plotCheck,'Value');
    REMORA.ct.CB_params.plotFlag = plotFlag;
 
elseif strcmp(action,'setPlotPause')
    plotPause = get(REMORA.ct.CB_verify.plotPauseCheck,'Value');
    REMORA.ct.CB_params.pauseAfterPlotting = plotPause;
    
elseif strcmp(action,'setFalseRM')
    falseRM = get(REMORA.ct.CB_verify.falseRMCheck,'Value');
    REMORA.ct.CB_params.falseRM = min(falseRM,1);
    
elseif strcmp(action,'setDiff')
    diffCheck = get(REMORA.ct.CB_verify.diffCheck, 'Value');
    REMORA.ct.CB_params.diff = diffCheck;
    
elseif strcmp(action,'setppThresh')
    ppThresh = str2double(get(REMORA.ct.CB_verify.ppThreshEdTxt, 'string'));
    REMORA.ct.CB_params.ppThresh = ppThresh;
    
elseif strcmp(action,'setTimeStep')
    timeStep = str2double(get(REMORA.ct.CB_verify.timeStepEdTxt, 'string'));
    REMORA.ct.CB_params.timeStep = timeStep;
    
elseif strcmp(action,'setMaxNetworkSz')
    maxNetworkSz = str2double(get(REMORA.ct.CB_verify.maxNetworkSzEdTxt, 'string'));
    REMORA.ct.CB_params.maxNetworkSz = maxNetworkSz;
    
elseif strcmp(action,'setMinCueGap')
    minCueGap = str2double(get(REMORA.ct.CB_verify.minCueGapEdTxt, 'string'));
    REMORA.ct.CB_params.minCueGap = minCueGap;
    
elseif strcmp(action,'setParpoolSize')
    parpoolSize = str2double(get(REMORA.ct.CB_verify.parpoolSizeEdTxt, 'string'));
    REMORA.ct.CB_params.parpoolSize = parpoolSize;
    
elseif strcmp(action,'setStartFreq')
    startFreq = str2double(get(REMORA.ct.CB_verify.startFreqEdTxt, 'string'));
    REMORA.ct.CB_params.startFreq = startFreq;
    
elseif strcmp(action,'setEndFreq')
    endFreq = str2double(get(REMORA.ct.CB_verify.endFreqEdTxt, 'string'));
    REMORA.ct.CB_params.endFreq = endFreq;
    
elseif strcmp(action,'setBarIntMax')
    barIntMax = str2double(get(REMORA.ct.CB_verify.barIntMaxEdTxt, 'string'));
    REMORA.ct.CB_params.barIntMax = barIntMax;
    
elseif strcmp(action,'setInDir')
    inDir = get(REMORA.ct.CB_verify.inDirEdTxt, 'string');
    REMORA.ct.CB_params.inDir = inDir;
    
elseif strcmp(action,'setOutDir')
    outDir = get(REMORA.ct.CB_verify.outDirEdTxt, 'string');
    REMORA.ct.CB_params.outDir = outDir;
    
elseif strcmp(action,'recursSearch')
    recursSearch = get(REMORA.ct.CB_verify.recursSearch, 'Value');
    REMORA.ct.CB_params.recursSearch = recursSearch;
    
elseif strcmp(action,'runClusterBins')
    dh = ct_cb_status_dialog('Bin-level clustering in progress.\n    Details in Matlab console.');
    ct_cluster_bins(REMORA.ct.CB_params)
    dh = ct_cb_status_dialog('Bin-level clustering complete.');
    
elseif strcmp(action,'ct_clusterBins_settingsLoad')
    thisPath = mfilename('fullpath');
    settingsPath = fullfile(fileparts(fileparts(thisPath)),...
        'settings');
    dialogTitle1 = 'Open Bin-Level Settings File';
    
    [REMORA.ct.CB_settings.paramFile,REMORA.ct.CB_settings.paramPath] = ...
        uigetfile(fullfile(settingsPath,'*.m*'),dialogTitle1);
    % give user some feedback
    if isscalar(REMORA.ct.CB_settings.paramFile)
        return    % User cancelled
    end
    ct_cb_load_settings
    
elseif strcmp(action,'ct_clusterBins_settingsSave')
    thisPath = mfilename('fullpath');
    settingsPath = fullfile(fileparts(fileparts(thisPath)),...
        'settings');% user interface retrieve file to open through a dialog box
    dialogTitle2 = 'Save Current Bin-Level Settings As';
    [REMORA.ct.CB_settings.paramFileOut,REMORA.ct.CB_settings.paramPathOut] = ...
        uiputfile(fullfile(settingsPath,'*.mat'),dialogTitle2);
    
    % if the cancel button is pushed, then no file is loaded
    % so exit this script
    if 0 == REMORA.ct.CB_settings.paramFileOut
        return
    end
    
    outFile = fullfile(REMORA.ct.CB_settings.paramPathOut,...
        REMORA.ct.CB_settings.paramFileOut);
    p = REMORA.ct.CB_params;
    save(outFile,'p')
    
else
    warning('Action %s is unspecified.',action)
end
