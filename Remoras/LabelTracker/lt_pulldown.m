function lt_pulldown(action)

%%%%initializes pulldowns for label tracker 

global PARAMS REMORA 

if strcmp(action, 'create_tlabs_txt')
    %load text file and create tlab, taken from ship detector
    lt_sh_create_tlab_file
    
elseif strcmp(action,'create_tlabs_detEdit')
    %load file from some sort of detEdit output, create tlab
    REMORA.lt.tLab_params = lt_tLab_init_settings;
    lt_init_mk_tLab_window
    
elseif strcmp(action,'visualize_labels')
    %visualize tlabs for plotting
    REMORA.lt.lVis_params = lt_lVis_init_settings;
    lt_init_lVis_window
    
    %initialize settings needed for plotting
    REMORA.lt.lVis_det.detection.PlotLabels = false;
    REMORA.lt.lVis_det.detection2.PlotLabels = false;
    REMORA.lt.lVis_det.detection3.PlotLabels = false;
    REMORA.lt.lVis_det.detection4.PlotLabels = false;
end