function lt_pulldown(action)

%%%%initializes pulldowns for label tracker 

global PARAMS REMORA 


if strcmp(action,'create_tlabs')
    REMORA.lt.tLab_params = lt_tLab_init_settings;
    lt_init_mk_tLab_window
    
elseif strcmp(action,'visualize_labels')
    REMORA.lt.lVis_params = lt_lVis_init_settings;
    lt_init_lVis_window
    
    %initialize settings needed for plotting
    REMORA.lt.lVis_det.detection.PlotLabels = false;
    REMORA.lt.lVis_det.detection2.PlotLabels = false;
    REMORA.lt.lVis_det.detection3.PlotLabels = false;
    REMORA.lt.lVis_det.detection4.PlotLabels = false;
end