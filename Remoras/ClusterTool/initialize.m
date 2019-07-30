global REMORA HANDLES

% initialization script for clustering tool remora

REMORA.clusterTool.menu = uimenu(HANDLES.remmenu,'Label','&Cluster Tool',...
    'Enable','on','Visible','on');

% Run cluster bins
uimenu(REMORA.clusterTool.menu, 'Label', 'Cluster in bins', ...
    'Callback', 'cluster_tool_pulldown(''cluster_bins'')');
% Run composite clusters
uimenu(REMORA.clusterTool.menu, 'Label', 'Cluster across bins', ...
    'Callback', 'cluster_tool_pulldown(''composite_clusters'')');

% uimenu(REMORA.spice_dt.menu, 'Label', 'Convert detections to TPWS', ...
%     'Callback', 'cluster_tool_pulldown(''view_existing_clusters'')');

