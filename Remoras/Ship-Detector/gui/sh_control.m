function sh_control(action)

global REMORA

if strcmp(action, '')
% Note: could make this have an option to just refresh everything by making
% these all into if rather than elseif

elseif strcmp(action,'setOutDir')
    outDir = get(REMORA.sh_verify.outDirEdTxt, 'string');
    REMORA.sh.settings.outDir = outDir;
    
elseif strcmp(action,'setTFPath')
    tfFullFile = get(REMORA.sh_verify.TFPathEdTxt, 'string');
    REMORA.sh.settings.tfFullFile = tfFullFile;   
    
elseif strcmp(action,'setMinLowBand')
    MinLowBandEdText = get(REMORA.sh_verify.MinlowBandEdText, 'string');
    REMORA.sh.settings.lowBand(1) = MinLowBandEdText;   
    
elseif strcmp(action,'setMaxLowBand')
    MaxLowBandEdText = get(REMORA.sh_verify.MaxlowBandEdText, 'string');
    REMORA.sh.settings.lowBand(2) = MaxLowBandEdText;     
    
elseif strcmp(action,'setMinMediumBand')
    MinMediumBandEdText = get(REMORA.sh_verify.MinMediumBandEdText, 'string');
    REMORA.sh.settings.mediumBand(1) = MinMediumBandEdText;   
    
elseif strcmp(action,'setMaxMediumBand')
    MaxMediumBandEdText = get(REMORA.sh_verify.MaxMediumBandEdText, 'string');
    REMORA.sh.settings.mediumBand(2) = MaxMediumBandEdText;  
    
elseif strcmp(action,'setMinHighBand')
    MinHighBandEdText = get(REMORA.sh_verify.MinHighBandEdText, 'string');
    REMORA.sh.settings.highBand(1) = MinHighBandEdText;   
    
elseif strcmp(action,'setMaxHighBand')
    MaxHighBandEdText = get(REMORA.sh_verify.MaxHighBandEdText, 'string');
    REMORA.sh.settings.highBand(2) = MaxHighBandEdText;  
    
elseif strcmp(action,'setThrClose')
    ThrCloseEdTxt = str2double(get(REMORA.sh_verify.ThrCloseEdTxt, 'string'));
    REMORA.sh.settings.thrClose = ThrCloseEdTxt;
    
elseif strcmp(action,'setThrDistant')
    ThrDistantEdTxt = str2double(get(REMORA.sh_verify.ThrDistantEdTxt, 'string'));
    REMORA.sh.settings.thrDistant = ThrDistantEdTxt; 
    
elseif strcmp(action,'setThrRL')
    ThrRLEdTxt = str2double(get(REMORA.sh_verify.ThrDistantEdTxt, 'string'));
    REMORA.sh.settings.thrRL = ThrRLEdTxt; 
    
elseif strcmp(action,'setMinPassage')
    MinPassageEdTxt = str2double(get(REMORA.sh_verify.MinPassageEdTxt, 'string'));
    REMORA.sh.settings.minPassage = MinPassageEdTxt;     

elseif strcmp(action,'setBuffer')
    BufferEdTxt = str2double(get(REMORA.sh_verify.BufferEdTxt, 'string'));
    REMORA.sh.settings.buffer = BufferEdTxt;   
    
elseif strcmp(action,'setLabelsFile')
    labelsCheckbox = get(REMORA.sh_verify.labelsCheckbox, 'Value');
    REMORA.sh.settings.saveLabels = labelsCheckbox;
    
elseif strcmp(action,'setDurWind')    
    DurWindEdTxt = get(REMORA.sh_verify.DurWindEdTxt, 'Value');
    REMORA.sh.settings.durWind = DurWindEdTxt; 
    
elseif strcmp(action,'setSlide')
    SlideEdTxt = get(REMORA.sh_verify.SlideEdTxt, 'string');
    REMORA.sh.settings.slide = SlideEdTxt;
    
elseif strcmp(action,'setErrorRange')
    ErrorRangeEdTxt = get(REMORA.sh_verify.ErrorRangeEdTxt, 'string');
    REMORA.sh.settings.errorRange = ErrorRangeEdTxt;

elseif strcmp(action,'setDutyCycle')
    dutyCycleCheckbox = get(REMORA.sh_verify.dutyCycleCheckbox, 'string');
    REMORA.sh.settings.dutyCycle = dutyCycleCheckbox;
    
elseif strcmp(action,'setDiskWrite')
    diskWriteCheckbox = get(REMORA.sh_verify.diskWriteCheckbox, 'string');
    REMORA.sh.settings.diskWrite = diskWriteCheckbox;
    
elseif strcmp(action,'setLabelFile')
    labelsCheckbox = get(REMORA.sh_verify.labelsCheckbox, 'string');
    REMORA.sh.settings.saveLabels = labelsCheckbox;
    
elseif strcmp(action,'RunBatchDetection')
    close(REMORA.fig.sh_verify)
    settings_in_seconds
    sh_init_ltsa_params;
    sh_detector_batch;
end

function settings_in_seconds

global REMORA

REMORA.sh.settings.minPassage = REMORA.sh.settings.minPassage * 60*60;
REMORA.sh.settings.buffer = REMORA.sh.settings.buffer * 60;
REMORA.sh.settings.durWind = REMORA.sh.settings.durWind * 60*60;
REMORA.sh.settings.slide = REMORA.sh.settings.slide * 60*60;

