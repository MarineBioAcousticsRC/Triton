%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Initialize the MultiDirLTSA pulldown
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global HANDLES REMORA PARAMS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

REMORA.mdLTSA.menu = uimenu(HANDLES.remmenu,'Label','&MultiDirLTSA',...
    'Enable','on','Visible','on');

% Batch create LTSAs over multiple directories
uimenu(REMORA.bp.menu, 'Label', 'Batch create LTSAs', ...
    'Callback', 'mdLTSA_pulldown(''batch_ltsas'')');
                   