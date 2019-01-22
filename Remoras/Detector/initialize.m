
global PARAMS REMORA HANDLES

REMORA.dt.menu = uimenu(HANDLES.remmenu,'Label','&Detector',...
    'Enable','on','Visible','on');

% interactive xwav detector
uimenu(REMORA.dt.menu, 'Label', 'Interactive detector (XWAV)', ...
    'Callback', 'dtpd(''xwav'')');
% short time 
uimenu(REMORA.dt.menu, 'Label', 'Batch Short Time Spectrum (STS)', ...
    'Callback', 'dtpd(''dtShortTimeDetection'')');
% high resolution click detection (guided by STS detection)
uimenu(REMORA.dt.menu,'Label','Batch &High Res Click (STS Guided)',...
    'Callback','dtpd(''dtST_GuidedHRClickDet'')');
% v2 high resolution click detection (guided by STS detection)
uimenu(REMORA.dt.menu, 'Label', 'Batch High Res Click (STS Guided) V2',...
    'Callback', 'dtpd(''dtST_GuidedHRClickDet_v2'')');
% batch processing stream: STS --> hi res
uimenu(REMORA.dt.menu, 'Label', 'STS --> Hi Res Proc Stream',...
    'Callback', 'dtpd(''dt_procStream'')');
% batch processing stream: STS --> hi res (v2)
uimenu(REMORA.dt.menu, 'Label', 'STS --> Hi Res Proc Stream V2',...
    'Callback', 'dtpd(''dt_procStreamv2'')');


dt_initparams;  
dt_initwins;
dt_initcontrol;
dt_initconst;





