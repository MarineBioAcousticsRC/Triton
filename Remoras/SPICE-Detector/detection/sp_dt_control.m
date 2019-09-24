function sp_dt_control(action,mySource)
global REMORA

if ~exist('mySource','var')
    mySource = 'null';
    
end
if strcmp(action, '')
    % Note: could make this have an option to just refresh everything by making
    % these all into if rather than elseif
    
    % Set RL threshold for detector
elseif strcmp(action,'setPPThreshold')
    valueDBpp = str2double(get(REMORA.spice_dt.PPThresholdEdTxt,'String'));
    REMORA.spice_dt.detParams.dBppThreshold = max(valueDBpp,1);
    
    % Set minimum click duration for detector
elseif strcmp(action,'SetMinClickDur')
    valueMuSec = str2double(get(REMORA.spice_dt.MinClickDurEdText,'String'));
    REMORA.spice_dt.detParams.delphClickDurLims(1,1) = max(valueMuSec,0);
    
    % Set maximum click duration for detector
elseif strcmp(action,'SetMaxClickDur')
    valueMuSec = str2double(get(REMORA.spice_dt.MaxClickDurEdText,'String'));
    REMORA.spice_dt.detParams.delphClickDurLims(1,2) = max(valueMuSec,0);
    
    % Set low end of bandpass filter
elseif strcmp(action,'SetMinBandpass')
    valuekHz = str2double(get(REMORA.spice_dt.MinBandPassEdText,'String'));
    REMORA.spice_dt.detParams.bpRanges(1,1) = max(valuekHz,0);
    REMORA.spice_dt.detParams.rebuildFilter = 1;
    
    % Set high end of bandpass filter
elseif strcmp(action,'SetMaxBandpass')
    valuekHz = str2double(get(REMORA.spice_dt.MaxBandPassEdText,'String'));
    REMORA.spice_dt.detParams.bpRanges(1,2) = max(valuekHz,0);
    REMORA.spice_dt.detParams.rebuildFilter = 1;
    
    % Set minimum click peak frequency for detector
elseif strcmp(action,'SetMinPeakFreq')
    valueKHz = str2double(get(REMORA.spice_dt.MinPeakFreqEdTxt,'String'));
    REMORA.spice_dt.detParams.cutPeakBelowKHz = max(valueKHz,0);
    
    % Set minimum click peak frequency for detector
elseif strcmp(action,'SetMaxPeakFreq')
    valueKHz = str2double(get(REMORA.spice_dt.MaxPeakFreqEdTxt,'String'));
    REMORA.spice_dt.detParams.cutPeakAbovewKHz = max(valueKHz,0);
    
    % Set maximum click peak frequency for detector
elseif strcmp(action,'SetMinEnvRatio')
    valueERatio = str2double(get(REMORA.spice_dt.MinEvEdTxt,'String'));
    REMORA.spice_dt.detParams.dEvLims(1) = max(valueERatio,-1);
    
    % Set maximum click peak frequency for detector
elseif strcmp(action,'SetMaxEnvRatio')
    valueERatio = str2double(get(REMORA.spice_dt.MaxEvEdTxt,'String'));
    REMORA.spice_dt.detParams.dEvLims(2) = min(valueERatio,1);
    
    % Set maximum saturation of click detections
elseif strcmp(action,'SetClipThreshold')
    maxSaturationRatio = str2double(get(REMORA.spice_dt.clipThresholdEdTxt, 'string'));
    REMORA.spice_dt.detParams.clipThreshold = max(min(maxSaturationRatio,1),0);
    
    
elseif strcmp(action,'setUsePPThresh')
    usePPthresh = get(REMORA.spice_dt.PPThresholdRadio,'value');
    REMORA.spice_dt.detParams.snrDet = ~usePPthresh;
    if usePPthresh
        set(REMORA.spice_dt.PPThresholdEdTxt,'Visible','on')
        set(REMORA.spice_dt.SNRThresholdEdTxt,'Visible','off')
    else
        set(REMORA.spice_dt.PPThresholdEdTxt,'Visible','off')
        set(REMORA.spice_dt.SNRThresholdEdTxt,'Visible','on')
    end
        
elseif strcmp(action,'setUseSNRThresh')
    useSNRthresh = get(REMORA.spice_dt.SNRThresholdRadio,'value');
    REMORA.spice_dt.detParams.snrDet = useSNRthresh;
    if useSNRthresh
        set(REMORA.spice_dt.SNRThresholdEdTxt,'Visible','on')
        set(REMORA.spice_dt.PPThresholdEdTxt,'Visible','off')
    else
        set(REMORA.spice_dt.SNRThresholdEdTxt,'Visible','off')
        set(REMORA.spice_dt.PPThresholdEdTxt,'Visible','on')
    end
    
%% begin cases from batch detector ui
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
    REMORA.spice_dt.detParams.overwrite = overWrite;
    
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
    
elseif strcmp(action,'setUsePPThreshBatch')
    usePPthresh = get(REMORA.spice_dt_verify.PPThresholdRadio,'value');
    REMORA.spice_dt.detParams.snrDet = ~usePPthresh;
    if usePPthresh
        set(REMORA.spice_dt_verify.PPThresholdEdTxt,'Visible','on')
        set(REMORA.spice_dt_verify.SNRThresholdEdTxt,'Visible','off')
    else
        % call is coming from batch gui, so toggle those fields
        set(REMORA.spice_dt_verify.PPThresholdEdTxt,'Visible','off')
        set(REMORA.spice_dt_verify.SNRThresholdEdTxt,'Visible','on')
    end
    
elseif strcmp(action,'setUseSNRThreshBatch')
    useSNRthresh = get(REMORA.spice_dt_verify.SNRThresholdRadio,'value');
    REMORA.spice_dt.detParams.snrDet = useSNRthresh;
    if useSNRthresh
        set(REMORA.spice_dt_verify.SNRThresholdEdTxt,'Visible','on')
        set(REMORA.spice_dt_verify.PPThresholdEdTxt,'Visible','off')
    else
        set(REMORA.spice_dt_verify.SNRThresholdEdTxt,'Visible','off')
        set(REMORA.spice_dt_verify.PPThresholdEdTxt,'Visible','on')
    end
    
elseif strcmp(action,'setSNRThreshold')
    SNRthresh = str2num(get(REMORA.spice_dt.SNRThreshold,'string'));
    REMORA.spice_dt.detParams.snrThresh = SNRthresh;
    
elseif strcmp(action,'RunBatchDetection')
    sp_dt_runFullDetector()
end

if strcmp(mySource, 'gui')
    sp_dt_gui
    sp_plot_detections
end

