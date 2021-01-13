function ec_id_control (action)

%update in response to GUI settings input

global REMORA

if strcmp(action,'')
    
elseif strcmp(action, 'setfilePath')
    filePath = get(REMORA.ec.id_verify.filePathTxt,'string');
    REMORA.ec.id_params.inDir = filePath;
    
elseif strcmp(action, 'runonSub')
    subPath = get(REMORA.ec.id_verify.runonSub,'Value');
    REMORA.ec.id_params.runonSub = subPath;
    
    if REMORA.ec.id_params.runonSub
        showoutName = 'off';
        showPref = 'on';
    else
        showoutName = 'on';
        showPref = 'off';
    end
    
    set(REMORA.ec.id_verify.outFileStr,'Visible',showoutName)
    set(REMORA.ec.id_verify.outFileTxt,'Visible',showoutName)
    set(REMORA.ec.id_verify.inPrefStr,'Visible',showPref)
    set(REMORA.ec.id_verify.inPrefTxt,'Visible',showPref)
    
elseif strcmp(action, 'setoutName')
    outPath = get(REMORA.ec.id_verify.outFileTxt,'string');
    REMORA.ec.id_params.outName = outPath;
    
elseif strcmp(action, 'setsubfolderPref')
    subPref = get(REMORA.ec.id_verify.inPrefTxt,'string');
    REMORA.ec.id_params.inPref = subPref;    
    
elseif strcmp(action, 'setoutFolder')
    outDir = get(REMORA.ec.id_verify.outFoldTxt,'string')
    REMORA.ec.id_params.outDir = outDir;
    
elseif strcmp(action,'runIt')
    disp('Creating ID file...')
    ec_getIDtimes
    
end