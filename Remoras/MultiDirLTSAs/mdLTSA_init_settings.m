function mdLTSA_init_settings

global REMORA

settings.inDir = '';
settings.outDir  = '';
settings.tave = '5';
settings.dfreq = '100';
settings.dataType = 'XWAV'; % default is XWAV

REMORA.mdLTSA.settings = settings;

end