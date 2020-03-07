
global REMORA HANDLES

REMORA.bp.menu = uimenu(HANDLES.remmenu,'Label','&Fin Whale Index-Detector',...
    'Enable','on','Visible','on');

% % Interactive ltsa detector
% uimenu(REMORA.sh.menu, 'Label', 'Interactive detector (LTSA)', ...
%     'Enable','on','Callback', 'sh_pulldown(''interactive'')');

% Run fin whale detector
uimenu(REMORA.bp.menu, 'Label', 'Batch run detector', ...
    'Callback', 'bp_pulldown(''full_detector'')');

% Visualize labels
REMORA.bp.labelmenu = uimenu(REMORA.bp.menu, 'Label', 'Visualize detections');
uimenu(REMORA.bp.labelmenu, 'Label', 'Create labels from text file', ...
    'Enable','on','Callback', 'bp_pulldown(''create_labels'')');

uimenu(REMORA.bp.labelmenu, 'Label', 'Load labels (.tlab)', ...
    'Enable','on','Callback', 'bp_pulldown(''load_labels'')');

% Run evaluate interface
uimenu(REMORA.bp.menu, 'Label', 'Evaluate detections', ...
    'Enable','on','Callback', 'bp_pulldown(''evaluate_detections'')');





