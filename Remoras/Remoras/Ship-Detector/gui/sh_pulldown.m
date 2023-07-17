function sh_pulldown(action)
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

if strcmp(action, 'interactive')
    % dialog box - interactive spectrogram detector
    if isempty(PARAMS.ltsa.infile)
        % no data loaded, display message to load data.
        disp_msg('Please load ltsa file before launching detector gui')
        return
    end
    sh_setpointers('watch');
    
    % set up to open gui window for motion detector
    sh_init_motion_figure
    sh_init_settings
    
    % When, gui window open, update window and time step (sliding window) 
    % in Control Triton window based on settings file
    update_window_settings
    
    % set up all default settings to motion gui
    sh_init_motion_gui
    sh_settings_to_sec
    
    sh_setpointers('arrow');
        
elseif strcmp(action,'full_detector')
    % dialog box - run full detector
    sh_setpointers('watch');
    
    % set up to open gui window for batch detector
    sh_init_batch_figure
    sh_init_settings
    
    % set up all default settings to motion gui
    sh_init_batch_gui
    sh_settings_to_sec
    
    sh_setpointers('arrow');

elseif strcmp(action,'create_labels')
    
    % load text file and create .tlab file 
    sh_create_tlab_file
    
elseif strcmp(action,'load_labels')
    
    % set up to open gui window for motion detector
    sh_init_visLabel_figure
    
    % set motion gui for detection lables
    sh_init_visLabel_gui

elseif strcmp(action,'evaluate_detections')
    
    % launch evaluation gui
    sh_evaluate
end


function sh_setpointers(icon)
global HANDLES
set(HANDLES.fig.ctrl, 'Pointer', icon);
set(HANDLES.fig.main, 'Pointer', icon);
set(HANDLES.fig.msg, 'Pointer', icon);

function update_window_settings
global HANDLES REMORA
set(HANDLES.ltsa.time.edtxt3,'string',REMORA.sh.settings.durWind)
set(HANDLES.ltsa.time.edtxt4,'string',REMORA.sh.settings.slide)
control_ltsa('newtseg') %change Triton plot length
control_ltsa('newtstep') %change Triton time step 
% bring motion gui to front
figure(REMORA.fig.sh.motion);



