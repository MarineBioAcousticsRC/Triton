% settings_detector_xwav_DCLDE2015

% Settings script for spice_detector

% Parameters for both detector steps (low & high resolution):
detParams.lowResDet = true; % run low resolution detector.
detParams.highResDet = true; % run high resolution detector.

% Location of base directory containing directories of files to be analyzed
detParams.baseDir = 'G:\SocalHFDevelopmentData\DCPP_C';

% Optional output directory location. Metadata directory will be created in 
% outDir if specified, otherwise it will be created in baseDir.
detParams.outDir  = 'D:\DCLDE2015'; 

% Set transfer function location
detParams.tfFullFile = 'E:\Data\Papers\AI_classification\DCLDETFsIUsed\682_120919_ALL\682_120919_HARP.tf';
% Note, if no transfer function use: parametersLR.tfFullFile = [];

% Name of the deployment. This should be the first few characters in the 
% directory(ies) you want to look in you want to look at. For now, 
% directory hierarchy is expected to be: basedir>depl*>*.x.wav
detParams.depl = 'DCPP01C';

detParams.channel = 1; % which channel do you want to look at?
detParams.bpRanges = [5000 100000]; % Bandpass filter parameters in Hz [min,max]
detParams.filterOrder = 5; % butterworth filter order used for band pass
detParams.dBppThreshold = 118; % minimum amplitude threshold in dB. 
detParams.frameLengthUs = 2000; % For fft computation
detParams.clipThreshold = 0.98;%  Normalized clipping threshold btwn 0 and 1.  If empty, 
% assumes no clipping. 
detParams.snrDet = 0;
detParams.snrThresh  = 0;

detParams.REWavExt = '(\.x)?\.wav';% Only used for array. Expression to match .wav or .x.wav
% If you are using wav files that have a time stamp in the name, put a
% regular expression for extracting that here:
detParams.DateRegExp = '_(\d*)_(\d*)';

% Examples:
%      a) File name looks like: "myFile_20110901_234905.wav" 
%         ie.:  "*_yyyymmdd_HHMMSS.wav"
%         So use:
%         parametersST.DateRE = '_(\d*)_(\d*)';
%
%      b) File name looks like: "palmyra102006-061104-012711_4.wav" 
%         ie.:  "*yyyy-yymmdd-HHMMSS*.wav"
%         So use:
%         parametersST.DateRE = '(\d{4})-\d{2}(\d{4})-(\d{6})';

%%%%% GUIDED DETECTIONS? %%%%
detParams.guidedDetector = false; % flag to 1 if guided
% Name of spreadsheet containing target detection times. Required if guidedDetector = true
% parametersLR.gDxls = 'E:\Data\John Reports\DCLDEdata\WAT_NC_guidedDets.xlsx';
detParams.gDxls = [];
detParams.diary = false; % set to true if you want a diary output. Warning: text file can get large

%%%%%%%%%%%%%%%%%% Low resolution only settings %%%%%%%%%%%%%%%%
detParams.LRbuffer = 0.0025; % # of seconds to add on either side of area of interest

%%%%%%%%%%%%%%%%%% High resolution only settings %%%%%%%%%%%%%%%%
%%% OTHER DETECTION THRESHOLD PARAMS %%%
detParams.energyThr = 0.25; % n-percent energy threshold for envelope duration
detParams.dEvLims = [-.5,.9];  % [min,max] Envelope energy distribution comparing 
% first half to second half of high energy envelope of click. If there is
% more energy in the first half of the click (dolphin) dEv >0, If it's more
% in the second half (boats?) dEv<0. If it's about the same (beaked whale)
% dEnv ~= 0 , but still allow a range...

detParams.HRbuffer = 0.00025; % # of seconds to add on either side of area of interest
detParams.delphClickDurLims = [30,1200];% [min,max] duration in microsec 
% allowed for high energy envelope of click
detParams.cutPeakBelowKHz = 5; % discard click if peak frequency below X kHz
detParams.cutPeakAboveKHz = 100; % discard click if peak frequency above Y kHz 
% detParams.minClick_us = 16;% Minimum duration of a click in us 
% detParams.maxClick_us = 1500; % Max duration of a click including echos

detParams.mergeThr = 100;% min gap between energy peaks in us. Anything less
% will be merged into one detection the beginning of the next is fewer
% samples than this, the signals will be merged.

detParams.energyPrctile = 70; % sets the threshold at which click start 
% and end are defined. In a time window of interest, the detector finds the
% maximum energy peak, and then walks forward and back in time, until it
% gets to an energy level set by this threshold, ie. 70th percentile of
%  energy in the time window. 

%%% POST PROCESSING FLAGS %%%%%%%%
detParams.rmLonerClicks = false;
detParams.rmEchos = false;
detParams.lockOut = 0.0001; % min gap between clicks in seconds, only used if rmEchos=TRUE
detParams.maxNeighbor = 10; % max time in seconds allowed between neighboring 
% clicks. Clicks that are far from neighbors can be rejected using this parameter,
% good for dolphins in noisy environments because lone clicks or pairs of
% clicks are likely false positives

%%% Saving options %%%
detParams.saveNoise = 0; % Make 1 if you want to save noise samples with each click. 
% Beware: this can make big files if you have a lot of detections.
detParams.saveForTPWS = 1; % Save just enough data to build TPWS files. Should help
% limit metadata size.

detParams.overwrite = false; % overwrite any existing detection files? 
% Useful in case of a crash.

% Control amount of messaging displayed in console.
detParams.verbose = true;

%%% Output file extensions. Probably don't need to be changed %%%
detParams.ppExt = 'cHR';