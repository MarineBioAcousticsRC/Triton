function bp_detector_control(action)
%Do something in response to GUI window update action:

global REMORA

if strcmp(action,'')
    
    %Top of window controls:
    
elseif strcmp(action,'setUserID')
    userid = get(REMORA.bp.verify.useridEdtxt,'string');
    REMORA.bp.settings.userid = userid;
    
elseif strcmp(action,'setInDir')
    inDir = get(REMORA.bp.verify.inDirEdTxt,'string');
    REMORA.bp.settings.inDir = inDir;
    
elseif strcmp(action,'setTFfile')
    TFfile = get(REMORA.bp.verify.tffileEdTxt,'string');
    REMORA.bp.settings.tffile = TFfile;
    
elseif strcmp(action,'recursSearch')
    recursSearch = get(REMORA.bp.verify.recursSearch, 'Value');
    REMORA.bp.settings.recursSearch = recursSearch;
    
elseif strcmp(action,'setOutDir')
    outDir = get(REMORA.bp.verify.OutDirEdTxt,'string');
    REMORA.bp.settings.outDir = outDir;
   
elseif strcmp(action,'setThresh')
    threshold = str2double(get(REMORA.bp.verify.threshEdTxt,'string'));
    REMORA.bp.settings.threshold = threshold;

elseif strcmp(action,'setBin')
    binsize = str2double(get(REMORA.bp.verify.binsizeEdTxt,'string'));
    REMORA.bp.settings.binsize = binsize;
    
elseif strcmp(action,'setGranularity')
    granularity = str2double(get(REMORA.bp.verify.granularity,'string'));
    REMORA.bp.settings.granularity = granularity;
        
elseif strcmp(action,'setCallFreq')
    callfreq = str2double(get(REMORA.bp.verify.callfreqEdTxt,'string'));
    REMORA.bp.settings.callfreq = callfreq;
    
elseif strcmp(action,'setLowNoise')
    nfreq1 = str2double(get(REMORA.bp.verify.minNoiseEdTxt,'string'));
    REMORA.bp.settings.nfreq1 = nfreq1;
    
elseif strcmp(action,'setHighNoise')
    nfreq2 = str2double(get(REMORA.bp.verify.highNoiseEdTxt,'string'));
    REMORA.bp.settings.nfreq2 = nfreq2;
    
%elseif strcmp(action,'setDataType')
 %   datatype.val = get(REMORA.ag.verify.datatype, 'Value');
  %  datatype.opt = get(REMORA.ag.verify.datatype, 'string');
   % datachoice = datatype.opt{datatype.val};
   % REMORA.ag.detect_params.datatype = datachoice;
   
   %Running detector:
   
elseif strcmp(action,'runFinwhaleIndexDetector')
    d = bp_status_dialog('Fin whale index detector in progress.\n Details in Matlab console.');
    bp_Fin3PowerDetectDay_ST; %Run detector
end