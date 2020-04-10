function bm_pulldown(action)
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
    bm_setpointers('watch');
    
    % set up to open gui window for batch detector
    bm_init_batch_figure
    bm_init_settings
    
    % set up all default settings to motion gui
    bm_init_batch_gui
    
     bm_setpointers('arrow');
% elseif strcmp(action,'create_labels')
%     
%     % load text file and create .tlab file 
%     sh_create_tlab_file
    
elseif strcmp(action,'load_labels')
    
    % set up to open gui window for motion detector
    bm_init_visLabel_figure
    
    % set motion gui for detection lables
    bm_init_visLabel_gui
    
elseif strcmp(action,'evaluate_detections')
    
    %launch evaluation gui
    bm_evaluate
    
end


function bm_setpointers(icon)
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



