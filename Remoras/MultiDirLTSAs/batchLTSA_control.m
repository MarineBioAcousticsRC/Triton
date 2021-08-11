function batchLTSA_control(action, mySource)

global REMORA 

if ~exist('mySource','var')
    mySource = 'null';
end

if strcmp(action, '')
    % Note: could make this have an option to just refresh everything by making
    % these all into if rather than elseif
    
elseif strcmp(action,'setInDir')
    inDir = get(REMORA.batchLTSA_verify.inDirEdTxt, 'string');
    REMORA.batchLTSA.settings.inDir = inDir;
    
elseif strcmp(action, 'browseInDir')
    dir = uigetdir();
    if ~ isnumeric(dir)
        % user selected something
         set(REMORA.batchLTSA_verify.inDirEdTxt, 'string', dir);
        REMORA.batchLTSA.settings.inDir = dir;
    end
    elseif strcmp(action, 'setDataType')
    dataType = get(REMORA.fig.dataType_buttongroup.SelectedObject, 'Tag');
    REMORA.batchLTSA.settings.dataType = dataType;
  
elseif strcmp(action,'settave')
    tave = get(REMORA.batchLTSA_verify.taveEdTxt, 'string');
    REMORA.batchLTSA.settings.tave = tave;

elseif strcmp(action,'setdfreq')
    dfreq = get(REMORA.batchLTSA_verify.dfreqEdTxt, 'string');
    REMORA.batchLTSA.settings.dfreq = dfreq;

elseif strcmp(action,'RunBatchLTSA')
    close(REMORA.fig.batchLTSA)
    batchLTSA_init_batch_ltsa;
end


