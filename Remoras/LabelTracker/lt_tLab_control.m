function lt_tLab_control(action)

%update in response to GUI settings input

global REMORA

if strcmp(action,'')
    
elseif strcmp(action,'setfilePath')
    filePath = get(REMORA.lt.tLab_verify.filePathTxt,'string');
    REMORA.lt.tLab_params.filePath = filePath;
    
elseif strcmp(action, 'rmvFDsCheck')
    rmvFDs = get(REMORA.lt.tLab_verify.rmvFDsCheck,'Value');
    REMORA.lt.tLab_params.rmvFDs = rmvFDs;
    
     if rmvFDs % toggle visibility of other spectral options
        showFDpath = 'on';
    else
        showFDpath = 'off';
    end
    set(REMORA.lt.tLab_verify.FDpathStr,'visible',showFDpath)
    set(REMORA.lt.tLab_verify.FDpathTxt,'visible',showFDpath)
    
elseif strcmp(action,'setFDpath')
    FDpath = get(REMORA.lt.tLab_verify.FDpathTxt,'string');
    REMORA.lt.tLab_params.FDpath = FDpath;
    
elseif strcmp(action,'setSaveDir')
    saveDir = get(REMORA.lt.tLab_verify.saveDirTxt,'string');
    REMORA.lt.tLab_params.saveDir = saveDir;
    
elseif strcmp(action,'setFilePrefix')
    filePrefix = get(REMORA.lt.tLab_verify.filePrefixTxt,'string');
    REMORA.lt.tLab_params.filePrefix = filePrefix;
    
elseif strcmp(action,'setLabel1Name')
    trueLabel = get(REMORA.lt.tLab_verify.label1Txt,'string');
    REMORA.lt.tLab_params.trueLabel = trueLabel;
    
elseif strcmp(action, 'setTimeOffset')
    timeOffYr = str2num(get(REMORA.lt.tLab_verify.timeOffsetTxt,'string'));
    timeOffset = datenum(timeOffYr,0,0,0,0,0);
    REMORA.lt.tLab_params.timeOffset = timeOffset;
    
elseif strcmp(action,'setClickDuration')
    dur = str2num(get(REMORA.lt.tLab_verify.durTxt,'string'));
    REMORA.lt.tLab_params.dur = dur;
    
elseif strcmp(action, 'runtLabCreator')
    lt_mk_tLabs(REMORA.lt.tLab_params)
end