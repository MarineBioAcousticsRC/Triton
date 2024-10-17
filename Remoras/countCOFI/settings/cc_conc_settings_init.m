function cc_conc_settings_init
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% cc_conc_settings_init
%
% made by SGB 20240717
% Shelby G. Bloom (sbloom@ucsd.edu)
% modified/based on Soundscape-Metrics Remora settings folder code by Simone Baumann-Pickering
%
% initialize concatenate parameters
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global REMORA

REMORA.cc.conc = [];

%% Input / Output Settings

REMORA.cc.conc.indir = '';
REMORA.cc.conc.outdir = '';
%REMORA.cc.conc.csvout = 1; % yes/no for a csv output
%REMORA.cc.conc.fstart = 1; % Daily Expanded file number to start with for calculation

%% 







% 
% PARAMS.ltsa = [];
% PARAMS.ltsahd = [];
% 
% % user defined:
% PARAMS.ltsa.tave = 1;       % averaging time [seconds]
% PARAMS.ltsa.dfreq = 1;    % frequency bin size [Hz]
% PARAMS.ltsa.ndays = 3;    % length of LTSA [days]
% PARAMS.ltsa.nstart = 1;   % start number of LTSA file (e.g. want to start at week 2)
% 
% 
% % experiment defined (in WAV/XWAV file):
% PARAMS.ltsa.fs = 200000;    % sample rate [Hz]
% 
% % other
% PARAMS.ltsa.indir = 'H:\SOCAL_CB_01_01\SOCAL_CB_01_01_disk01\';   % starting data directory
% PARAMS.ltsa.outdir = 'D:\SoundScape\SOCAL_CB_01_01\ltsa\';   % starting data directory
% PARAMS.ltsa.outfname = 'SOCAL_CB_01_01';   %file name of ltsa; will be appended with '_n' for file number
% 
% PARAMS.ltsa.ftype = 2;      % 1= WAVE, 2=XWAV
% 
% PARAMS.ltsa.dtype = 1;      % 1 = HARP, 2 = ARP, 3 = OBS, 4 = towed array or sonobuoy, 5 = SoundTrap
% 
% PARAMS.ltsa.ch = 1;       % channel to do ltsa on for multichannel wav files
% 
% 
% %% calculated based on user defined:
% % number of samples for fft (nfft = 1000 for dfreq=200Hz & fs=200000Hz)
% PARAMS.ltsa.nfft = PARAMS.ltsa.fs / PARAMS.ltsa.dfreq;    
% % compression factor (cfact = 1000 for tave=5sec,fs=200000Hz,dfreq=200)
% PARAMS.ltsa.cfact = PARAMS.ltsa.tave * PARAMS.ltsa.fs / PARAMS.ltsa.nfft;   
% 
% 
