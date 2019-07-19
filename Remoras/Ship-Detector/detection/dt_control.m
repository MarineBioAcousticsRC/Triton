function dt_control(action,mySource)
global REMORA

if strcmp(action, '')
% Note: could make this have an option to just refresh everything by making
% these all into if rather than elseif
    
elseif strcmp(action,'setBaseDir')
    baseDir = get(REMORA.spice_dt_verify.baseDirEdTxt, 'string');
    REMORA.spice_dt.detParams.baseDir = baseDir;

elseif strcmp(action,'setOutDir')
    outDir = get(REMORA.spice_dt_verify.outDirEdTxt, 'string');
    REMORA.spice_dt.detParams.outDir = outDir;
    
elseif strcmp(action,'setTFPath')
    tfFullFile = get(REMORA.spice_dt_verify.TFPathEdTxt, 'string');
    REMORA.spice_dt.detParams.tfFullFile = tfFullFile;   
    
elseif strcmp(action,'setDeployName')
    deployName = get(REMORA.spice_dt_verify.deployNameEdTxt, 'string');
    REMORA.spice_dt.detParams.depl = deployName;   
    
elseif strcmp(action,'setChannel')
    channelNum = str2double(get(REMORA.spice_dt_verify.channelEdTxt, 'string'));
    % TODO add check to verify valid channel
    REMORA.spice_dt.detParams.channel = channelNum;   
    
elseif strcmp(action,'setOverwrite')
    overWrite = get(REMORA.spice_dt_verify.overwriteCheck, 'Value');
    REMORA.spice_dt.detParams.channel = overWrite;  
    
elseif strcmp(action,'SetRmIsolated')
    rmLonerClicks = get(REMORA.spice_dt_verify.rmIsolatedCheckbox, 'Value');
    REMORA.spice_dt.detParams.rmLonerClicks = rmLonerClicks; 
    
elseif strcmp(action,'SetMaxNeighbor')
    maxNeighbor = str2double(get(REMORA.spice_dt_verify.maxNeighborEdTxt, 'string'));
    REMORA.spice_dt.detParams.maxNeighbor = maxNeighbor;
    
elseif strcmp(action,'SetRmEcho')
    rmEchos = get(REMORA.spice_dt_verify.rmEchoCheckbox, 'Value');
    REMORA.spice_dt.detParams.rmEchos = rmEchos;  
    
elseif strcmp(action,'SetLockout')
    lockOut = str2double(get(REMORA.spice_dt_verify.lockoutEdTxt, 'string'));
    REMORA.spice_dt.detParams.lockOut = lockOut;
    
elseif strcmp(action,'SetNoise')
    saveNoise = get(REMORA.spice_dt_verify.noiseCheckbox, 'Value');
    REMORA.spice_dt.detParams.saveNoise = saveNoise;  
    
elseif strcmp(action,'SetSaveforTPWS')
    saveForTPWS = get(REMORA.spice_dt_verify.saveForTPWSCheckbox, 'Value');
    REMORA.spice_dt.detParams.saveForTPWS = saveForTPWS;
    
elseif strcmp(action,'SetGuidedDetection')    
    guidedDetector = get(REMORA.spice_dt_verify.GuidedDetCheckBox, 'Value');
    REMORA.spice_dt.detParams.guidedDetector = guidedDetector; 
    
elseif strcmp(action,'SetGuidedDetFile')
    gDxls = get(REMORA.spice_dt_verify.GuidedDetFileEdTxt, 'string');
    REMORA.spice_dt.detParams.gDxls = gDxls;
    
elseif strcmp(action,'SetWaveRegExp')
    DateRegExp = get(REMORA.spice_dt_verify.WaveRegExpEdTxt, 'string');
    REMORA.spice_dt.detParams.DateRegExp = DateRegExp;
    
elseif strcmp(action,'SetLRBuffer')
    LRbuffer = get(REMORA.spice_dt_verify.LRBufferEdTxt, 'string');
    REMORA.spice_dt.detParams.LRbuffer = LRbuffer;
    
elseif strcmp(action,'SetHRBuffer')    
    HRbuffer = get(REMORA.spice_dt_verify.HRBufferEdTxt, 'string');
    REMORA.spice_dt.detParams.HRbuffer = HRbuffer;
    
elseif strcmp(action,'SetMergeThreshold')
    mergeThr = get(REMORA.spice_dt_verify.mergeThresholdEdTxt, 'string');
    REMORA.spice_dt.detParams.LRbuffer = mergeThr;
    
elseif strcmp(action,'SetEnergyPercentile')
    energyPrctile = get(REMORA.spice_dt_verify.energyPercEdTxt, 'string');
    REMORA.spice_dt.detParams.energyPrctile = energyPrctile;
    
elseif strcmp(action,'SetEnergyThr')
    energyThr = get(REMORA.spice_dt_verify.energyThrEdTxt, 'string');
    REMORA.spice_dt.detParams.energyPrctile = energyThr; 
    
elseif strcmp(action,'SetFilterOrder')
    filterOrder = get(REMORA.spice_dt_verify.BPfilterEdTxt, 'string');
    REMORA.spice_dt.detParams.filterOrder = filterOrder; 
    
elseif strcmp(action,'RunBatchDetection')
    dt_runFullDetector()
end

if strcmp(mySource, 'gui')
    dt_gui
    sp_plot_detections
end

