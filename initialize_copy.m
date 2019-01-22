
global PARAMS REMORA HANDLES

REMORA.dtmenu = uimenu(HANDLES.remmenu,'Label','&Detector',...
    'Enable','on','Visible','on');

intx = uimenu(REMORA.dtmenu, 'Label', 'Interactive detector');
uimenu(intx, 'Label', 'LTSA', 'Callback', 'dtpd(''ltsa'')', 'Enabled', 'off');
uimenu(intx, 'Label', 'XWAV', 'Callback', 'dtpd(''xwav'')');

dt_initparams; 
dt_initwins;
dt_initcontrol;


