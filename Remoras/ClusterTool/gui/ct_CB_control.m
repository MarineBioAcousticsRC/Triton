function ct_CB_control(action)
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
    
% Set low end of bandpass filter 
elseif strcmp(action,'setVariableThreshold')
    variableThreshold = get(REMORA.ct.CB_verify.variableThreshold,'Value');
    REMORA.ct.CB_params.variableThreshold = variableThreshold;
    
% Set high end of bandpass filter 
elseif strcmp(action,'setMaxCWiterations')
    maxCWiterations = str2double(get(REMORA.ct.CB_verify.maxCWiterationsEdText,'String'));
    REMORA.ct.CB_params.maxCWiterations = min(maxCWiterations,100); 
    
% Set minimum click peak frequency for detector
elseif strcmp(action,'setMergeTF')
    mergeTF = get(REMORA.ct.CB_verify.mergeCheck,'Value');
    REMORA.ct.CB_params.mergeTF = mergeTF;

% Set minimum click peak frequency for detector
elseif strcmp(action,'setLinearTF')
    linearTF = get(REMORA.ct.CB_verify.linearCheck,'Value');
    REMORA.ct.CB_params.linearTF = linearTF;
    
% Set maximum click peak frequency for detector
elseif strcmp(action,'setPlotFlag')
    plotFlag = get(REMORA.ct.CB_verify.plotCheck,'Value');
    REMORA.ct.CB_params.plotFlag = plotFlag;
    
% Set maximum click peak frequency for detector
elseif strcmp(action,'setFalseRM')
    falseRM = get(REMORA.ct.CB_verify.falseRMCheck,'Value');
    REMORA.ct.CB_params.falseRM = min(falseRM,1);
    
elseif strcmp(action,'setDiff')
    diffCheck = get(REMORA.ct.CB_verify.diffCheck, 'value');
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
    REMORA.ct.CB_params.rmEchos = barIntMax;  
    
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
    dh = ct_CB_status_dialog('Bin-level clustering in progress.\n    Details in Matlab console.');
    ct_cluster_bins(REMORA.ct.CB_params)
    dh = ct_CB_status_dialog('Bin-level clustering complete.');

else
    warning('Action %s is unspecified.',action)

end
