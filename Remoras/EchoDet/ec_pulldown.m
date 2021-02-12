function ec_pulldown(action)

%%%%initializes pulldowns for label tracker

global REMORA HANDLES

if strcmp(action, 'create_echoDet')
    %open window for starting echosounder detector
    ec_settings;
    REMORA.ec.ec_params = p;
    ec_init_window
    
elseif strcmp(action,'create_IDfiles')
    p = ec_id_settings;
    REMORA.ec.id_params = p;
    ec_id_init_window
    
    
end