
global REMORA HANDLES

REMORA.sm.menu = uimenu(HANDLES.remmenu,'Label','&Soundscape Metrics',...
    'Enable','on','Visible','on');

% Make Soundscape LTSAs
uimenu(REMORA.sm.menu, 'Label', 'Make Soundscape LTSAs', ...
    'Enable','on','Callback', 'sm_pulldown(''make_ltsa'')');

% Compute soundscape metrics
uimenu(REMORA.sm.menu, 'Label', 'Compute Soundscape Metrics', ...
    'Callback', 'sm_pulldown(''compute_metrics'')');

% Load Soundscape LTSAs
uimenu(REMORA.sm.menu, 'Label', 'Load Soundscape LTSA', ...
    'Enable','on','Callback', 'sm_pulldown(''load_ltsa'')');

% Plot soundscape metrics
uimenu(REMORA.sm.menu, 'Label', 'Plot Soundscape Metrics', ...
    'Callback', 'sm_pulldown(''plot_metrics'')');
