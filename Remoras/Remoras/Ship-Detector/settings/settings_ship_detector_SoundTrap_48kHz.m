% settings_ship_detector_GOM

% Settings script for ship_detector

% Optional output directory location. Metadata directory will be created in 
% outDir if specified, otherwise it will be created in baseDir.
settings.outDir  = 'G:\ShipDetector_NOAA\Tutorial_Continuous_Data\metadata';

% Set transfer function location (calibration/sensitivity gain)
% settings.tfFullFile = 'E:\evaluate_ship_detector\tfs\656_130221_HARP.tf';
% Note, if no transfer function but singular gain use:
settings.tfFullFile = 0; % m-gain in dB
 
settings.REWavExt = '(\.x)?\.wav'; % Expression to match .wav or .x.wav

%%%% DETECTOR PARAMETERS %%%%

settings.lowBand = [100,1000]; % [min,max] Lower band frequency ranges in Hz
settings.mediumBand = [1000,3000]; % [min,max] Medium band frequency ranges in Hz
settings.highBand = [3000,15000]; % [min,max] Higher band frequency ranges in Hz

settings.thrClose = 100; % minimum duration in seconds allowed above the time-dependent  
% threshold for averaged power spectral densities at the three frequency bands
settings.thrDistant = 200; % minimum duration in seconds above the time-dependent  
% threshold for averaged power spectral densities at the low and medium frequency bands
settings.thrRL = 0.10; % percentage above mean received levels to distinguish
% ship passages from ambient noise (e.g. weather noise)
settings.minPassage = 0.25; % minimum time in hours between passages, if not will be merged
settings.buffer = 5; % add minutes before and after detected times

settings.durWind = 4; % minimum duration in hours of the exploratory window
settings.slide = 1; % hours allowed to slide overlapping windows before and after
% start of the central exploratory window
settings.errorRange = 0.05; % n-percent start and end time difference between 
% overlapping windows

settings.diskWrite = false; % exclude disk write noise (only for HARP data)
settings.dutyCycle = false; % if duty cycle data, set to true, this will ignore gaps
settings.saveCsv = true; % save .tlab file to plot detection in Triton. 