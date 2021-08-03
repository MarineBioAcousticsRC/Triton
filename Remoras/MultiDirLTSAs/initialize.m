%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Initialize the MultiDirLTSA pulldown
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global HANDLES REMORA PARAMS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

REMORA.mdLTSA.menu = uimenu(HANDLES.remmenu,'Label','&Batch LTSAs',...
    'Enable','on','Visible','on');

% Batch create LTSAs over multiple directories
uimenu(REMORA.mdLTSA.menu, 'Label', 'Batch create LTSAs', ...
    'Callback', 'mdLTSA_pulldown(''batch_ltsas'')');
                   