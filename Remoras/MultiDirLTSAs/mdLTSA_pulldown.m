function mdLTSA_pulldown(action)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% mdLTSA_pulldown.m
% initializes pulldowns for batch LTSAs
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS REMORA HANDLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(action,'batch_ltsas')
    % dialog box - 
    mdLTSA_setpointers('watch');
    
    % set up to open gui window for batch detector
    mdLTSA_init_batch_figure
    mdLTSA_init_settings
    
    % set up all default settings to motion gui
    mdLTSA_init_batch_gui
    
    mdLTSA_setpointers('arrow');
    
end


function mdLTSA_setpointers(icon)
global HANDLES
set(HANDLES.fig.ctrl, 'Pointer', icon);
set(HANDLES.fig.main, 'Pointer', icon);
set(HANDLES.fig.msg, 'Pointer', icon);



