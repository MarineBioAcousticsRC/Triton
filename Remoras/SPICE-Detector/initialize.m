
global REMORA HANDLES

REMORA.spice_dt.menu = uimenu(HANDLES.remmenu,'Label','&SPICE-Detector',...
    'Enable','on','Visible','on');

% interactive xwav detector
uimenu(REMORA.spice_dt.menu, 'Label', 'Interactive detector', ...
    'Callback', 'spice_dt_pd(''xwav'')');
% Run both high and low res 
uimenu(REMORA.spice_dt.menu, 'Label', 'Batch run detector', ...
    'Callback', 'spice_dt_pd(''full_detector'')');

uimenu(REMORA.spice_dt.menu, 'Label', 'Convert detections to TPWS', ...
    'Callback', 'spice_dt_pd(''make_TPWS'')');




% spice_dt_initparams;  
% spice_dt_initwins;
% spice_dt_initcontrol;
% spice_dt_initconst;





