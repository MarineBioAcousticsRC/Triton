global REMORA HANDLES

% initialization script for label tracking remora

REMORA.lt.menu = uimenu(HANDLES.remmenu,'Label','&Label Tracker',...
    'Enable','on','Visible','on');


% create tlab files 
uimenu(REMORA.lt.menu, 'Label', 'Create tLabs From detEdit Output', ...
    'Callback', 'lt_pulldown(''create_tlabs'')');
% Start label visualization
uimenu(REMORA.lt.menu, 'Label', 'Visualize Labels', ...
    'Callback', 'lt_pulldown(''visualize_labels'')');


if ~isfield(REMORA,'fig')
    REMORA.fig = [];
end