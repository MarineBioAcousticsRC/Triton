
global REMORA HANDLES

REMORA.bm.menu = uimenu(HANDLES.remmenu,'Label','&Blue whale detector',...
    'Enable','on','Visible','on');

% Run blue whale call detector
uimenu(REMORA.bm.menu, 'Label', 'Batch run detector', ...
    'Callback', 'bm_pulldown(''full_detector'')');

% Visualize labels
% REMORA.bm.labelmenu = uimenu(REMORA.bm.menu, 'Label', 'Visualize detections');
% uimenu(REMORA.bm.labelmenu, 'Label', 'Load labels (.tlab)', ...
%     'Enable','on','Callback', 'bm_pulldown(''load_labels'')');

% uimenu(REMORA.bw.labelmenu, 'Label', 'Create labels from text file', ...
%     'Enable','on','Callback', 'bw_pulldown(''create_labels'')');

% Run evaluate interface
% uimenu(REMORA.bm.menu, 'Label', 'Evaluate detections', ...
%     'Enable','on','Callback', 'bm_pulldown(''evaluate_detections'')');






