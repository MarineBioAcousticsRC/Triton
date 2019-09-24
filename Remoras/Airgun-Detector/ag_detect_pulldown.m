function ag_detect_pulldown
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ag_detect_pulldown.m
% Initializes pulldowns for airgun detector.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global  REMORA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ag_setpointers('watch');
ag_init_airgun_settings
REMORA.ag.detect_params = ag_init_airgun_settings;
if ~isfield(REMORA,'fig')
    REMORA.fig = [];
end
ag_init_detector_params_window

ag_setpointers('arrow');

function ag_setpointers(icon)
global HANDLES
set(HANDLES.fig.ctrl, 'Pointer', icon);
set(HANDLES.fig.main, 'Pointer', icon);
set(HANDLES.fig.msg, 'Pointer', icon);
