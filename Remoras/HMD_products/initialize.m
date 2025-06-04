%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mypsd_init.m — Remora init function for 1-min daily PSD NetCDF writer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global HANDLES REMORA PARAMS

% Add to Triton Remora menu
REMORA.mypsd.menu = uimenu(HANDLES.remmenu, ...
    'Label', 'Hybrid-millidecade Products', ...
    'Callback', 'mypsd_run(''gui'')');  % opens GUI or folder select