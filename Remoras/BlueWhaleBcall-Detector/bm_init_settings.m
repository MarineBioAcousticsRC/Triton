function bm_init_settings

global REMORA

settings.inDir = '';
settings.outDir  = '';
settings.thresh = 30; % threshold for peak detection  
settings.species = 'Blue whale';
settings.HARPdata = false; % if HARP data, set to true
settings.SoundTrap = true; % if not Sound Trap data, set to false
settings.saveCsv = true; % save results to a .csv file
settings.startF = [45, 44.5, 44, 43.5];
settings.endF = [44.5, 44, 43.5, 42.7];
settings.regdate = '(?<yr>\d\d)(?<mon>\d\d)(?<day>\d\d)(?<hr>\d\d)(?<min>\d\d)(?<s>\d\d)';
settings.kernelDir = '';
settings.kernelSite = '';
settings.kernelDepl = '';
REMORA.bm.settings = settings;