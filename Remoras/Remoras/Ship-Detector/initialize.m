
global REMORA HANDLES

REMORA.sh.menu = uimenu(HANDLES.remmenu,'Label','&Ship-Detector',...
    'Enable','on','Visible','on');

% Interactive ltsa detector
uimenu(REMORA.sh.menu, 'Label', 'Interactive detector (LTSA)', ...
    'Enable','on','Callback', 'sh_pulldown(''interactive'')');

% Run ship detector
uimenu(REMORA.sh.menu, 'Label', 'Batch run detector', ...
    'Callback', 'sh_pulldown(''full_detector'')');

% Visualize labels
REMORA.sh.labelmenu = uimenu(REMORA.sh.menu, 'Label', 'Visualize detections');
uimenu(REMORA.sh.labelmenu, 'Label', 'Create labels from text file', ...
    'Enable','on','Callback', 'sh_pulldown(''create_labels'')');

uimenu(REMORA.sh.labelmenu, 'Label', 'Load labels (.tlab)', ...
    'Enable','on','Callback', 'sh_pulldown(''load_labels'')');

% Run evaluate interface
uimenu(REMORA.sh.menu, 'Label', 'Evaluate detections', ...
    'Enable','on','Callback', 'sh_pulldown(''evaluate_detections'')');





