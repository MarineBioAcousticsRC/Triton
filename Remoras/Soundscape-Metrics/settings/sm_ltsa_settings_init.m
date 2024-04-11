function sm_ltsa_settings_init
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% sm_ltsa_settings_init.m
%
% initialize ltsa parameters - holds the default soundscape metrics mkLTSA
% window parameters which have been modified from the global PARAMS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS

PARAMS.ltsa = [];
PARAMS.ltsahd = [];

% user defined:
PARAMS.ltsa.tave = 1;       % averaging time [seconds]
PARAMS.ltsa.dfreq = 1;    % frequency bin size [Hz]
PARAMS.ltsa.ndays = 3;    % length of LTSA [days]
PARAMS.ltsa.nstart = 1;   % start number of LTSA file (e.g. want to start at week 2)


% experiment defined (in WAV/XWAV file):
PARAMS.ltsa.fs = 200000;    % sample rate [Hz]

% other
PARAMS.ltsa.indir = 'H:\SOCAL_CB_01_01\SOCAL_CB_01_01_disk01\';   % starting data directory
PARAMS.ltsa.outdir = 'D:\SoundScape\SOCAL_CB_01_01\ltsa\';   % starting data directory
PARAMS.ltsa.outfname = 'SOCAL_CB_01_01';   %file name of ltsa; will be appended with '_n' for file number

PARAMS.ltsa.ftype = 2;      % 1= WAVE, 2=XWAV

PARAMS.ltsa.dtype = 1;      % 1 = HARP, 2 = ARP, 3 = OBS, 4 = towed array or sonobuoy, 5 = SoundTrap

PARAMS.ltsa.ch = 1;       % channel to do ltsa on for multichannel wav files


%% calculated based on user defined:
% number of samples for fft (nfft = 1000 for dfreq=200Hz & fs=200000Hz)
PARAMS.ltsa.nfft = PARAMS.ltsa.fs / PARAMS.ltsa.dfreq;    
% compression factor (cfact = 1000 for tave=5sec,fs=200000Hz,dfreq=200)
PARAMS.ltsa.cfact = PARAMS.ltsa.tave * PARAMS.ltsa.fs / PARAMS.ltsa.nfft;   


