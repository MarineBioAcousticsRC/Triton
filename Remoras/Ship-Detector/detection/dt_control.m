function dt_control(action,mySource)
global REMORA

if strcmp(action, '')
% Note: could make this have an option to just refresh everything by making
% these all into if rather than elseif

elseif strcmp(action,'setOutDir')
    outDir = get(REMORA.spice_dt_verify.outDirEdTxt, 'string');
    REMORA.ship_dt.settings.outDir = outDir;
    
elseif strcmp(action,'setTFPath')
    tfFullFile = get(REMORA.spice_dt_verify.TFPathEdTxt, 'string');
    REMORA.ship_dt.settings.tfFullFile = tfFullFile;   
    
elseif strcmp(action,'setMinLowBand')
    MinLowBandEdText = get(REMORA.spice_dt_verify.MinlowBandEdText, 'string');
    REMORA.ship_dt.settings.lowBand(1) = MinLowBandEdText;   
    
elseif strcmp(action,'setMaxLowBand')
    MaxLowBandEdText = get(REMORA.spice_dt_verify.MaxlowBandEdText, 'string');
    REMORA.ship_dt.settings.lowBand(2) = MaxLowBandEdText;     
    
elseif strcmp(action,'setMinMediumBand')
    MinMediumBandEdText = get(REMORA.spice_dt_verify.MinMediumBandEdText, 'string');
    REMORA.ship_dt.settings.mediumBand(1) = MinMediumBandEdText;   
    
elseif strcmp(action,'setMaxMediumBand')
    MaxMediumBandEdText = get(REMORA.spice_dt_verify.MaxMediumBandEdText, 'string');
    REMORA.ship_dt.settings.mediumBand(2) = MaxMediumBandEdText;  
    
elseif strcmp(action,'setMinHighBand')
    MinHighBandEdText = get(REMORA.spice_dt_verify.MinHighBandEdText, 'string');
    REMORA.ship_dt.settings.highBand(1) = MinHighBandEdText;   
    
elseif strcmp(action,'setMaxHighBand')
    MaxHighBandEdText = get(REMORA.spice_dt_verify.MaxHighBandEdText, 'string');
    REMORA.ship_dt.settings.highBand(2) = MaxHighBandEdText;  
    
elseif strcmp(action,'setThrClose')
    ThrCloseEdTxt = str2double(get(REMORA.spice_dt_verify.ThrCloseEdTxt, 'string'));
    REMORA.ship_dt.settings.thrClose = ThrCloseEdTxt;
    
elseif strcmp(action,'setThrDistant')
    ThrDistantEdTxt = str2double(get(REMORA.spice_dt_verify.ThrDistantEdTxt, 'string'));
    REMORA.ship_dt.settings.thrDistant = ThrDistantEdTxt; 
    
elseif strcmp(action,'setThrRL')
    ThrRLEdTxt = str2double(get(REMORA.spice_dt_verify.ThrDistantEdTxt, 'string'));
    REMORA.ship_dt.settings.thrRL = ThrRLEdTxt; 
    
elseif strcmp(action,'setLabelsFile')
    labelsCheckbox = get(REMORA.spice_dt_verify.labelsCheckbox, 'Value');
    REMORA.ship_dt.settings.saveLabels = labelsCheckbox;
    
elseif strcmp(action,'setDurWind')    
    DurWindEdTxt = get(REMORA.spice_dt_verify.DurWindEdTxt, 'Value');
    REMORA.ship_dt.settings.durWind = DurWindEdTxt; 
    
elseif strcmp(action,'setSlide')
    SlideEdTxt = get(REMORA.spice_dt_verify.SlideEdTxt, 'string');
    REMORA.ship_dt.settings.slide = SlideEdTxt;
    
elseif strcmp(action,'setErrorRange')
    ErrorRangeEdTxt = get(REMORA.spice_dt_verify.ErrorRangeEdTxt, 'string');
    REMORA.ship_dt.settings.errorRange = ErrorRangeEdTxt;
    
elseif strcmp(action,'RunBatchDetection')
    dt_runLtsaDetector()
end

% if strcmp(mySource, 'gui')
%     dt_gui
%     sp_plot_detections
% end

