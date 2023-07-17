function sh_control(action,mySource)

global REMORA HANDLES

if ~exist('mySource','var')
    mySource = 'null';
end

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
    MinLowBand = str2double(get(REMORA.sh_verify.MinLowBandEdText, 'string'));
    MaxLowBand = str2double(get(REMORA.sh_verify.MaxLowBandEdText, 'string'));
    REMORA.sh.settings.lowBand = [MinLowBand, MaxLowBand];
    
elseif strcmp(action,'setMaxLowBand')
    MinLowBand = str2double(get(REMORA.sh_verify.MinLowBandEdText, 'string'));
    MaxLowBand = str2double(get(REMORA.sh_verify.MaxLowBandEdText, 'string'));
    REMORA.sh.settings.lowBand = [MinLowBand, MaxLowBand];
    
elseif strcmp(action,'setMinMediumBand')
    MinMediumBand = str2double(get(REMORA.sh_verify.MinMediumBandEdText, 'string'));
    MaxMediumBand = str2double(get(REMORA.sh_verify.MaxMediumBandEdText, 'string'));
    REMORA.sh.settings.mediumBand = [MinMediumBand,MaxMediumBand];
    
elseif strcmp(action,'setMaxMediumBand')
    MinMediumBand = str2double(get(REMORA.sh_verify.MinMediumBandEdText, 'string'));
    MaxMediumBand = str2double(get(REMORA.sh_verify.MaxMediumBandEdText, 'string'));
    REMORA.sh.settings.mediumBand = [MinMediumBand,MaxMediumBand];
    
elseif strcmp(action,'setMinHighBand')
    MinHighBand = str2double(get(REMORA.sh_verify.MinHighBandEdText, 'string'));
    MaxHighBand = str2double(get(REMORA.sh_verify.MaxHighBandEdText, 'string'));
    REMORA.sh.settings.highBand = [MinHighBand,MaxHighBand];
    
elseif strcmp(action,'setMaxHighBand')
    MinHighBand = str2double(get(REMORA.sh_verify.MinHighBandEdText, 'string'));
    MaxHighBand = str2double(get(REMORA.sh_verify.MaxHighBandEdText, 'string'));
    REMORA.sh.settings.highBand = [MinHighBand,MaxHighBand];
    
elseif strcmp(action,'setThrClose')
    ThrCloseEdTxt = str2double(get(REMORA.sh_verify.ThrCloseEdTxt, 'string'));
    REMORA.sh.settings.thrClose = ThrCloseEdTxt;
    
elseif strcmp(action,'setThrDistant')
    ThrDistantEdTxt = str2double(get(REMORA.sh_verify.ThrDistantEdTxt, 'string'));
    REMORA.sh.settings.thrDistant = ThrDistantEdTxt;
    
elseif strcmp(action,'setThrRL')
    ThrRLEdTxt = str2double(get(REMORA.sh_verify.ThrRLEdTxt, 'string'));
    REMORA.sh.settings.thrRL = ThrRLEdTxt;
    
elseif strcmp(action,'setMinPassage')
    MinPassageEdTxt = str2double(get(REMORA.sh_verify.MinPassageEdTxt, 'string'));
    REMORA.sh.settings.minPassage = MinPassageEdTxt  * (60 * 60); % convert from hours to seconds
    
elseif strcmp(action,'setBuffer')
    BufferEdTxt = str2double(get(REMORA.sh_verify.BufferEdTxt, 'string'));
    REMORA.sh.settings.buffer = BufferEdTxt  * 60; % convert from minutes to seconds
    
elseif strcmp(action,'setLabelsFile')
    labelsCheckbox = get(REMORA.sh_verify.labelsCheckbox, 'Value');
    REMORA.sh.settings.saveLabels = labelsCheckbox;
    
elseif strcmp(action,'setDurWind')
    DurWindEdTxt = str2double(get(REMORA.sh_verify.DurWindEdTxt, 'string'));
    REMORA.sh.settings.durWind = DurWindEdTxt  * (60 * 60); % convert from hours to seconds
    if strcmp(mySource, 'motion')
        set(HANDLES.ltsa.time.edtxt3,'string',DurWindEdTxt)
        control_ltsa('newtseg') %change Triton window
        % bring motion gui to front
        figure(REMORA.fig.sh.motion);
    end
    
elseif strcmp(action,'setSlide')
    SlideEdTxt = str2double(get(REMORA.sh_verify.SlideEdTxt, 'string'));
    REMORA.sh.settings.slide = SlideEdTxt  * (60 * 60); % convert from hours to seconds
    if strcmp(mySource, 'motion')
        set(HANDLES.ltsa.time.edtxt4,'string',SlideEdTxt)
        control_ltsa('newtstep') %change Triton window
        % bring motion gui to front
        figure(REMORA.fig.sh.motion);
    end
    
elseif strcmp(action,'setDutyCycle')
    dutyCycleCheckbox = get(REMORA.sh_verify.dutyCycleCheckbox, 'string');
    REMORA.sh.settings.dutyCycle = dutyCycleCheckbox;
    
elseif strcmp(action,'setDiskWrite')
    diskWriteCheckbox = get(REMORA.sh_verify.diskWriteCheckbox, 'string');
    REMORA.sh.settings.diskWrite = diskWriteCheckbox;
    
elseif strcmp(action,'setCsvFile')
    csvCheckbox = get(REMORA.sh_verify.csvCheckbox, 'string');
    REMORA.sh.settings.saveCsv = csvCheckbox;
    
elseif strcmp(action,'RunBatchDetection')
    close(REMORA.fig.sh.batch)
    sh_init_ltsa_params;
    sh_detector_batch;
end

if strcmp(mySource, 'motion')
    sh_detector_motion
end
