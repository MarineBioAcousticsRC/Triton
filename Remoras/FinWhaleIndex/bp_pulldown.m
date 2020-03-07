function bp_pulldown(action)
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

if  strcmp(action,'full_detector')
    % dialog box - run full detector
    bp_setpointers('watch');
    
    % set up to open gui window for batch detector
    bp_init_batch_figure
    bp_init_settings
    
    % set up all default settings to motion gui
    bp_init_batch_gui
    bp_settings_to_sec
    
    bp_setpointers('arrow');

end


function bp_setpointers(icon)
global HANDLES
set(HANDLES.fig.ctrl, 'Pointer', icon);
set(HANDLES.fig.main, 'Pointer', icon);
set(HANDLES.fig.msg, 'Pointer', icon);

function update_window_settings
global HANDLES REMORA
set(HANDLES.ltsa.time.edtxt3,'string',REMORA.bp.settings.durWind)
set(HANDLES.ltsa.time.edtxt4,'string',REMORA.bp.settings.slide)
control_ltsa('newtseg') %change Triton plot length
control_ltsa('newtstep') %change Triton time step 
% bring motion gui to front
figure(REMORA.fig.bp.motion);



