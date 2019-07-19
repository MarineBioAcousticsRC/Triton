function ship_init_ltsaParams
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% init_ltsaparams.m
%
% initialize ltsa parameters
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global REMORA

REMORA.ship_dt.ltsa = [];
REMORA.ship_dt.ltsahd = [];


% user defined:
REMORA.ship_dt.ltsa.tave = 5;       % averaging time [seconds]
REMORA.ship_dt.ltsa.dfreq = 200;    % frequency bin size [Hz]

% experiment defined (in XWAV file):
REMORA.ship_dt.ltsa.fs = 200000;    % sample rate [Hz]

% calculated based on user defined:
% number of samples for fft (nfft = 1000 for dfreq=200Hz & fs=200000Hz)
REMORA.ship_dt.ltsa.nfft = REMORA.ship_dt.ltsa.fs / REMORA.ship_dt.ltsa.dfreq;    
% compression factor (cfact = 1000 for tave=5sec,fs=200000Hz,dfreq=200)
REMORA.ship_dt.ltsa.cfact = REMORA.ship_dt.ltsa.tave * REMORA.ship_dt.ltsa.fs / REMORA.ship_dt.ltsa.nfft;   

% other
REMORA.ship_dt.ltsa.indir = 'C:\';   % starting data directory
REMORA.ship_dt.ltsa.ftype = 2;      % 1= WAVE, 2=XWAV

REMORA.ship_dt.ltsa.dtype = 1;      % 1 = HARP, 2 = ARP, 3 = OBS, 4 = towed array or sonobuoy

REMORA.ship_dt.ltsa.ch = 1;       % channel to do ltsa on for multichannel wav files



