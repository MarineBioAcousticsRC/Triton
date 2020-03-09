function bw_pulldown(action)
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
    % dialog box - run full detector
    bw_setpointers('watch');
    
    % set up to open gui window for batch detector
    bw_init_batch_figure
    bw_init_settings
    
    % set up all default settings to motion gui
    bw_init_batch_gui
    
     bw_setpointers('arrow');

end


function bw_setpointers(icon)
global HANDLES
set(HANDLES.fig.ctrl, 'Pointer', icon);
set(HANDLES.fig.main, 'Pointer', icon);
set(HANDLES.fig.msg, 'Pointer', icon);

%function update_window_settings
%global HANDLES REMORA
%set(HANDLES.ltsa.time.edtxt3,'string',REMORA.sh.settings.durWind)
%set(HANDLES.ltsa.time.edtxt4,'string',REMORA.sh.settings.slide)
%control_ltsa('newtseg') %change Triton plot length
%control_ltsa('newtstep') %change Triton time step 
% bring motion gui to front
%figure(REMORA.fig.sh.motion);



