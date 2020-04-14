function sm_cmpt_settings_init
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% sm_cmpt_settings_init.m
%
% initialize compute soundscape metrics parameters
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global REMORA

REMORA.sm.cmpt = [];

%% Input / Output Settings

REMORA.sm.cmpt.indir = 'D:\SoundScape\SOCAL_CB_01_01\ltsa';
REMORA.sm.cmpt.outdir = 'D:\SoundScape\SOCAL_CB_01_01\metrics';
REMORA.sm.cmpt.ltsaout = 0; % yes/no for a new average LTSA output
REMORA.sm.cmpt.csvout = 1; % yes/no for a csv output
REMORA.sm.cmpt.fstart = 1; % LTSA file number to start with for calculation

%% Analysis Options
% Bandpass Edges
REMORA.sm.cmpt.lfreq = 20; % low frequency cut off (Hz)
REMORA.sm.cmpt.hfreq = 24000; % hight frequency cut off (Hz)

% Analysis Type
REMORA.sm.cmpt.bb = 0; % yes/no broadband level
REMORA.sm.cmpt.ol = 0; % yes/no octave level
REMORA.sm.cmpt.tol = 0; % yes/no third octave level
REMORA.sm.cmpt.psd = 0; % yes/no power spectral density

% Averaging
REMORA.sm.cmpt.avgt = 3600; % bin size of time average in seconds
REMORA.sm.cmpt.avgf = 1; % bin size of frequency average in Hz
REMORA.sm.cmpt.perc = 0.5; % percentage of seconds with good data / time average

REMORA.sm.cmpt.mean = 0; % mean averaging type
REMORA.sm.cmpt.median = 0; % median averaging type
REMORA.sm.cmpt.prctile = 0; % percentiles averaging type

% Remove Erroneous Data
REMORA.sm.cmpt.fifo = 0; % yes/no remove fifo noise
REMORA.sm.cmpt.dw = 0; % yes/no remove disk writes in HARP data
REMORA.sm.cmpt.strum = 0; % yes/no remove flow or strumming noise

%% Calibration Options
% Single Value Calibration
REMORA.sm.cmpt.cal = 0; % yes/no  to calibrate data during computation
REMORA.sm.cmpt.sval = 0; % yes/no to calibrate with single value
REMORA.sm.cmpt.caldb = []; % system sensitivity (high or low gain ST300; hdyrophone + recorder for ST500)

% Transfer Function Calibration
REMORA.sm.cmpt.tfval = 0; %yes/no to calibrate with transfer function
REMORA.sm.cmpt.tfile = [];
REMORA.sm.cmpt.tpath = [];

