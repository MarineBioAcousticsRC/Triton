global REMORA HANDLES

% initialization script for label tracking remora

REMORA.lt.menu = uimenu(HANDLES.remmenu,'Label','&LabelVis',...
    'Enable','on','Visible','on');

%create tlab files from text
uimenu(REMORA.lt.menu, 'Label', 'Create tLabs from Text File',...
    'Callback','lt_pulldown(''create_tlabs_txt'')');
% create tlab files 
uimenu(REMORA.lt.menu, 'Label', 'Create tLabs from DetEdit Output', ...
    'Callback', 'lt_pulldown(''create_tlabs_detEdit'')');
% Start label visualization
uimenu(REMORA.lt.menu, 'Label', 'Visualize Labels', ...
    'Callback', 'lt_pulldown(''visualize_labels'')');


if ~isfield(REMORA,'fig')
    REMORA.fig = [];
end