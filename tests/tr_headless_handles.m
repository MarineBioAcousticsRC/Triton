function tr_headless_handles()
%TR_HEADLESS_HANDLES  Minimal HANDLES global so Triton internals run without the GUI.
%
% Several core Triton functions touch the HANDLES global even though their job is pure
% computation:
%
%   disp_msg        -> HANDLES.msg                 (get/set 'String')
%   check_time      -> HANDLES.motion.{seekbof,back,autoback,stop,seekeof,fwd,autofwd,
%                                      nextfile,prevfile}  ('Enable', 'Userdata')
%   check_ltsa_time -> HANDLES.ltsa.motion.{...}, HANDLES.ltsa.time.edtxt3
%   read_ltsahead   -> HANDLES.fig.main, HANDLES.pick.disp, HANDLES.pick.button,
%                      HANDLES.savepicks   (it re-arms GUI callbacks at lines 190-200,
%                      because parsing and view setup are not separated there)
%
% This builds just those, as real uicontrols on one invisible figure, so that readseg /
% check_time / mkspecgram can be exercised headlessly and produce genuine ground truth --
% rather than us re-implementing their logic in the dump script and testing our own
% transcription.
%
% Call tr_headless_handles_close() when finished.
%
% Part of the Triton regression harness -- see tests/README.md.

global HANDLES

f = figure('Visible','off','Name','triton-headless-shim','IntegerHandle','off', ...
           'HandleVisibility','off');

HANDLES = [];
HANDLES.fig.headless = f;

% read_ltsahead re-arms plot-window callbacks; give it somewhere harmless to point
HANDLES.fig.main = f;

% disp_msg / disp_pick targets
HANDLES.msg         = uicontrol(f,'Style','listbox','String',{},'Visible','off');
HANDLES.pick.disp   = uicontrol(f,'Style','listbox','String',{},'Visible','off');
HANDLES.pick.button = uicontrol(f,'Style','togglebutton','Visible','off');
HANDLES.savepicks   = uimenu(f,'Label','savepicks-shim','Visible','off');

% check_time toggles these; Userdata on .stop gates the auto-advance loop
names = {'seekbof','back','autoback','stop','seekeof','fwd','autofwd', ...
         'nextfile','prevfile'};
for k = 1:numel(names)
    HANDLES.motion.(names{k}) = uicontrol(f,'Style','pushbutton','Visible','off');
    HANDLES.ltsa.motion.(names{k}) = uicontrol(f,'Style','pushbutton','Visible','off');
end
set(HANDLES.motion.stop,'Userdata',-1);        % -1 == not auto-advancing (motion.m:102)
set(HANDLES.ltsa.motion.stop,'Userdata',-1);

% initdata touches the control-window widgets when it sets up channels, the
% frequency range and the display/filter/sound toggles. Plain wav and flac
% both go through that path, so they cannot be exercised without these.
HANDLES.fig.ctrl        = f;
HANDLES.chan            = uicontrol(f,'Style','popupmenu','String',{'1'},'Visible','off');
HANDLES.ch.pop          = uicontrol(f,'Style','popupmenu','String',{'1'},'Visible','off');
HANDLES.ch.txt          = uicontrol(f,'Style','text','Visible','off');
HANDLES.displaycontrol  = uicontrol(f,'Style','checkbox','Visible','off');
HANDLES.filtcontrol     = uicontrol(f,'Style','checkbox','Visible','off');
HANDLES.sndcontrol      = uicontrol(f,'Style','checkbox','Visible','off');
HANDLES.snd.button      = uicontrol(f,'Style','pushbutton','Visible','off');
HANDLES.stfreq.edtxt    = uicontrol(f,'Style','edit','Visible','off');
HANDLES.endfreq.edtxt   = uicontrol(f,'Style','edit','Visible','off');
HANDLES.mc.on           = uicontrol(f,'Style','checkbox','Value',0,'Visible','off');

% plot_specgram, plot_ltsa and plot_triton read the display checkboxes and a few
% spectrogram controls, so the plotting path needs these to run headlessly.
HANDLES.display.ltsa       = uicontrol(f,'Style','checkbox','Value',0,'Visible','off');
HANDLES.display.specgram   = uicontrol(f,'Style','checkbox','Value',1,'Visible','off');
HANDLES.display.spectra    = uicontrol(f,'Style','checkbox','Value',0,'Visible','off');
HANDLES.display.timeseries = uicontrol(f,'Style','checkbox','Value',0,'Visible','off');
HANDLES.sgeq.tog           = uicontrol(f,'Style','togglebutton','Value',0,'Visible','off');
HANDLES.sgeq.tog2          = uicontrol(f,'Style','togglebutton','Value',0,'Visible','off');
HANDLES.specnfft.edtxt     = uicontrol(f,'Style','edit','Visible','off');
HANDLES.BC                 = uicontrol(f,'Style','text','Visible','off');

% init_ltsadata and check_ltsa_time reach into the LTSA control window for the
% frequency range and the expand toggle, so the LTSA read path needs these too.
HANDLES.ltsa.endfreq.edtxt  = uicontrol(f,'Style','edit','Visible','off');
HANDLES.ltsa.stfreq.edtxt   = uicontrol(f,'Style','edit','Visible','off');
HANDLES.ltsa.expand.button  = uicontrol(f,'Style','togglebutton','Value',0,'Visible','off');

% check_ltsa_time writes the segment length back into the control window
HANDLES.ltsa.time.edtxt3 = uicontrol(f,'Style','edit','Visible','off');

end


function tr_headless_handles_close() %#ok<DEFNU>
%TR_HEADLESS_HANDLES_CLOSE  Tear down the shim figure.
global HANDLES
if isstruct(HANDLES) && isfield(HANDLES,'fig') && isfield(HANDLES.fig,'headless') ...
        && ishandle(HANDLES.fig.headless)
    close(HANDLES.fig.headless);
end
HANDLES = [];
end
