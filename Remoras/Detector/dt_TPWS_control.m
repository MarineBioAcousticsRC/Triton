function dt_TPWS_control(action)

global REMORA

if strcmp(action, '')
% Note: could make this have an option to just refresh everything by making
% these all into if rather than elseif
elseif strcmp(action, 'setDetDir')
    detDir = get(REMORA.dt_mkTPWS.detDirEdTxt,'String');
    REMORA.dt.mkTPWS.detDir = detDir;

elseif strcmp(action, 'setSubDirTF')
    subDirTF = get(REMORA.dt_mkTPWS.subDirCheckBox,'Value');
    REMORA.dt.mkTPWS.subDirTF = subDirTF;
    
elseif strcmp(action, 'setDetFileExt')
    fileExt = get(REMORA.dt_mkTPWS.detExtPopup,'String');
    REMORA.dt.mkTPWS.fileExt = fileExt;

elseif strcmp(action, 'setXwavDir')
    xwavDir = get(REMORA.dt_mkTPWS.xwavDirEdTxt,'String');
    REMORA.dt.mkTPWS.xwavDir = xwavDir;

elseif strcmp(action, 'setXwavFileExt')
    xwavExt = get(REMORA.dt_mkTPWS.xwavExtPopup,'String');
    REMORA.dt.mkTPWS.xwavExt = xwavExt;
    
elseif strcmp(action, 'setTPWSOutDir')
    outDir = get(REMORA.dt_mkTPWS.outDirEdTxt,'String');
    REMORA.dt.mkTPWS.outDir = outDir;
    
elseif strcmp(action, 'setbpEdgeMin')
    bpEdgeMin = get(REMORA.dt_mkTPWS.bpEdgeMinEdTxt,'String');
    REMORA.dt.mkTPWS.bpRange(1) = bpEdgeMin;
    
elseif strcmp(action, 'setbpEdgeMax')
    bpEdgeMax = get(REMORA.dt_mkTPWS.bpEdgeMaxEdTxt,'String');
    REMORA.dt.mkTPWS.bpRange(2) = bpEdgeMax;

elseif strcmp(action, 'setbpEdgeMax')
    bpEdgeMax = get(REMORA.dt_mkTPWS.bpEdgeMaxEdTxt,'String');
    REMORA.dt.mkTPWS.bpRange(2) = bpEdgeMax;    
    
elseif strcmp(action, 'setTFPath')
    tfFullFile = get(REMORA.dt_mkTPWS.tfPathEdTxt,'String');
    REMORA.dt.mkTPWS.tfFullFile = tfFullFile;
    
elseif strcmp(action, 'setTPWSFilterString')
    filterString = get(REMORA.dt_mkTPWS.filterStringEdTxt,'String');
    REMORA.dt.mkTPWS.filterString = filterString;
    
elseif strcmp(action, 'setTPWSminRL')
    ppThresh = get(REMORA.dt_mkTPWS.minRLTxt,'String');
    if ~isempty(ppThresh)
        ppThresh = str2num(ppThresh);
        REMORA.dt.mkTPWS.ppThresh = ppThresh;
    else
        REMORA.dt.mkTPWS.ppThresh = [];
    end
    
elseif strcmp(action, 'setStoreFeat')
    saveFeat = get(REMORA.dt_mkTPWS.featCheckBox,'String');
    REMORA.dt.mkTPWS.saveFeat = saveFeat;
    
elseif strcmp(action, 'run_mkTPWS')
    dt_mkTPWS
end