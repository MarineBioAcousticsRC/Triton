function lt_tLab_control(action)

%update in response to GUI settings input

global REMORA

if strcmp(action,'')
    
elseif strcmp(action,'setfilePath')
    filePath = get(REMORA.lt.tLab_verify.filePathTxt,'string');
    REMORA.lt.tLab_params.filePath = filePath;
    
elseif strcmp(action,'setTPWSitr')
    TPWSitr = get(REMORA.lt.tLab_verify.TPWSitrTxt,'string');
    REMORA.lt.tLab_params.TPWSitr = TPWSitr;

elseif strcmp(action, 'setTPWSCheck')
    TPWStype = get(REMORA.lt.tLab_verify.TPWSCheck,'Value');
    REMORA.lt.tLab_params.TPWStype = TPWStype;
    REMORA.lt.tLab_params.IDtype = 0;
    REMORA.lt.tLab_params.FDtype = 0;
    REMORA.lt.tLab_params.TDtype = 0;
    
    if REMORA.lt.tLab_params.TPWStype %toggle visibility of remove FD option 
        showFDCheck = 'on';
    else
        showFDCheck = 'off';
    end
    
    set(REMORA.lt.tLab_verify.rmvFDsCheck,'Visible',showFDCheck)
    
elseif strcmp(action, 'rmvFDsCheck')
    rmvFDs = get(REMORA.lt.tLab_verify.rmvFDsCheck,'Value');
    REMORA.lt.tLab_params.rmvFDs = rmvFDs;
    
elseif strcmp(action, 'setIDCheck')
    IDtype = get(REMORA.lt.tLab_verify.IDCheck,'Value');
    REMORA.lt.tLab_params.IDtype = IDtype;
    REMORA.lt.tLab_params.TPWStype = 0;
    REMORA.lt.tLab_params.FDtype = 0;
    REMORA.lt.tLab_params.TDtype = 0;
    set(REMORA.lt.tLab_verify.rmvFDsCheck,'Visible','off')
    
elseif strcmp(action, 'setFDCheck')
    FDtype = get(REMORA.lt.tLab_verify.FDCheck,'Value');
    REMORA.lt.tLab_params.FDtype = FDtype;
    REMORA.lt.tLab_params.TPWStype = 0;
    REMORA.lt.tLab_params.IDtype = 0;
    REMORA.lt.tLab_params.TDtype = 0;
    set(REMORA.lt.tLab_verify.rmvFDsCheck,'Visible','off')
    
elseif strcmp(action, 'setTDCheck')
    TDtype = get(REMORA.lt.tLab_verify.TDCheck,'Value');
    REMORA.lt.tLab_params.TDtype = TDtype;
    REMORA.lt.tLab_params.TPWStype = 0;
    REMORA.lt.tLab_params.FDtype = 0;
    REMORA.lt.tLab_params.IDtype = 0;
    set(REMORA.lt.tLab_verify.rmvFDsCheck,'Visible','off')
    
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
    timeOffset = str2num(get(REMORA.lt.tLab_verify.timeOffsetTxt,'string'));
    REMORA.lt.tLab_params.timeOffset = timeOffset;
    
elseif strcmp(action,'setClickDuration')
    dur = str2num(get(REMORA.lt.tLab_verify.durTxt,'string'));
    REMORA.lt.tLab_params.dur = dur;
    
elseif strcmp(action, 'runtLabCreator')
    lt_mk_tLabs(REMORA.lt.tLab_params)
end