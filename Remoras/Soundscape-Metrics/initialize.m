
global REMORA HANDLES

REMORA.sh.menu = uimenu(HANDLES.remmenu,'Label','&Soundscape Metrics',...
    'Enable','on','Visible','on');

% Make weekly LTSAs
uimenu(REMORA.sh.menu, 'Label', 'Make Soundscape LTSAs', ...
    'Enable','on','Callback', 'sm_pulldown(''make_ltsa'')');

% Compute soundscape metrics
uimenu(REMORA.sh.menu, 'Label', 'Compute Soundscape Metrics', ...
    'Callback', 'sm_pulldown(''compute_metrics'')');

% Plot soundscape metrics
uimenu(REMORA.sh.menu, 'Label', 'Plot Soundscape Metrics', ...
    'Callback', 'sm_pulldown(''plot_metrics'')');
