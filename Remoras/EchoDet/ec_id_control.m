function ec_id_control (action)

%update in response to GUI settings input

global REMORA

if strcmp(action,'')
    
elseif strcmp(action, 'setfilePath')
    filePath = get(REMORA.ec.id_verify.filePathTxt,'string');
    REMORA.ec.id_params.inDir = filePath;
    
elseif strcmp(action, 'setoutName')
    outPath = get(REMORA.ec.id_verify.outFileTxt,'string');
    REMORA.ec.id_params.outName = outPath;
    
elseif strcmp(action,'runIt')
    disp('Creating ID file...')
    ec_getIDtimes
    
end