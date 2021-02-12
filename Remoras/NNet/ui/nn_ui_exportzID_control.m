function nn_ui_exportzID_control(action)

global REMORA

if strcmp(action,'')

elseif strcmp(action,'setBinTF')
    binTF = get(REMORA.fig.nn.exportzID.bg_r1,'Value');
    if binTF
        REMORA.nn.exportzID.binsTF = 1;
        REMORA.nn.exportzID.detsTF = 0;
        REMORA.nn.exportzID.inDirTxt = 'Folder of Network Classification Output (bin):';
    else
        REMORA.nn.exportzID.binsTF = 0;
        REMORA.nn.exportzID.detsTF = 1;
        REMORA.nn.exportzID.inDirTxt = 'Folder of Network Classifications Output(det)';
    end
    set(REMORA.fig.nn.exportzID.inDirTxt,'String',REMORA.nn.exportzID.inDirTxt)

elseif strcmp(action,'setDetTF')
    detTF = get(REMORA.fig.nn.exportzID.bg_r2,'Value');
    if detTF
        REMORA.nn.exportzID.binsTF = 0;
        REMORA.nn.exportzID.detsTF = 1;
        REMORA.nn.exportzID.inDirTxt = 'Folder of Network Classifications Output(det)';
    else
        REMORA.nn.exportzID.binsTF = 1;
        REMORA.nn.exportzID.detsTF = 0;
        REMORA.nn.exportzID.inDirTxt = 'Folder of Network Classification Output (bin):';
    end
    set(REMORA.fig.nn.exportzID.inDirTxt,'String',REMORA.nn.exportzID.inDirTxt)

elseif strcmp(action,'setInDir')
    REMORA.nn.exportzID.inDir = get(REMORA.fig.nn.exportzID.inDirEdTxt,'String');
    
elseif strcmp(action,'selectInDir')
    REMORA.nn.exportzID.inDir = uigetdir(pwd,'Select input folder');
    set(REMORA.fig.nn.exportzID.inDirEdTxt,'String',REMORA.nn.exportzID.inDir)

elseif strcmp(action,'setSearchSubDirsTF')
    REMORA.nn.exportzID.searchSubDirsTF = get(REMORA.fig.nn.exportzID.searchSubDirsCheck,'Value');
    
elseif strcmp(action,'setWildcard')
    REMORA.nn.exportzID.wildcard = get(REMORA.fig.nn.exportzID.wildcardEdTxt,'String');
    
elseif strcmp(action,'setSaveDir')
    REMORA.nn.exportzID.saveDir = get(REMORA.fig.nn.exportzID.saveDirEdTxt,'String');

elseif strcmp(action,'selectSaveDir')
    REMORA.nn.exportzID.saveDir = uigetdir(pwd,'Select input folder');
    set(REMORA.fig.nn.exportzID.saveDirEdTxt,'String',REMORA.nn.exportzID.saveDir)
       
elseif strcmp(action,'Run')
    nn_fn_exportzID
else
    fprintf('Action ''%s'' not recognized.\n',action)
end