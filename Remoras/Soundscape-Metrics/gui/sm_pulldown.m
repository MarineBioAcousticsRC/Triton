function sm_pulldown(action)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% sm_pulldown.m
% initializes pulldowns for soundscape metrics calculation
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS REMORA HANDLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(action, 'make_ltsa')
    sm_setpointers('watch');
    
    sm_settings_init_ltsa;
    
    REMORA.sm.ltsa = PARAMS.ltsa;
    if ~isfield(REMORA,'fig')
        REMORA.fig = [];
    end
    
    %initialize ltsa parameters
    sm_ltsa_params_window;
    
    sm_setpointers('arrow');
        
elseif strcmp(action,'compute_metrics')
    % dialog box - compute metrics
    sm_setpointers('watch');
    
    REMORA.sm.mkltsa_params = sm_init_mkltsa_settings; %load default settings
    % dialog box - make ltsa
    if ~isfield(REMORA,'fig')
        REMORA.fig = [];
    end
    

    sm_init_metrics_params_window
    
    % set up to open gui window for batch detector
    sm_init_batch_figure
    sm_init_settings
    
    % set up all default settings to motion gui
    sm_init_batch_gui
    sm_settings_to_sec
    
    sm_setpointers('arrow');

end


function sm_setpointers(icon)
global HANDLES
set(HANDLES.fig.ctrl, 'Pointer', icon);
set(HANDLES.fig.main, 'Pointer', icon);
set(HANDLES.fig.msg, 'Pointer', icon);

% function update_window_settings
% global HANDLES REMORA
% set(HANDLES.ltsa.time.edtxt3,'string',REMORA.sh.settings.durWind)
% set(HANDLES.ltsa.time.edtxt4,'string',REMORA.sh.settings.slide)
% control_ltsa('newtseg') %change Triton plot length
% control_ltsa('newtstep') %change Triton time step 
% % bring motion gui to front
% figure(REMORA.fig.sh.motion);



