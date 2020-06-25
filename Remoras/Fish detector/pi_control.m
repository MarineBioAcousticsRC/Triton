function pi_control(action,~)

global REMORA


if strcmp(action, '')
    % Note: could make this have an option to just refresh everything by making
    % these all into if rather than elseif
    
elseif strcmp(action,'setInDir')
    inDir = get(REMORA.pi_verify.inDirEdTxt, 'string');
    REMORA.pi.settings.baseDir = inDir;
    
elseif strcmp(action,'setOutDir')
    outDir = get(REMORA.pi_verify.outDirEdTxt, 'string');
    REMORA.pi.settings.outDir = outDir;
    
elseif strcmp(action,'setThresh')
    ThreshEdText = str2double(get(REMORA.pi_verify.ThreshEdText, 'string'));
    REMORA.pi.settings.thresh = ThreshEdText;
    
elseif strcmp(action, 'setDiffS')
    diffsEdText = str2double(get(REMORA.pi_verify.diffsEdText, 'string'));
    REMORA.pi.settings.diff_s = diffsEdText;
    
elseif strcmp(action, 'setRmsASmin')
    rmsASminEdText = str2double(get(REMORA.pi_verify.rmsASminEdText, 'string'));
    REMORA.pi.settings.rmsASmin = rmsASminEdText;
    
elseif strcmp(action,'RunBatchDetection')
    close(REMORA.fig.pi.batch)
    pi_autodet_batch_ST;
end


