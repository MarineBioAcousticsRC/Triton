function nn_ui_classify_control(action)
% Do something in response to gui window update action

global REMORA

if strcmp(action,'')

elseif strcmp(action,'setBinTF')
    binTF = get(REMORA.fig.nn.classify.bg_r1,'Value');
    if binTF
        REMORA.nn.classify.binsTF = 1;
        REMORA.nn.classify.detsTF = 0;
        REMORA.nn.classify.inDirTxt = 'Location of ''Cluster Bins'' output:';
    else
        REMORA.nn.classify.binsTF = 0;
        REMORA.nn.classify.detsTF = 1;
        REMORA.nn.classify.inDirTxt = 'Location of TPWS files:';
    end
    set(REMORA.fig.nn.classify.inDirTxt,'String',REMORA.nn.classify.inDirTxt)

elseif strcmp(action,'setDetTF')
    detTF = get(REMORA.fig.nn.classify.bg_r2,'Value');
    if detTF
        REMORA.nn.classify.binsTF = 0;
        REMORA.nn.classify.detsTF = 1;
        REMORA.nn.classify.inDirTxt = 'Location of TPWS files:';
    else
        REMORA.nn.classify.binsTF = 1;
        REMORA.nn.classify.detsTF = 0;
        REMORA.nn.classify.inDirTxt = 'Location of ''Cluster Bins'' output:';
    end
    set(REMORA.fig.nn.classify.inDirTxt,'String',REMORA.nn.classify.inDirTxt)

elseif strcmp(action,'setInDir')
    REMORA.nn.classify.inDir = get(REMORA.fig.nn.classify.inDirEdTxt,'String');
    
elseif strcmp(action,'selectInDir')
    REMORA.nn.classify.inDir = uigetdir(pwd,'Select input folder');
    set(REMORA.fig.nn.classify.inDirEdTxt,'String',REMORA.nn.classify.inDir)

elseif strcmp(action,'setSearchSubDirsTF')
    REMORA.nn.classify.searchSubDirsTF = get(REMORA.fig.nn.classify.searchSubDirsCheck,'Value');
    
elseif strcmp(action,'setWildcard')
    REMORA.nn.classify.wildcard = get(REMORA.fig.nn.classify.wildcardEdTxt,'String');

elseif strcmp(action,'setNetworkPath')
    REMORA.nn.classify.networkPath = get(REMORA.fig.nn.classify.networkPathEdTxt,'String');
    
elseif strcmp(action,'selectNetworkPath')
    [netFile,netPath] = uigetfile('*trainedNetwork.mat','Select trained network file');
    REMORA.nn.classify.networkPath = fullfile(netPath,netFile);
    set(REMORA.fig.nn.classify.networkPathEdTxt,'String',REMORA.nn.classify.networkPath)
    
elseif strcmp(action,'setSaveDir')
    REMORA.nn.classify.saveDir = get(REMORA.fig.nn.classify.saveDirEdTxt,'String');

elseif strcmp(action,'selectSaveDir')
    REMORA.nn.classify.saveDir = uigetdir(pwd,'Select input folder');
    set(REMORA.fig.nn.classify.saveDirEdTxt,'String',REMORA.nn.classify.saveDir)
elseif strcmp(action,'Run')
    nn_fn_classify
else
    fprintf('Action ''%s'' not recognized.\n',action)
end