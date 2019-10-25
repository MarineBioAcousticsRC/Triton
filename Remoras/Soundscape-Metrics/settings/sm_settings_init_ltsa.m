function sm_settings_init_ltsa
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% settings_init_ltsa.m
%
% initialize ltsa parameters
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS

PARAMS.ltsa = [];
PARAMS.ltsahd = [];

% user defined:
PARAMS.ltsa.tave = 1;       % averaging time [seconds]
PARAMS.ltsa.dfreq = 1;    % frequency bin size [Hz]
PARAMS.ltsa.ndays = 7;    % length of LTSA [days]


% experiment defined (in WAV/XWAV file):
PARAMS.ltsa.fs = 96000;    % sample rate [Hz]

% other
PARAMS.ltsa.indir = 'G:\MB02_01\wav_671903780\';   % starting data directory
PARAMS.ltsa.outdir = 'D:\SanctSound_Output\SanctSound_MB02_01\ltsa\';   % starting data directory
PARAMS.ltsa.outfname = 'SanctSound_MB02_01';   %file name of ltsa; will be appended with '_n' for file number

PARAMS.ltsa.ftype = 1;      % 1= WAVE, 2=XWAV

PARAMS.ltsa.dtype = 5;      % 1 = HARP, 2 = ARP, 3 = OBS, 4 = towed array or sonobuoy, 5 = SoundTrap

PARAMS.ltsa.ch = 1;       % channel to do ltsa on for multichannel wav files


%% calculated based on user defined:
% number of samples for fft (nfft = 1000 for dfreq=200Hz & fs=200000Hz)
PARAMS.ltsa.nfft = PARAMS.ltsa.fs / PARAMS.ltsa.dfreq;    
% compression factor (cfact = 1000 for tave=5sec,fs=200000Hz,dfreq=200)
PARAMS.ltsa.cfact = PARAMS.ltsa.tave * PARAMS.ltsa.fs / PARAMS.ltsa.nfft;   


