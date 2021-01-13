function ec_control (action)

%update in response to GUI settings input

global REMORA

if strcmp(action,'')
    
elseif strcmp(action, 'setfilePath')
    filePath = get(REMORA.ec.ec_verify.filePathTxt,'string');
    REMORA.ec.ec_params.dataFilePath = filePath;
    
elseif strcmp(action, 'setoutPath')
    outPath = get(REMORA.ec.ec_verify.outPathTxt,'string');
    REMORA.ec.ec_params.outDir = outPath;
    
elseif strcmp(action,'settempPath')
    templateFile = get(REMORA.ec.ec_verify.tempPathTxt,'string');
    REMORA.ec.ec_params.templateFilePath = templateFile;
    
elseif strcmp(action,'setTFPath')
    TF = get(REMORA.ec.ec_verify.TFpathTxt,'string');
    REMORA.ec.ec_params.TFpath = TF;
    
elseif strcmp(action,'setdepName')
    depName = get(REMORA.ec.ec_verify.depNameTxt,'string');
    REMORA.ec.ec_params.depName = depName;
    
elseif strcmp(action,'setLowF')
    lowF = get(REMORA.ec.ec_verify.lowFTxt,'string');
    REMORA.ec.ec_params.lowF = str2num(lowF);
    
elseif strcmp(action,'setHighF')
    highF = get(REMORA.ec.ec_verify.HighFTxt,'string');
    REMORA.ec.ec_params.highF = str2num(highF);
    
elseif strcmp(action,'setprcTh')
    prcTh = get(REMORA.ec.ec_verify.percThTxt,'string');
    REMORA.ec.ec_params.prcTh = str2num(prcTh);
    
elseif strcmp(action,'setthresholdC')
    threshC = get(REMORA.ec.ec_verify.threshCTxt,'string');
    REMORA.ec.ec_params.thresholdC = str2num(threshC);
    
elseif strcmp(action,'setICIlow')
    lowICI = get(REMORA.ec.ec_verify.lowICITxt,'string');
    REMORA.ec.ec_params.lowICI = str2num(lowICI);
    
elseif strcmp(action,'setICIhigh')
    highICI = get(REMORA.ec.ec_verify.highICITxt,'string');
    REMORA.ec.ec_params.highICI = str2num(highICI);
    
elseif strcmp(action,'setICIpad')
    ICIpad = get(REMORA.ec.ec_verify.ICIpadTxt,'string');
    REMORA.ec.ec_params.ICIpad = str2num(ICIpad);
    
elseif strcmp(action,'setDetgap')
    gapT = get(REMORA.ec.ec_verify.detgapTxt,'string');
    REMORA.ec.ec_params.gapT = str2num(gapT);
    
elseif strcmp(action,'setthreshPP')
    threshPP = get(REMORA.ec.ec_verify.threshPPTxt,'string');
    REMORA.ec.ec_params.threshPP = str2num(threshPP);
    
elseif strcmp(action,'runDetector')
    disp('Running echosounder detector...')
    echosounder_detector(REMORA.ec.ec_params)
    
end