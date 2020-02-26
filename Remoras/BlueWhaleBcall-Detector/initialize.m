
global REMORA HANDLES

REMORA.bw.menu = uimenu(HANDLES.remmenu,'Label','&Blue whale detector',...
    'Enable','on','Visible','on');

% Run blue whale call detector
uimenu(REMORA.bw.menu, 'Label', 'Batch run detector', ...
    'Callback', 'bw_pulldown(''full_detector'')');


% Run evaluate interface
%uimenu(REMORA.bw.menu, 'Label', 'Evaluate detections', ...
 %   'Enable','on','Callback', 'bw_pulldown(''evaluate_detections'')');





