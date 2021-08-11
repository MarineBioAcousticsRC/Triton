%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Initialize the BatchLTSA pulldown
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global HANDLES REMORA PARAMS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

REMORA.batchLTSA.menu = uimenu(HANDLES.remmenu,'Label','&Batch LTSAs',...
    'Enable','on','Visible','on');

% Batch create LTSAs over multiple directories
uimenu(REMORA.batchLTSA.menu, 'Label', 'Batch create LTSAs', ...
    'Callback', 'batchLTSA_pulldown(''batch_ltsas'')');
                   