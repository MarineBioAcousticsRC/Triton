function init_ltsaparams
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% init_ltsaparams.m
%
% initialize ltsa parameters
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS

PARAMS.ltsa = [];
PARAMS.ltsahd = [];

% user defined:
PARAMS.ltsa.tave = 5;       % averaging time [seconds]
PARAMS.ltsa.dfreq = 200;    % frequency bin size [Hz]

% experiment defined (in XWAV file):
PARAMS.ltsa.fs = 200000;    % sample rate [Hz]

% calculated based on user defined:
% number of samples for fft (nfft = 1000 for dfreq=200Hz & fs=200000Hz)
PARAMS.ltsa.nfft = PARAMS.ltsa.fs / PARAMS.ltsa.dfreq;    
% compression factor (cfact = 1000 for tave=5sec,fs=200000Hz,dfreq=200)
PARAMS.ltsa.cfact = PARAMS.ltsa.tave * PARAMS.ltsa.fs / PARAMS.ltsa.nfft;   

% other
PARAMS.ltsa.indir = 'C:\';   % starting data directory
PARAMS.ltsa.ftype = 2;      % 1= WAVE, 2=XWAV

PARAMS.ltsa.dtype = 1;      % 1 = HARP, 2 = ARP, 3 = OBS, 4 = towed array or sonobuoy

PARAMS.ltsa.ch = 1;       % channel to do ltsa on for multichannel wav files



