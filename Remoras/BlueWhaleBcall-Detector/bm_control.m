function bm_control(action,mySource)

global REMORA HANDLES

if ~exist('mySource','var')
    mySource = 'null';
end

if strcmp(action, '')
    % Note: could make this have an option to just refresh everything by making
    % these all into if rather than elseif
    
elseif strcmp(action,'setInDir')
    inDir = get(REMORA.bm_verify.inDirEdTxt, 'string');
    REMORA.bm.settings.inDir = inDir;
    
elseif strcmp(action,'setOutDir')
    outDir = get(REMORA.bm_verify.outDirEdTxt, 'string');
    REMORA.bm.settings.outDir = outDir;
      
elseif strcmp(action,'setRegDate')
    regdate = get(REMORA.bm_verify.regdateEdTxt, 'string');
    REMORA.bm.settings.regdate = regdate;
    
elseif strcmp(action,'setThresh')
    ThreshEdText = str2double(get(REMORA.bm_verify.ThreshEdText, 'string'));
    REMORA.bm.settings.thresh = ThreshEdText;
    
elseif strcmp(action, 'setStartF1')
    startF1EdText = str2double(get(REMORA.bm_verify.StartF1EdText, 'string'));
    REMORA.bm.settings.startF(1,1) = startF1EdText;
    
elseif strcmp(action, 'setStartF2')
    startF2EdText = str2double(get(REMORA.bm_verify.StartF2EdText, 'string'));
    REMORA.bm.settings.startF(1,2) = startF2EdText;

elseif strcmp(action, 'setStartF3')
    startF3EdText = str2double(get(REMORA.bm_verify.StartF3EdText, 'string'));
    REMORA.bm.settings.startF(1,3) = startF3EdText;

elseif strcmp(action, 'setStartF4')
    startF4EdText = str2double(get(REMORA.bm_verify.StartF4EdText, 'string'));
    REMORA.bm.settings.startF(1,4) = startF4EdText;

elseif strcmp(action, 'setEndF1')
    endF1EdText = str2double(get(REMORA.bm_verify.EndF1EdText, 'string'));
    REMORA.bm.settings.endF(1,1) = endF1EdText;
    
elseif strcmp(action, 'setEndF2')
    endF2EdText = str2double(get(REMORA.bm_verify.EndF2EdText, 'string'));
    REMORA.bm.settings.endF(1,2) = endF2EdText;

elseif strcmp(action, 'setEndF3')
    endF3EdText = str2double(get(REMORA.bm_verify.EndF3EdText, 'string'));
    REMORA.bm.settings.endF(1,3) = endF3EdText;

elseif strcmp(action, 'setEndF4')
    endF4EdText = str2double(get(REMORA.bm_verify.EndF4EdText, 'string'));
    REMORA.bm.settings.endF(1,4) = endF4EdText;

elseif strcmp(action,'setSpecies')
    species.val = get(REMORA.bm_verify.SpeciesChoice, 'Value');
    species.opt = get(REMORA.bm_verify.SpeciesChoice,'string');
    SpeciesChoice = species.opt{species.val};
    REMORA.bm.settings.species = SpeciesChoice;
    
elseif strcmp(action,'setDataType')
    datatype.val = get(REMORA.bm_verify.DataChoice, 'Value');
    datatype.opt = get(REMORA.bm_verify.DataChoice,'string');
    DataChoice = datatype.opt{datatype.val};
    REMORA.bm.settings.datatype = DataChoice;
    
elseif strcmp(action,'setCsvFile')
    csvCheckbox = get(REMORA.bm_verify.csvCheckbox, 'string');
    REMORA.bm.settings.saveCsv = csvCheckbox;
    
elseif strcmp(action,'RunBatchDetection')
    close(REMORA.fig.bm.batch)
    %bm_init_ltsa_params;
    %bm_autodet_batch_ST;
    bm_init_batch_detector;
end


