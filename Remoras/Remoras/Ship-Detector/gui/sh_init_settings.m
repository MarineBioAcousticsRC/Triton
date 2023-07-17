function sh_init_settings

global REMORA

settings.outDir  = '';
settings.tfFullFile = '';
settings.lowBand = [1000,5000]; % [min,max] Lower band frequency ranges in Hz
settings.mediumBand = [5000,10000]; % [min,max] Medium band frequency ranges in Hz
settings.highBand = [10000,50000]; % [min,max] Higher band frequency ranges in Hz
settings.thrClose = 150; % minimum duration in seconds allowed above the time-dependent  
% threshold for averaged power spectral densities at the three frequency bands
settings.thrDistant = 250; % minimum duration in seconds above the time-dependent  
% threshold for averaged power spectral densities at the low and medium frequency bands
settings.thrRL = 0.10; % percentage above mean received levels to distinguish
% ship passages from ambient noise (e.g. weather noise)
settings.minPassage = 0.5; % minimum time in hours between passages, if not will be merged
settings.buffer = 5; % add minutes before and after detected times
settings.durWind = 2; % minimum duration in hours of the exploratory window
settings.slide = 0.5; % hours allowed to slide overlapping windows before and after
% start of the central exploratory window
settings.errorRange = 0.25; % n-percent start and end time difference between 
% overlapping windows

settings.diskWrite = true; % exclude disk write noise (only for HARP data)
settings.dutyCycle = false; % if duty cycle data, set to true, this will ignore gaps
settings.saveCsv = true; % save results to a .csv file


REMORA.sh.settings = settings;