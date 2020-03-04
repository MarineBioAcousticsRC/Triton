function bw_control(action,mySource)

global REMORA HANDLES

if ~exist('mySource','var')
    mySource = 'null';
end

if strcmp(action, '')
    % Note: could make this have an option to just refresh everything by making
    % these all into if rather than elseif
    
elseif strcmp(action,'setInDir')
    inDir = get(REMORA.bw_verify.inDirEdTxt, 'string');
    REMORA.bw.settings.inDir = inDir;
    
elseif strcmp(action,'setOutDir')
    outDir = get(REMORA.bw_verify.outDirEdTxt, 'string');
    REMORA.bw.settings.outDir = outDir;
        
elseif strcmp(action,'setThresh')
    ThreshEdText = str2double(get(REMORA.bw_verify.ThreshEdText, 'string'));
    REMORA.bw.settings.thresh = ThreshEdText;
    
elseif strcmp(action,'setSpecies')
    species.val = get(REMORA.bw_verify.SpeciesChoice, 'Value');
    species.opt = get(REMORA.bw_verify.SpeciesChoice,'string');
    SpeciesChoice = species.opt{species.val};
    REMORA.bw.settings.species = SpeciesChoice;
    
elseif strcmp(action,'setHARPdata')
    HARPdataCheckbox = get(REMORA.bw_verify.HARPdataCheckbox, 'string');
    REMORA.bw.settings.HARPdata = HARPdataCheckbox;
    
elseif strcmp(action,'setSoundTrapdata')
    SoundTrapdataCheckbox = get(REMORA.bw_verify.SoundTrapdataCheckbox, 'string');
    REMORA.bw.settings.SoundTrap = SoundTrapdataCheckbox;
    
elseif strcmp(action,'setCsvFile')
    csvCheckbox = get(REMORA.bw_verify.csvCheckbox, 'string');
    REMORA.bw.settings.saveCsv = csvCheckbox;
    
elseif strcmp(action,'RunBatchDetection')
    close(REMORA.fig.bw.batch)
    %bw_init_ltsa_params;
    %bw_autodet_batch_ST;
    bw_init_batch_detector;
end


