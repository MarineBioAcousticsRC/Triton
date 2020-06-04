function bm_thresh_control(action,~)

global REMORA

if strcmp(action, '')
    % Note: could make this have an option to just refresh everything by making
    % these all into if rather than elseif
    
elseif strcmp(action,'setInDir')
    inDir = get(REMORA.bm.thresh_verify.inDirEdTxt, 'string');
    REMORA.bm.settings.inDir = inDir;
    
elseif strcmp(action,'setOutDir')
    outDir = get(REMORA.bm.thresh_verify.outDirEdTxt, 'string');
    REMORA.bm.settings.outDir = outDir;
    
elseif strcmp(action, 'setStartF1')
    startF1EdText = str2double(get(REMORA.bm.thresh_verify.StartF1EdText, 'string'));
    REMORA.bm.settings.startF(1,1) = startF1EdText;
    
elseif strcmp(action, 'setStartF2')
    startF2EdText = str2double(get(REMORA.bm.thresh_verify.StartF2EdText, 'string'));
    REMORA.bm.settings.startF(1,2) = startF2EdText;

elseif strcmp(action, 'setStartF3')
    startF3EdText = str2double(get(REMORA.bm.thresh_verify.StartF3EdText, 'string'));
    REMORA.bm.settings.startF(1,3) = startF3EdText;

elseif strcmp(action, 'setStartF4')
    startF4EdText = str2double(get(REMORA.bm.thresh_verify.StartF4EdText, 'string'));
    REMORA.bm.settings.startF(1,4) = startF4EdText;

elseif strcmp(action, 'setEndF1')
    endF1EdText = str2double(get(REMORA.bm.thresh_verify.EndF1EdText, 'string'));
    REMORA.bm.settings.endF(1,1) = endF1EdText;
    
elseif strcmp(action, 'setEndF2')
    endF2EdText = str2double(get(REMORA.bm.thresh_verify.EndF2EdText, 'string'));
    REMORA.bm.settings.endF(1,2) = endF2EdText;

elseif strcmp(action, 'setEndF3')
    endF3EdText = str2double(get(REMORA.bm.thresh_verify.EndF3EdText, 'string'));
    REMORA.bm.settings.endF(1,3) = endF3EdText;

elseif strcmp(action, 'setEndF4')
    endF4EdText = str2double(get(REMORA.bm.thresh_verify.EndF4EdText, 'string'));
    REMORA.bm.settings.endF(1,4) = endF4EdText;
    
elseif strcmp(action,'setTMin')
    tmin = str2double(get(REMORA.bm.thresh_verify.tminEdTxt, 'string'));
    REMORA.bm.settings.tmin = tmin;
    
elseif strcmp(action,'setTMax')
    tmax = str2double(get(REMORA.bm.thresh_verify.tmaxEdTxt, 'string'));
    REMORA.bm.settings.tmax = tmax;
    
elseif strcmp(action,'setStSize')
    stsize = str2double(get(REMORA.bm.thresh_verify.stsizeEdTxt,'string'));
    REMORA.bm.settings.stsize = stsize;
    
elseif strcmp(action,'RunThreshCalc')
    close(REMORA.fig.bm.thresh)
    bm_init_threshcalc
end

