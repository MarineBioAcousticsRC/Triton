% Defult dettings for explosion detector.

parm.threshold = 0.03; % Threshold for correlation coefficient.
parm.c2_offset = 0.000003; % Threshold offset above median square of correlation coefficient.
parm.diff_s = 2; % Minimum time distance between consecutive explosions (was .05).
parm.nSamples = 1000; % Number of noise samples to be pulled out.
parm.rmsAS = 1.5; % RMS noise after signal <rmsAS (dB) difference will be eliminated.
parm.rmsBS = 1; % RMS noise before signal.
parm.ppAS = 4; % PP noise after signal <ppAS (dB) difference will be eliminated.
parm.ppBS = 3; % PP noise before signal.
parm.durLong_s = 0.55; % Durations >= durAfter_s (s) will be eliminated.
parm.durShort_s = .03; % Durations >= dur_s (s) will be eliminated.


parm.baseDir = 'G:\Site\data\df100'; % Example base directory.
parm.outDir = 'G:\Site\ExplosionDetections'; % Example output directory.
parm.datatype = 'HARP';
currentPath = mfilename('fullpath');
templateFilePath = fileparts(currentPath);
parm.templateFile = fullfile(templateFilePath,'template.mat'); % Searches current path of remora for the template!
parm.plotOn = 0; % turn to 0 to suppress plots; 1 for plots.

parm.recursSearch = 0; % Setting to 1 searches through all subfolders in the selected folder.