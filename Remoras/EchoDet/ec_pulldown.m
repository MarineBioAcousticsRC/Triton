function ec_pulldown(action)

%%%%initializes pulldowns for label tracker

global PARAMS REMORA HANDLES

if strcmp(action, 'create_echoDet')
    %open window for starting echosounder detector
    EC_settings;
    REMORA.ec.ec_params = p;
    ec_init_window
    
elseif strcmp(action,'create_IDfiles')
    disp('doesnt work yet')
    
    
end