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
    if ~strcmp(mySource, 'gui')
        valueDBpp = str2double(get(REMORA.spice_dt_verify.PPThresholdEdTxt,'String'));
    else
        valueDBpp = str2double(get(REMORA.spice_dt.PPThresholdEdTxt,'String'));
    end
    REMORA.spice_dt.detParams.dBppThreshold = max(valueDBpp,1);
    REMORA.spice_dt.detParams.dBppThresholdFlag = 1; % if true, recalculate counts threshold.
    % Set minimum click duration for detector
elseif strcmp(action,'SetMinClickDur')
    if ~strcmp(mySource, 'gui')
        valueMuSec = str2double(get(REMORA.spice_dt_verify.MinClickDurEdText,'String'));
    else
        valueMuSec = str2double(get(REMORA.spice_dt.MinClickDurEdText,'String'));
    end
    REMORA.spice_dt.detParams.delphClickDurLims(1,1) = max(valueMuSec,0);
    
    % Set maximum click duration for detector
elseif strcmp(action,'SetMaxClickDur')
    if ~strcmp(mySource, 'gui')
        valueMuSec = str2double(get(REMORA.spice_dt_verify.MaxClickDurEdText,'String'));
    else
        valueMuSec = str2double(get(REMORA.spice_dt.MaxClickDurEdText,'String'));
    end
    REMORA.spice_dt.detParams.delphClickDurLims(1,2) = max(valueMuSec,0);
        
    % Set low end of bandpass filter
elseif strcmp(action,'SetMinBandpass')
    if ~strcmp(mySource, 'gui')
        valuekHz = str2double(get(REMORA.spice_dt_verify.MinBandPassEdText,'String'));
    else
        valuekHz = str2double(get(REMORA.spice_dt.MinBandPassEdText,'String'));
    end
    REMORA.spice_dt.detParams.bpRanges(1,1) = max(valuekHz,0);
    REMORA.spice_dt.detParams.rebuildFilter = 1;
    
    % Set high end of bandpass filter
elseif strcmp(action,'SetMaxBandpass')
    if ~strcmp(mySource, 'gui')
        valuekHz = str2double(get(REMORA.spice_dt_verify.MaxBandPassEdText,'String'));
    else
        valuekHz = str2double(get(REMORA.spice_dt.MaxBandPassEdText,'String'));
    end
    REMORA.spice_dt.detParams.bpRanges(1,2) = max(valuekHz,0);
    REMORA.spice_dt.detParams.rebuildFilter = 1;
    
    % Set minimum click peak frequency for detector
elseif strcmp(action,'SetMinPeakFreq')
    if ~strcmp(mySource, 'gui')
        valueKHz = str2double(get(REMORA.spice_dt_verify.MinPeakFreqEdTxt,'String'));
    else
        valueKHz = str2double(get(REMORA.spice_dt.MinPeakFreqEdTxt,'String'));
    end
    REMORA.spice_dt.detParams.cutPeakBelowKHz = max(valueKHz,0);
    
    % Set minimum click peak frequency for detector
elseif strcmp(action,'SetMaxPeakFreq')
    if ~strcmp(mySource, 'gui')
        valueKHz = str2double(get(REMORA.spice_dt_verify.MaxPeakFreqEdTxt,'String'));
    else
        valueKHz = str2double(get(REMORA.spice_dt.MaxPeakFreqEdTxt,'String'));
    end
    REMORA.spice_dt.detParams.cutPeakAboveKHz = max(valueKHz,0);
    
    % Set maximum click peak frequency for detector
elseif strcmp(action,'SetMinEnvRatio')
    if ~strcmp(mySource, 'gui')
        valueERatio = str2double(get(REMORA.spice_dt_verify.MinEvEdTxt,'String'));
    else
        valueERatio = str2double(get(REMORA.spice_dt.MinEvEdTxt,'String'));
    end
    REMORA.spice_dt.detParams.dEvLims(1) = max(valueERatio,-1);
    
    % Set maximum click peak frequency for detector
elseif strcmp(action,'SetMaxEnvRatio')
    if ~strcmp(mySource, 'gui')
        valueERatio = str2double(get(REMORA.spice_dt_verify.MaxEvEdTxt,'String'));
    else
        valueERatio = str2double(get(REMORA.spice_dt.MaxEvEdTxt,'String'));
    end
    REMORA.spice_dt.detParams.dEvLims(2) = min(valueERatio,1);
    
    % Set maximum saturation of click detections
elseif strcmp(action,'SetClipThreshold')
    if ~strcmp(mySource, 'gui')
        maxSaturationRatio = str2double(get(REMORA.spice_dt_verify.clipThresholdEdTxt, 'string'));
    else
        maxSaturationRatio = str2double(get(REMORA.spice_dt.clipThresholdEdTxt, 'string'));
    end
    REMORA.spice_dt.detParams.clipThreshold = max(min(maxSaturationRatio,1),0);
    
    
elseif strcmp(action,'setUsePPThresh')
    if ~strcmp(mySource, 'gui')
        usePPthresh = get(REMORA.spice_dt_verify.PPThresholdRadio,'value');
    else
        usePPthresh = get(REMORA.spice_dt.PPThresholdRadio,'value');
    end
    REMORA.spice_dt.detParams.snrDet = ~usePPthresh;
    REMORA.spice_dt.detParams.dBppThresholdFlag = 1;
    if usePPthresh
        set(REMORA.spice_dt.PPThresholdEdTxt,'Visible','on')
        set(REMORA.spice_dt.SNRThresholdEdTxt,'Visible','off')
    else
        set(REMORA.spice_dt.PPThresholdEdTxt,'Visible','off')
        set(REMORA.spice_dt.SNRThresholdEdTxt,'Visible','on')
    end
        
elseif strcmp(action,'setUseSNRThresh')
    if ~strcmp(mySource, 'gui')
        useSNRthresh = get(REMORA.spice_dt_verify.SNRThresholdRadio,'value');
    else
        useSNRthresh = get(REMORA.spice_dt.SNRThresholdRadio,'value');
    end
    REMORA.spice_dt.detParams.snrDet = useSNRthresh;
    REMORA.spice_dt.detParams.dBppThresholdFlag = 0;
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

elseif strcmp(action,'SetWhiten')
    if strcmp(mySource, 'gui')
        whitenTF = get(REMORA.spice_dt.whitenCheck, 'Value');
        REMORA.spice_dt.detParams.rebuildFilter = 1;
    else
        whitenTF = get(REMORA.spice_dt_verify.whitenCheck, 'Value');
    end
    REMORA.spice_dt.detParams.whiten = whitenTF;
    
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
    LRbuffer = str2num(get(REMORA.spice_dt_verify.LRBufferEdTxt, 'string'));
    REMORA.spice_dt.detParams.LRbuffer = LRbuffer;
    
elseif strcmp(action,'SetHRBuffer')
    HRbuffer = str2num(get(REMORA.spice_dt_verify.HRBufferEdTxt, 'string'));
    REMORA.spice_dt.detParams.HRbuffer = HRbuffer;
    
elseif strcmp(action,'SetMergeThreshold')
    mergeThr = str2num(get(REMORA.spice_dt_verify.mergeThresholdEdTxt, 'string'));
    REMORA.spice_dt.detParams.mergeThr = mergeThr;
    
elseif strcmp(action,'SetEnergyPercentile')
    energyPrctile = str2num(get(REMORA.spice_dt_verify.energyPercEdTxt, 'string'));
    REMORA.spice_dt.detParams.energyPrctile = energyPrctile;
    
elseif strcmp(action,'SetEnergyThr')
    energyThr = str2num(get(REMORA.spice_dt_verify.energyThrEdTxt, 'string'));
    REMORA.spice_dt.detParams.energyPrctile = energyThr;
    
elseif strcmp(action,'SetParpool')
    parpoolSize = str2num(get(REMORA.spice_dt_verify.parpoolEdTxt, 'string'));
    REMORA.spice_dt.detParams.parpool = parpoolSize;

elseif strcmp(action,'SetFilterOrder')
    filterOrder = str2num(get(REMORA.spice_dt_verify.BPfilterEdTxt, 'string'));
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
    if ~strcmp(mySource, 'gui')
        SNRthresh = str2num(get(REMORA.spice_dt_verify.SNRThresholdEdTxt,'string'));
    else
        SNRthresh = str2num(get(REMORA.spice_dt.SNRThresholdEdTxt,'string'));
    end
    REMORA.spice_dt.detParams.snrThresh = SNRthresh;
    
elseif strcmp(action,'RunBatchDetection')
    sp_dt_runFullDetector()
end

if strcmp(mySource, 'gui')
    sp_dt_gui
    sp_plot_detections
end

