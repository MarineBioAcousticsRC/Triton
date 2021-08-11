function batchLTSA_pulldown(action)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% batchLTSA_pulldown.m
% initializes pulldowns for batch LTSAs
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS REMORA HANDLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(action,'batch_ltsas')
    % dialog box - 
    batchLTSA_setpointers('watch');
    
    % set up to open gui window for batch ltsa creation
    batchLTSA_init_figure
    batchLTSA_init_settings
    
    % set up all default settings to motion gui
    batchLTSA_init_gui
    
    batchLTSA_setpointers('arrow');
    
end


function batchLTSA_setpointers(icon)
global HANDLES
set(HANDLES.fig.ctrl, 'Pointer', icon);
set(HANDLES.fig.main, 'Pointer', icon);
set(HANDLES.fig.msg, 'Pointer', icon);



