
global REMORA HANDLES

REMORA.ship_dt.menu = uimenu(HANDLES.remmenu,'Label','&Ship-Detector',...
    'Enable','on','Visible','on');

% interactive ltsa detector
uimenu(REMORA.ship_dt.menu, 'Label', 'Interactive detector (LTSA)', ...
    'Enable','off','Callback', 'ship_dt_pd(''interactive'')');
% Run ship detector
uimenu(REMORA.ship_dt.menu, 'Label', 'Batch run detector', ...
    'Callback', 'ship_dt_pd(''full_detector'')');
% Visualize labels
REMORA.ship_dt.labelmenu = uimenu(REMORA.ship_dt.menu, 'Label', 'Visualize detections');
uimenu(REMORA.ship_dt.labelmenu, 'Label', 'Create labels', ...
    'Callback', 'ship_dt_pd(''create_labels'')');
uimenu(REMORA.ship_dt.labelmenu, 'Label', 'Load labels', ...
    'Enable','on','Callback', 'ship_dt_pd(''load_labels'')');
% REMORA.ship_dt.labelplot = uimenu(REMORA.ship_dt.labelmenu, 'Separator','off','Label', ...
%        'Display labels', 'Checked', 'off', ...
%        'Enable', 'off', 'Callback', 'ship_dt_pd(''display_labels'')');

% Run evaluate interface
uimenu(REMORA.ship_dt.menu, 'Label', 'Evaluate detections', ...
    'Enable','off','Callback', 'ship_dt_pd(''evaluate_detections'')');




% ship_dt_initparams;  
% ship_dt_initwins;
% ship_dt_initcontrol;
% ship_dt_initconst;





