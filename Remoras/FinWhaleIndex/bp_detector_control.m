function bp_detector_control(action)
%Do something in response to GUI window update action:

global REMORA

if strcmp(action,'')
    
    %Top of window controls:
    

elseif strcmp(action,'setInDir')
    inDir = get(REMORA.bp_verify.inDirEdTxt,'string');
    REMORA.bp.settings.inDir = inDir;
    
elseif strcmp(action,'setTFfile')
    TFfile = get(REMORA.bp_verify.tffileEdTxt,'string');
    REMORA.bp.settings.tffile = TFfile;
    
elseif strcmp(action,'recursSearch')
    recursSearch = get(REMORA.bp_verify.recursSearch, 'Value');
    REMORA.bp.settings.recursSearch = recursSearch;
    
elseif strcmp(action,'setOutDir')
    outDir = get(REMORA.bp_verify.OutDirEdTxt,'string');
    REMORA.bp.settings.outDir = outDir;
   
elseif strcmp(action,'checkTethys')
    Tethys = get(REMORA.bp_verify.tethysCheck, 'Value');
    REMORA.bp.settings.Tethys = Tethys;
    bp_tethys_figure;
    bp_tethys_gui;
    
elseif strcmp(action,'setUserID')
    userid = get(REMORA.bp_verify.useridEdTxt,'string');
    REMORA.bp.settings.userid = userid;
    
elseif strcmp(action,'setProject')
    project = get(REMORA.bp_verify.projectEdTxt,'string');
    REMORA.bp.settings.project = project;
    
elseif strcmp(action,'setSite')
    site = get(REMORA.bp_verify.siteEdTxt,'string');
    REMORA.bp.settings.site = site;
    
elseif strcmp(action,'setDepl')
    deployment = get(REMORA.bp_verify.deploymentEdTxt,'string');
    REMORA.bp.settings.deployment = deployment;
     
elseif strcmp(action,'setThresh')
    threshold = str2double(get(REMORA.bp_verify.threshEdTxt,'string'));
    REMORA.bp.settings.threshold = threshold;

elseif strcmp(action,'setBin')
    binsize = str2double(get(REMORA.bp_verify.binsizeEdTxt,'string'));
    REMORA.bp.settings.binsize = binsize;
    
elseif strcmp(action,'setGranularity')
    granularity = str2double(get(REMORA.bp_verify.granularity,'string'));
    REMORA.bp.settings.granularity = granularity;
        
elseif strcmp(action,'setCallFreq')
    callfreq = str2double(get(REMORA.bp_verify.callfreqEdTxt,'string'));
    REMORA.bp.settings.callfreq = callfreq;
    
elseif strcmp(action,'setLowNoise')
    nfreq1 = str2double(get(REMORA.bp_verify.minNoiseEdTxt,'string'));
    REMORA.bp.settings.nfreq1 = nfreq1;
    
elseif strcmp(action,'setHighNoise')
    nfreq2 = str2double(get(REMORA.bp_verify.highNoiseEdTxt,'string'));
    REMORA.bp.settings.nfreq2 = nfreq2;
    
%elseif strcmp(action,'setDataType')
 %   datatype.val = get(REMORA.ag.verify.datatype, 'Value');
  %  datatype.opt = get(REMORA.ag.verify.datatype, 'string');
   % datachoice = datatype.opt{datatype.val};
   % REMORA.ag.detect_params.datatype = datachoice;
   
   %Running detector:
   
elseif strcmp(action,'RunFinwhaleIndexDetector')
    d = bp_status_dialog('Fin whale index detector in progress.\n Details in Matlab console.');
    bp_Fin3PowerDetectDay_ST; %Run detector
end