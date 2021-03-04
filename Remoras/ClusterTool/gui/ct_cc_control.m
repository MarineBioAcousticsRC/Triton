function ct_cc_control(action)
% Do something in response to gui window update action
global REMORA

if strcmp(action,'')

elseif strcmp(action,'setInDir')
    inDir = get(REMORA.ct.CC_verify.inDirEdTxt,'String');
    REMORA.ct.CC_params.inDir = inDir;
    
elseif strcmp(action,'setOutDir')
    outDir = get(REMORA.ct.CC_verify.outDirEdTxt,'String');
    REMORA.ct.CC_params.outDir = outDir;
    
elseif strcmp(action,'setInFileString')
    inFileString = get(REMORA.ct.CC_verify.inFileStringEdTxt,'String');
    REMORA.ct.CC_params.inFileString = inFileString;

elseif strcmp(action,'setOutputName')
    outputName = get(REMORA.ct.CC_verify.outputNameEdTxt,'String');
    REMORA.ct.CC_params.outputName = outputName;

elseif strcmp(action, 'saveOutput')
    saveOutput = get(REMORA.ct.CC_verify.saveOutput,'Value');
    REMORA.ct.CC_params.saveOutput = saveOutput;
   
elseif strcmp(action,'setUseSpectraTF')
    useSpectraTF = get(REMORA.ct.CC_verify.spectraCheck,'Value');
    REMORA.ct.CC_params.useSpectraTF = useSpectraTF;
    if REMORA.ct.CC_params.useSpectraTF
        showSpectralParams = 'on';
    else
        showSpectralParams = 'off';
    end
    % Toggle other spectral params on and off depending on if they are
    % being used
    set(REMORA.ct.CC_verify.startFreqTxt,'Visible',showSpectralParams)
    set(REMORA.ct.CC_verify.endFreqTxt,'Visible',showSpectralParams)
    set(REMORA.ct.CC_verify.startFreqEdTxt,'Visible',showSpectralParams)
    set(REMORA.ct.CC_verify.endFreqEdTxt,'Visible',showSpectralParams)
    set(REMORA.ct.CC_verify.linearCheck,'Visible',showSpectralParams)
    set(REMORA.ct.CC_verify.diffCheck,'Visible',showSpectralParams)
    
elseif strcmp(action,'setStartFreq')
    startFreq = str2double(get(REMORA.ct.CC_verify.startFreqEdTxt,'String'));
    REMORA.ct.CC_params.startFreq = startFreq;
    
elseif strcmp(action,'setEndFreq')
    endFreq = str2double(get(REMORA.ct.CC_verify.endFreqEdTxt,'String'));
    REMORA.ct.CC_params.endFreq = endFreq;
    
elseif strcmp(action,'setLinearTF')
    linearTF = get(REMORA.ct.CC_verify.linearCheck,'Value');
    REMORA.ct.CC_params.linearTF = linearTF;
    
elseif strcmp(action,'setDiff')
    specDiffTF = get(REMORA.ct.CC_verify.diffCheck,'Value');
    REMORA.ct.CC_params.specDiffTF = specDiffTF;
elseif strcmp(action,'setNormalizeSpectraTF')
    specNormTF = get(REMORA.ct.CC_verify.normalizeSpectraCheck,'Value');
    REMORA.ct.CC_params.normalizeSpectra = specNormTF;
    
elseif strcmp(action,'setUseTimesTF')
    useTimesTF = get(REMORA.ct.CC_verify.timesCheck,'Value');
    REMORA.ct.CC_params.useTimesTF = useTimesTF;
    
    if REMORA.ct.CC_params.useTimesTF
        showTemporalParams = 'on';
    else
        showTemporalParams = 'off';
    end
    set(REMORA.ct.CC_verify.bg,'Visible',showTemporalParams)
    %set(REMORA.ct.CC_verify.ICIMinTxt,'Visible',showTemporalParams)
    %set(REMORA.ct.CC_verify.ICIMinEdTxt,'Visible',showTemporalParams)
    %set(REMORA.ct.CC_verify.ICIMaxTxt,'Visible',showTemporalParams)
    %set(REMORA.ct.CC_verify.ICIMaxEdTxt,'Visible',showTemporalParams)
    set(REMORA.ct.CC_verify.correctForSatCheck,'Visible',showTemporalParams)
    
elseif strcmp(action,'setUseEnvShape')
    useEnvShapeTF = get(REMORA.ct.CC_verify.envCheck,'Value');
    REMORA.ct.CC_params.useEnvShape = useEnvShapeTF;
    
elseif strcmp(action,'setMaxCWiterations')
    maxCWIterations = str2double(get(REMORA.ct.CC_verify.maxCWitrEdTxt,'String'));
    REMORA.ct.CC_params.maxCWIterations = maxCWIterations;
    
elseif strcmp(action,'setMaxNetworkSz')
    maxClust = str2double(get(REMORA.ct.CC_verify.maxNetworkSzEdTxt,'String'));
    REMORA.ct.CC_params.maxClust = maxClust;
    
elseif strcmp(action,'setPruneThr')
    pruneThr = str2double(get(REMORA.ct.CC_verify.pruneThrEdTxt,'String'));
    REMORA.ct.CC_params.pruneThr = pruneThr;
    
elseif strcmp(action,'setMinClicks')
    minClicks = str2double(get(REMORA.ct.CC_verify.minClicksEdTxt,'String'));
    REMORA.ct.CC_params.minClicks = minClicks;
    
elseif strcmp(action,'setMinClust')
    minClust = str2double(get(REMORA.ct.CC_verify.minClustEdTxt,'String'));
    REMORA.ct.CC_params.minClust = minClust;
    
elseif strcmp(action,'setNTrials')
    NTrials = str2double(get(REMORA.ct.CC_verify.NTrialsEdTxt,'String'));
    REMORA.ct.CC_params.N = NTrials;
    
elseif strcmp(action,'setSingleClustTF')
    singleClusterOnly = get(REMORA.ct.CC_verify.singleClustCheck,'Value');
    REMORA.ct.CC_params.singleClusterOnly = singleClusterOnly;
    
elseif strcmp(action,'setICIMin')
    minICI = str2num(get(REMORA.ct.CC_verify.ICIMinEdTxt,'String'));
    REMORA.ct.CC_params.minICI = minICI;
    
elseif strcmp(action,'setICIMax')
    maxICI = str2num(get(REMORA.ct.CC_verify.ICIMaxEdTxt,'String'));
    REMORA.ct.CC_params.maxICI = maxICI;
    
elseif strcmp(action,'setCorrectForSatTF')
    correctForSatTF = get(REMORA.ct.CC_verify.correctForSatCheck,'Value');
    REMORA.ct.CC_params.correctForSaturation = correctForSatTF;
    
elseif strcmp(action,'setICIMode')
    iciModeTF = get(REMORA.ct.CC_verify.bg_r1 ,'Value');
    REMORA.ct.CC_params.iciModeTF = iciModeTF;
    REMORA.ct.CC_params.iciDistTF = ~REMORA.ct.CC_params.iciModeTF;
    
elseif strcmp(action,'setICIDist')
    iciDistTF = get(REMORA.ct.CC_verify.bg_r2 ,'Value');
    REMORA.ct.CC_params.iciDistTF = iciDistTF;
    REMORA.ct.CC_params.iciModeTF = ~REMORA.ct.CC_params.iciDistTF;
    
elseif strcmp(action,'setClusterPruningFactor')
    clusterPruningFactor = str2double(get(REMORA.ct.CC_verify.clusterPruneEdTxt ,'String'));
    REMORA.ct.CC_params.clusterPrune = clusterPruningFactor;
    
elseif strcmp(action,'setClusteredOnlyTF')
    clusteredOnlyTF = get(REMORA.ct.CC_verify.clusteredOnlyCheck,'Value');
    REMORA.ct.CC_params.clusteredOnly = clusteredOnlyTF;

elseif strcmp(action,'rmPriorClustersTF')
    rmBinsTf = get(REMORA.ct.CC_verify.rmClustCheck,'Value');
    REMORA.ct.CC_params.rmPriorClusters = rmBinsTf;
    
elseif strcmp(action,'rmSimBinTF')
    rmSimBinsTf = get(REMORA.ct.CC_verify.rmSimBinCheck,'Value');
    REMORA.ct.CC_params.rmSimBins = rmSimBinsTf;
    
    if REMORA.ct.CC_params.rmSimBins
        showSBParams = 'on';
    else
        showSBParams = 'off';
    end
    
    set(REMORA.ct.CC_verify.SBdiffTxt,'Visible',showSBParams)
    set(REMORA.ct.CC_verify.SBdiffEdTxt,'Visible',showSBParams)
    set(REMORA.ct.CC_verify.SBpercTxt,'Visible',showSBParams)
    set(REMORA.ct.CC_verify.SBpercEdTxt,'Visible',showSBParams)
    
    
elseif strcmp(action,'setSBdiff')
    sbDiff = str2num(get(REMORA.ct.CC_verify.SBdiffEdTxt,'String'));
    REMORA.ct.CC_params.SBdiff = sbDiff;
    
elseif strcmp(action,'setSBperc')
    sbPerc = str2num(get(REMORA.ct.CC_verify.SBpercEdTxt,'String'));
    REMORA.ct.CC_params.SBperc = sbPerc;
    
elseif strcmp(action,'runCompositeClusters')
    REMORA.fig.ct.status = ct_cb_status_dialog('Composite clustering in progress.\n    Details in Matlab console.');
    spinH = ct_add_spinner(gcf,[0.45,0.3,0.1,0.15]);
    spinH.start;drawnow;
    
    [exitCode,ccOutput] = ct_composite_clusters(REMORA.ct.CC_params);
    REMORA.ct.CC.output = ccOutput;
    if exitCode
        REMORA.fig.ct.status = ct_cb_status_dialog('Composite clustering complete.');
        % show post-clustering menu
        ct_post_cluster_ui
    else
        REMORA.fig.ct.status = ct_cb_status_dialog('Composite clustering failed. See Matlab console for details.');
    end
    spinH.stop;
    
elseif strcmp(action,'ct_cc_settingsLoad')
    thisPath = mfilename('fullpath');
    settingsPath = fullfile(fileparts(fileparts(thisPath)),'settings');
    dialogTitle1 = 'Open Composite-Level Settings File';
    
    [REMORA.ct.CC_settings.paramFile,REMORA.ct.CC_settings.paramPath] = ...
        uigetfile(fullfile(settingsPath,'*.m*'),dialogTitle1);
    % give user some feedback
    if isscalar(REMORA.ct.CC_settings.paramFile)
        return    % User cancelled
    end
    ct_cc_load_settings
    
elseif strcmp(action,'ct_cc_settingsSave')
    thisPath = mfilename('fullpath');
    settingsPath = fullfile(fileparts(fileparts(thisPath)),...
        'settings');% user interface retrieve file to open through a dialog box
    dialogTitle2 = 'Save Current Composite-Level Settings As';
    [REMORA.ct.CC_settings.paramFileOut,REMORA.ct.CC_settings.paramPathOut] = ...
        uiputfile(fullfile(settingsPath,'*.mat'),dialogTitle2);
    
    % if the cancel button is pushed, then no file is loaded
    % so exit this script
    if 0 == REMORA.ct.CC_settings.paramFileOut
        return
    end
    
    outFile = fullfile(REMORA.ct.CC_settings.paramPathOut,...
        REMORA.ct.CC_settings.paramFileOut);
    s = REMORA.ct.CC_params;
    save(outFile,'s')
    
else
    warning('Action %s is unspecified.',action)
end
