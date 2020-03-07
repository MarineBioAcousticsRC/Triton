function fw_init_settings

global REMORA

settings.userid = 'jdoe';
settings.inDir = '';
settings.outDir  = '';
settings.binsize = 60;
settings.granularity = 'binned';
settings.thresh = NaN; % threshold for peak detection  
settings.callfreq = 22;
settings.nfreq1 = 10;
settings.nfreq2 = 34;
settings.HARPdata = false; % if HARP data, set to true
settings.SoundTrap = true; % if not Sound Trap data, set to false
settings.saveCsv = true; % save results to a .csv file


REMORA.bw.settings = settings;