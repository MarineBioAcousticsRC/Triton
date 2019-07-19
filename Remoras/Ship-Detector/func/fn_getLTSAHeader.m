function fn_getLTSAHeader
%
% read LTSA header and directories 
%
% 060612 smw ver 1.61
%
% tic
%
% Do not modify the following line, maintained by CVS
% $Id: read_ltsahead.m,v 1.1.1.1 2006/09/23 22:31:55 msoldevilla Exp $

global REMORA HANDLES PARAMS


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read long term spectral average header and store variables
disp('Extracting LTSA header information')

REMORA.ship_dt.ltsa = PARAMS.ltsa;
REMORA.ship_dt.ltsahd = PARAMS.ltsahd;

% Additonal - Get real xwav names 
% find physical files (raw index == 1)
physidx = find(PARAMS.ltsahd.rfileid == 1);
fnames = {};
for k = 1:length(physidx)
    index = physidx(k);
    fnames{end+1} = char(deblank(PARAMS.ltsahd.fname(index,:)));
end
REMORA.ship_dt.ltsahd.fname = fnames';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% initialize controls

set(HANDLES.ltsa.endfreq.edtxt,'String',num2str(REMORA.ship_dt.ltsa.fmax))

% turn on mouse coordinate display
set(HANDLES.fig.main,'WindowButtonMotionFcn','control(''coorddisp'')');
set(HANDLES.fig.main,'WindowButtonDownFcn','pickxyz');

% turn on msg window edit text box for pickxyz display
set(HANDLES.pick.disp,'Visible','on')
% turn on pickxyz toggle button
set(HANDLES.pick.button,'Visible','on')
% enable msg window File pulldown save pickxyz
set(HANDLES.savepicks,'Enable','on')

% t=toc;
% disp_msg(['Time to read ltsahead = ',num2str(t)])

