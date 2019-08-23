global REMORA HANDLES

% initialization script for clustering tool remora

REMORA.ct.menu = uimenu(HANDLES.remmenu,'Label','&Cluster Tool',...
    'Enable','on','Visible','on');

% Run cluster bins
uimenu(REMORA.ct.menu, 'Label', 'Cluster Bins', ...
    'Callback', 'ct_pulldown(''cluster_bins'')');
% Run composite clusters
uimenu(REMORA.ct.menu, 'Label', 'Composite Clusters', ...
    'Callback', 'ct_pulldown(''composite_clusters'')');

uimenu(REMORA.spice_dt.menu, 'Label', 'Post-clustering Options', ...
    'Callback', 'ct_pulldown(''post_cluster'')');

