function sm_mk_ltsa
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% sm_mk_ltsa.m
%
% make long-term spectral averages from XWAV files in a directory
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS HANDLES

% get directory
sm_get_ltsadir;

if PARAMS.ltsa.gen == 0
    disp_msg('Canceled making ltsa')
    return
end

% read data file headers
sm_get_headers;

if PARAMS.ltsa.gen == 0 % could not read wav file metadata 
    return
end

% check some ltsa parameters and other stuff
sm_ck_ltsaparams;

% split the data into # days defined before
sm_split_ltsa;

for lIdx = PARAMS.ltsa.nstart:size(PARAMS.ltsa.ltsaIdx,1)
    % setup ltsa file header + directory listing
    sm_write_ltsahead(lIdx);

    if PARAMS.ltsa.gen == 0
        disp_msg('Canceled making ltsa')
        return
    end
    % calculated averaged spectra
    sm_calc_ltsa(lIdx) % SET BREAKPOINT HERE IF NEED TO JUST MAKE ONE LTSA!!!
end

% initial parameter for LTSA
% Set the defaults first
PARAMS.ltsa.tseg.step = -1;     % Step size (== dur by default)
PARAMS.ltsa.tseg.hr = 2;
PARAMS.ltsa.tseg.sec = PARAMS.ltsa.tseg.hr * 60 * 60;         % initial window time segment duration

PARAMS.ltsa.ftype = 1;
PARAMS.ltsa.freq0 = 0;			% set frequency PARAMS.ltsa lower limit
PARAMS.ltsa.freq1 = -1;         % set frequency PARAMS.ltsa.ltsa upper limit
PARAMS.ltsa.bright = 0;			% shift in dB
PARAMS.ltsa.contrast = 100;		% amplify in % dB
PARAMS.ltsa.fax = 0;            % linear or log freq axis
PARAMS.ltsa.cmap = 'jet';		% color map for spectrogram
PARAMS.ltsa.start.yr = 0;
PARAMS.ltsa.start.str = '0000';
PARAMS.ltsa.aptime = 0;			%  pause time (typically CPU speed dependent?
PARAMS.ltsa.cancel = 0;
PARAMS.ltsa.delimit.value = 0;  %  delimit value is off at first


PARAMS.ltsa.infile = PARAMS.ltsa.outfile;
PARAMS.ltsa.inpath = PARAMS.ltsa.outdir;


set(HANDLES.display.ltsa,'Visible','on')
set(HANDLES.display.ltsa,'Value',1);
set(HANDLES.ltsa.equal,'Visible','on')
control_ltsa('button')
set([HANDLES.ltsa.motion.seekbof HANDLES.ltsa.motion.back HANDLES.ltsa.motion.autoback HANDLES.ltsa.motion.stop],...
    'Enable','off');
init_ltsadata
read_ltsadata
PARAMS.plot.dnum = PARAMS.ltsa.plot.dnum;
% need some sort of reset here on graphics and opened xwav file
plot_triton
control_ltsa('timeon')   % was timecontrol(1)
% turn on other menus now
control_ltsa('menuon')
control_ltsa('ampon')
control_ltsa('freqon')
set(HANDLES.ltsa.motioncontrols,'Visible','on')
% turns on radio button
set(HANDLES.fig.ctrl, 'Pointer', 'arrow');

