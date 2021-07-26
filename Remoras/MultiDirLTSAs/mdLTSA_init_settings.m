function mdLTSA_init_settings

global REMORA

settings.inDir = '';
settings.outDir  = '';
% settings.thresh = 30; % threshold for peak detection  
% settings.species = 'Blue whale';
settings.XWAVdata = false; % if HARP data, set to true
settings.WAVdata = true; % if wav or flac, set to true
settings.saveCsv = true; % save results to a .csv file
settings.startF = [45, 44.5, 44, 43.5];
settings.endF = [44.5, 44, 43.5, 42.7];
settings.regdate = '(?<yr>\d\d)(?<mon>\d\d)(?<day>\d\d)(?<hr>\d\d)(?<min>\d\d)(?<s>\d\d)';
settings.kernelDir = '';
settings.kernelID = '';
%settings.kernelDepl = '';
settings.tmin = 25;
settings.tmax = 35;
settings.stsize = 2;
REMORA.mdLTSA.settings = settings;