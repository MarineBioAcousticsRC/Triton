function ct_pulldown(action)
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

    REMORA.ct.CB_params = ct_init_cluster_bins_settings;
    ct_init_clusterbins_batch_window  
    
elseif strcmp(action,'composite_clusters')
    
    REMORA.ct.CC_params = ct_init_composite_clusters_settings;
    ct_init_compClust_window
    
elseif strcmp(action,'post_cluster')
    
    ct_post_cluster_ui    

end
