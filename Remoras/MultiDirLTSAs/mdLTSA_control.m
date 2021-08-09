function mdLTSA_control(action,mySource)

global REMORA HANDLES

if ~exist('mySource','var')
    mySource = 'null';
end

if strcmp(action, '')
    % Note: could make this have an option to just refresh everything by making
    % these all into if rather than elseif
    
elseif strcmp(action,'setInDir')
    inDir = get(REMORA.mdLTSA_verify.inDirEdTxt, 'string');
    REMORA.mdLTSA.settings.inDir = inDir;
    
elseif strcmp(action, 'browseInDir')
    dir = uigetdir();
    if ~ isnumeric(dir)
        % user selected something
         set(REMORA.mdLTSA_verify.inDirEdTxt, 'string', dir);
        REMORA.mdLTSA.settings.inDir = dir;
    end
    elseif strcmp(action, 'setDataType')
    dataType = get(REMORA.fig.mdLTSA.dataType_buttongroup.SelectedObject, 'Tag');
    REMORA.mdLTSA.settings.dataType = dataType;
  
elseif strcmp(action,'settave')
    tave = get(REMORA.mdLTSA_verify.taveEdTxt, 'string');
    REMORA.mdLTSA.settings.tave = tave;

elseif strcmp(action,'setdfreq')
    dfreq = get(REMORA.mdLTSA_verify.dfreqEdTxt, 'string');
    REMORA.mdLTSA.settings.dfreq = dfreq;

elseif strcmp(action,'RunBatchLTSA')
    close(REMORA.fig.mdLTSA.batch)
    mdLTSA_init_batch_ltsa;
end


