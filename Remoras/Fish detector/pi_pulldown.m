function pi_pulldown(action)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% sh_pulldown.m
% initializes pulldowns for ship detector
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS REMORA HANDLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(action,'full_detector')
        
    % set up to open gui window for batch detector
    pi_init_batch_figure
    pi_default_settings
    
    % set up all default settings to motion gui
    pi_init_batch_gui
    
end


% function bm_setpointers(icon)
% global HANDLES
% set(HANDLES.fig.ctrl, 'Pointer', icon);
% set(HANDLES.fig.main, 'Pointer', icon);
% set(HANDLES.fig.msg, 'Pointer', icon);

%function update_window_settings
%global HANDLES REMORA
%set(HANDLES.ltsa.time.edtxt3,'string',REMORA.sh.settings.durWind)
%set(HANDLES.ltsa.time.edtxt4,'string',REMORA.sh.settings.slide)
%control_ltsa('newtseg') %change Triton plot length
%control_ltsa('newtstep') %change Triton time step 
% bring motion gui to front
%figure(REMORA.fig.sh.motion);



