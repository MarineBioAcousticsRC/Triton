
global REMORA HANDLES

% initialization script for spice detector remora

REMORA.spice_dt.menu = uimenu(HANDLES.remmenu,'Label','&SPICE-Detector',...
    'Enable','on','Visible','on');

% interactive xwav detector
uimenu(REMORA.spice_dt.menu, 'Label', 'Interactive detector', ...
    'Callback', 'sp_dt_pd(''xwav'')');
% Run both high and low res 
uimenu(REMORA.spice_dt.menu, 'Label', 'Batch run detector', ...
    'Callback', 'sp_dt_pd(''full_detector'')');

uimenu(REMORA.spice_dt.menu, 'Label', 'Convert detections to TPWS', ...
    'Callback', 'sp_dt_pd(''make_TPWS'')');


if ~isfield(REMORA,'fig')
    REMORA.fig = [];
end





