% Defult dettings for fish detector.
function pi_default_settings

global REMORA
settings.threshold = 0.03; % Threshold for correlation coefficient.
settings.c2_offset = 0.000000002; % Threshold offset above median square of correlation coefficient.
settings.diff_s = 0.5; % Minimum time distance between consecutive calls (was .05).
settings.nSamples = 1000; % Number of noise samples to be pulled out.
settings.rmsASmin = 1; % RMS noise after signal <rmsAS (dB) difference will be eliminated.
settings.rmsASmax = 10;
settings.rmsBS = 1; % RMS noise before signal.
settings.ppAS = 4; % PP noise after signal <ppAS (dB) difference will be eliminated.
settings.ppBS = 3; % PP noise before signal.
settings.durLong_s = 11; % Durations >= durAfter_s (s) will be eliminated.
settings.durShort_s = .005; % Durations >= dur_s (s) will be eliminated.


settings.baseDir = 'G:\Site\data\df100'; % Example base directory.
settings.outDir = 'G:\Site\Detections'; % Example output directory.
currentPath = mfilename('fullpath');
templateFilePath = fileparts(currentPath);
settings.templateFile = fullfile(templateFilePath,'template.mat'); % Searches current path of remora for the template!
settings.plotOn = 0; % turn to 0 to suppress plots; 1 for plots.

settings.recursSearch = 0; % Setting to 1 searches through all subfolders in the selected folder.
REMORA.pi.settings = settings;
end