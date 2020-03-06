
global REMORA HANDLES

REMORA.bw.menu = uimenu(HANDLES.remmenu,'Label','&Blue whale detector',...
    'Enable','on','Visible','on');

% Run blue whale call detector
uimenu(REMORA.bw.menu, 'Label', 'Batch run detector', ...
    'Callback', 'bw_pulldown(''full_detector'')');

% Visualize labels
REMORA.bw.labelmenu = uimenu(REMORA.bw.menu, 'Label', 'Visualize detections');
uimenu(REMORA.bw.labelmenu, 'Label', 'Load labels (.tlab)', ...
    'Enable','on','Callback', 'bw_pulldown(''load_labels'')');

% uimenu(REMORA.bw.labelmenu, 'Label', 'Create labels from text file', ...
%     'Enable','on','Callback', 'bw_pulldown(''create_labels'')');

% Run evaluate interface
% uimenu(REMORA.bw.menu, 'Label', 'Evaluate detections', ...
%     'Enable','on','Callback', 'bw_pulldown(''evaluate_detections'')');






