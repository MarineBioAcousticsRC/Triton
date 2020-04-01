function lt_pulldown(action)

%%%%initializes pulldowns for label tracker 

global PARAMS REMORA 


if strcmp(action,'create_tlabs')
    REMORA.lt.tLab_params = lt_tLab_init_settings;
    lt_init_mk_tLab_window
    
elseif strcmp(action,'visualize_labels')
    disp('Im afraid I cant do that sire...')
end 