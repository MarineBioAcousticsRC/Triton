function ex_detect_pulldown
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ag_detect_pulldown.m
% Initializes pulldowns for airgun detector.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global  REMORA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ex_setpointers('watch');
ex_init_explosion_settings
REMORA.ex.detect_params = ex_init_explosion_settings;
if ~isfield(REMORA,'fig')
    REMORA.fig = [];
end
ex_init_detector_params_window

ex_setpointers('arrow');

function ex_setpointers(icon)
global HANDLES
set(HANDLES.fig.ctrl, 'Pointer', icon);
set(HANDLES.fig.main, 'Pointer', icon);
set(HANDLES.fig.msg, 'Pointer', icon);
