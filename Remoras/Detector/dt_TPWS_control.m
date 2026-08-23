function dt_TPWS_control(action)

global REMORA

if strcmp(action, '')
% Note: could make this have an option to just refresh everything by making
% these all into if rather than elseif
elseif strcmp(action, 'setDetDir')
    detDir = get(REMORA.dt_TPWS_verify.detDirEdTxt,'String');
    REMORA.dt.TPWS.detDir = detDir;
    
elseif strcmp(action, 'setDetFileExt')
    detExtString = get(REMORA.dt_TPWS_verify.detFileExtPopup,'String');
    detExtValue = get(REMORA.dt_TPWS_verify.detFileExtPopup,'Value');
    REMORA.dt.TPWS.detFileExt = detExtString{detExtValue};

elseif strcmp(action, 'setRecDir')
    recDir = get(REMORA.dt_TPWS_verify.recDirEdTxt,'String');
    REMORA.dt.TPWS.recDir = recDir;

elseif strcmp(action, 'setRecFileExt')
    recExtString = get(REMORA.dt_TPWS_verify.recFileExtPopup,'String');
    recExtValue = get(REMORA.dt_TPWS_verify.recFileExtPopup,'Value');
    REMORA.dt.TPWS.recFileExt = recExtString{recExtValue};
    
elseif strcmp(action, 'setTPWSOutDir')
    outDir = get(REMORA.dt_TPWS_verify.outDirEdTxt,'String');
    REMORA.dt.TPWS.outDir = outDir;
    
elseif strcmp(action, 'setByFolder')
    byFolder = get(REMORA.dt_TPWS_verify.byFolderCheckBox,'Value');
    REMORA.dt.TPWS.byFolder = byFolder;
    
elseif strcmp(action, 'setbpEdgeMin')
    bpEdgeMin = get(REMORA.dt_TPWS_verify.bpEdgeMinEdTxt,'String');
    REMORA.dt.TPWS.bpRange(1) = bpEdgeMin;
    
elseif strcmp(action, 'setbpEdgeMax')
    bpEdgeMax = get(REMORA.dt_TPWS_verify.bpEdgeMaxEdTxt,'String');
    REMORA.dt.TPWS.bpRange(2) = bpEdgeMax;

elseif strcmp(action, 'setFft')
    fftSize = get(REMORA.dt_TPWS_verify.bpEdgeMaxEdTxt,'String');
    REMORA.dt.TPWS.fftSize = fftSize;    
    
elseif strcmp(action, 'setTFPath')
    tfFullFile = get(REMORA.dt_TPWS_verify.tfPathEdTxt,'String');
    REMORA.dt.TPWS.tfFullFile = tfFullFile;
    
elseif strcmp(action, 'setTPWSFilterString')
    filterString = get(REMORA.dt_TPWS_verify.filterStringEdTxt,'String');
    REMORA.dt.TPWS.filterString = filterString;
    
elseif strcmp(action, 'setTPWSminRL')
    ppThresh = get(REMORA.dt_TPWS_verify.minRLTxt,'String');
    if ~isempty(ppThresh)
        ppThresh = str2num(ppThresh);
        REMORA.dt.TPWS.ppThresh = ppThresh;
    else
        REMORA.dt.TPWS.ppThresh = [];
    end
    
elseif strcmp(action, 'setExclDet')
    exclDet = get(REMORA.dt_TPWS_verify.exclDetCheckbox,'Value');
    REMORA.dt.TPWS.exclDetections = exclDet;
    
elseif strcmp(action, 'run_mkTPWS')
    settings = settings_in_seconds(REMORA.dt.TPWS);
    dt_mkTPWS(settings)
end

function p = settings_in_seconds(settings)

p = settings;
p.frameLength = p.frameLength / 1000; 
p.timeseriesLength = p.timeseriesLength / 1000; 
p.framebuffer = p.framebuffer / 1000; 
p.clickbuffer = p.clickbuffer / 1000; 



