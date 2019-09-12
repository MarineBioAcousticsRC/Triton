
global REMORA HANDLES

REMORA.sh.menu = uimenu(HANDLES.remmenu,'Label','&Ship-Detector',...
    'Enable','on','Visible','on');

% interactive ltsa detector
uimenu(REMORA.sh.menu, 'Label', 'Interactive detector (LTSA)', ...
    'Enable','on','Callback', 'sh_pulldown(''interactive'')');
% Run ship detector
uimenu(REMORA.sh.menu, 'Label', 'Batch run detector', ...
    'Callback', 'sh_pulldown(''full_detector'')');
% Visualize labels
REMORA.sh.labelmenu = uimenu(REMORA.sh.menu, 'Label', 'Visualize detections');
uimenu(REMORA.sh.labelmenu, 'Label', 'Create labels', ...
    'Enable','on','Callback', 'sh_pulldown(''create_labels'')');
uimenu(REMORA.sh.labelmenu, 'Label', 'Load labels', ...
    'Enable','on','Callback', 'sh_pulldown(''load_labels'')');
% REMORA.sh.labelplot = uimenu(REMORA.sh.labelmenu, 'Separator','off','Label', ...
%        'Display labels', 'Checked', 'off', ...
%        'Enable', 'off', 'Callback', 'sh_pulldown(''display_labels'')');

% Run evaluate interface
uimenu(REMORA.sh.menu, 'Label', 'Evaluate detections', ...
    'Enable','off','Callback', 'sh_pulldown(''evaluate_detections'')');




% sh_initparams;  
% sh_initwins;
% sh_initcontrol;
% sh_initconst;





