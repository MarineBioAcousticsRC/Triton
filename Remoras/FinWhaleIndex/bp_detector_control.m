function fw_detector_control(action)
%Do something in response to GUI window update action:

global REMORA

if strcmp(action,'')
    
    %Top of window controls:
    
elseif strcmp(action,'setUserID')
    userid = get(REMORA.fw.verify.useridEdtxt,'string');
    REMORA.fw.detect_params.userid = userid;
    
elseif strcmp(action,'setbaseDir')
    inDir = get(REMORA.fw.verify.baseDirEdTxt,'string');
    REMORA.fw.detect_params.inDir = inDir;
    
elseif strcmp(action,'recursSearch')
    recursSearch = get(REMORA.fw.verify.recursSearch, 'Value');
    REMORA.fw.detect_params.recursSearch = recursSearch;
    
elseif strcmp(action,'setOutDir')
    outDir = get(REMORA.fw.verify.OutDirEdTxt,'string');
    REMORA.fw.detect_params.outDir = outDir;
   
elseif strcmp(action,'setBin')
    binsize = str2double(get(REMORA.fw.verify.binsizeEdTxt,'string'));
    REMORA.fw.detect_params.binsize = binsize;
    
elseif strcmp(action,'setGranularity')
    granularity = str2double(get(REMORA.fw.verify.granularity,'string'));
    REMORA.fw.detect_params.granularity = granularity;
    
elseif strcmp(action,'setThresh')
    threshold = str2double(get(REMORA.fw.verify.threshEdTxt,'string'));
    REMORA.fw.detect_params.threshold = threshold;
    
elseif strcmp(action,'setCallFreq')
    callfreq = str2double(get(REMORA.fw.verify.callfreqEdTxt,'string'));
    REMORA.fw.detect_params.callfreq = callfreq;
    
elseif strcmp(action,'setLowNoise')
    nfreq1 = str2double(get(REMORA.fw.verify.minNoiseEdTxt,'string'));
    REMORA.fw.detect_params.nfreq1 = nfreq1;
    
elseif strcmp(action,'setHighNoise')
    nfreq2 = str2double(get(REMORA.fw.verify.highNoiseEdTxt,'string'));
    REMORA.fw.detect_params.nfreq2 = nfreq2;
    
%elseif strcmp(action,'setDataType')
 %   datatype.val = get(REMORA.ag.verify.datatype, 'Value');
  %  datatype.opt = get(REMORA.ag.verify.datatype, 'string');
   % datachoice = datatype.opt{datatype.val};
   % REMORA.ag.detect_params.datatype = datachoice;
   
   %Running detector:
   
elseif strcmp(action,'runFinwhaleIndexDetector')
    d = fw_status_dialog('Fin whale index detector in progress.\n Details in Matlab console.');
    fw_index_detector(REMORA.fw.detect_params);
end