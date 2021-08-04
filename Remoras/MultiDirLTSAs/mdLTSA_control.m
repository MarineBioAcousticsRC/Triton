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
    
    
% 
% 
% elseif strcmp(action,'setSpecies')
%     species.val = get(REMORA.bm_verify.SpeciesChoice, 'Value');
%     species.opt = get(REMORA.bm_verify.SpeciesChoice,'string');
%     SpeciesChoice = species.opt{species.val};
%     REMORA.bm.settings.species = SpeciesChoice;
%     
% elseif strcmp(action,'setXWAVdata')
%     XWAVdataCheckbox = get(REMORA.mdLTSA_verify.XWAVCheckbox, 'string');
%     REMORA.mdLTSA.settings.XWAVdata = XWAVdataCheckbox;
% 
% elseif strcmp(action,'setWAVdata')
%     WAVdataCheckbox = get(REMORA.mdLTSA_verify.WAVCheckbox, 'string');
%     REMORA.mdLTSA.settings.WAVdata = WAVdataCheckbox;

elseif strcmp(action, 'setDataType')
    dataType = get(REMORA.fig.mdLTSA.dataType_buttongroup.SelectedObject, 'Tag');
    REMORA.mdLTSA.settings.dataType = dataType;
    
elseif strcmp(action,'RunBatchLTSA')
    close(REMORA.fig.mdLTSA.batch)
    mdLTSA_init_batch_detector;
end


