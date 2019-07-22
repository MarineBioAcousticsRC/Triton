function cluster_tool_pulldown(action)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% cluster_tool_pulldown.m
% initializes pulldowns for clustering tool
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS REMORA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if strcmp(action,'cluster_bins')
    
    ct_setpointers('watch');
    REMORA.ct.CB_params = ct_init_cluster_bins_settings;
    ct_init_clusterbins_batch_window
    
    ct_setpointers('arrow');
    
    
end



function ct_setpointers(icon)
global HANDLES
set(HANDLES.fig.ctrl, 'Pointer', icon);
set(HANDLES.fig.main, 'Pointer', icon);
set(HANDLES.fig.msg, 'Pointer', icon);
