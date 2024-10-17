function cc_pulldown(action)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% made by SGB 20240717
% Shelby G. Bloom (sbloom@ucsd.edu)
% modified/based on Soundscape-Metrics Remora gui folder code by Simone Baumann-Pickering
%
%
% cc_pulldown.m
% initializes pulldowns for countCOFI calculation
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS REMORA HANDLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(action, 'countCOFI')
    % Set the pointer to 'watch' to indicate a process is running
    cc_setpointers('watch');
   
    % Initialize concatenate settings
    cc_count_settings_init;
    
    % Check if REMORA.fig field exists; if not, initialize it
    if ~isfield(REMORA, 'fig')
        REMORA.fig = [];
    end
    
    % Initialize countCOFI table file parameters window
    cc_count_params_window;
    
    % Reset the pointer to 'arrow' to indicate process completion
    cc_setpointers('arrow'); 

    
elseif strcmp(action, 'concatenate')
    % Set the pointer to 'watch' to indicate a process is running
    cc_setpointers('watch');
   
    % Initialize concatenate settings
    cc_conc_settings_init;
    
    % Check if REMORA.fig field exists; if not, initialize it
    if ~isfield(REMORA, 'fig')
        REMORA.fig = [];
    end
    
    % Initialize concatenate daily expanded files parameters window
    cc_conc_params_window;
    
    % Reset the pointer to 'arrow' to indicate process completion
    cc_setpointers('arrow');  
    
    
elseif strcmp(action, 'visEffort')
    % Set the pointer to 'watch' to indicate a process is running
    cc_setpointers('watch');
   
    % Initialize concatenate settings
    cc_vis_settings_init;
    
    % Check if REMORA.fig field exists; if not, initialize it
    if ~isfield(REMORA, 'fig')
        REMORA.fig = [];
    end
    
    % Initialize concatenate daily expanded files parameters window
    cc_vis_params_window;
    
    % Reset the pointer to 'arrow' to indicate process completion
    cc_setpointers('arrow'); 
    
    
elseif strcmp(action, 'gmtmaps')
    % Set the pointer to 'watch' to indicate a process is running
    cc_setpointers('watch');
   
    % Initialize concatenate settings
    cc_gmt_settings_init;
    
    % Check if REMORA.fig field exists; if not, initialize it
    if ~isfield(REMORA, 'fig')
        REMORA.fig = [];
    end
    
    % Initialize concatenate daily expanded files parameters window
    cc_gmt_params_window;
    
    % Reset the pointer to 'arrow' to indicate process completion
    cc_setpointers('arrow'); 
end    
    
function cc_setpointers(icon)
global HANDLES
set(HANDLES.fig.ctrl, 'Pointer', icon);
set(HANDLES.fig.main, 'Pointer', icon);
set(HANDLES.fig.msg, 'Pointer', icon);
