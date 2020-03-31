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
        
elseif strcmp(action,'setThresh')
    ThreshEdText = str2double(get(REMORA.bm_verify.ThreshEdText, 'string'));
    REMORA.bm.settings.thresh = ThreshEdText;
    
elseif strcmp(action,'setSpecies')
    species.val = get(REMORA.bm_verify.SpeciesChoice, 'Value');
    species.opt = get(REMORA.bm_verify.SpeciesChoice,'string');
    SpeciesChoice = species.opt{species.val};
    REMORA.bm.settings.species = SpeciesChoice;
    
elseif strcmp(action,'setHARPdata')
    HARPdataCheckbox = get(REMORA.bm_verify.HARPdataCheckbox, 'string');
    REMORA.bm.settings.HARPdata = HARPdataCheckbox;
    
elseif strcmp(action,'setSoundTrapdata')
    SoundTrapdataCheckbox = get(REMORA.bm_verify.SoundTrapdataCheckbox, 'string');
    REMORA.bm.settings.SoundTrap = SoundTrapdataCheckbox;
    
elseif strcmp(action,'setCsvFile')
    csvCheckbox = get(REMORA.bm_verify.csvCheckbox, 'string');
    REMORA.bm.settings.saveCsv = csvCheckbox;
    
elseif strcmp(action,'RunBatchDetection')
    close(REMORA.fig.bm.batch)
    %bm_init_ltsa_params;
    %bm_autodet_batch_ST;
    bm_init_batch_detector;
end


