function bw_init_settings

global REMORA

settings.inDir = '';
settings.outDir  = '';
settings.thresh = 30; % threshold for peak detection  
settings.species = 'Blue whale';
settings.HARPdata = false; % if HARP data, set to true
settings.SoundTrap = true; % if not Sound Trap data, set to false
settings.saveCsv = true; % save results to a .csv file


REMORA.bw.settings = settings;