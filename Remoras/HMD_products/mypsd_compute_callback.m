function mypsd_compute_callback(~, ~)
global REMORA PARAMS

PARAMS.ltsa.inputDir = get(REMORA.mypsd.gui.inputDir, 'String');
PARAMS.ltsa.outputDir = get(REMORA.mypsd.gui.outputDir, 'String');
PARAMS.tfFilePath = get(REMORA.mypsd.gui.tfFilePath, 'String');

PARAMS.ltsa.organization = get(REMORA.mypsd.gui.organization, 'String');
PARAMS.ltsa.project = get(REMORA.mypsd.gui.project, 'String');
PARAMS.ltsa.site = get(REMORA.mypsd.gui.site, 'String');
PARAMS.ltsa.startF = get(REMORA.mypsd.gui.startFreq, 'String');
PARAMS.ltsa.endF = get(REMORA.mypsd.gui.endFreq, 'String');



% set for HARP hybrid millidecade soundscape metrics
PARAMS.ltsa.ftype = 2;      % 1= WAVE, 2=XWAV
PARAMS.ltsa.dtype = 1;      % 1 = HARP, 2 = ARP, 3 = OBS, 4 = towed array or sonobuoy, 5 = SoundTrap
PARAMS.ltsa.tave = 1;       % averaging time [seconds]
PARAMS.ltsa.dfreq = 1;      % frequency bin size [Hz]
PARAMS.ltsa.ndays = 1;      % length of LTSA [days]
PARAMS.ltsa.nstart = 1;     % start number of LTSA file (e.g. want to start at week 2)

% Confirm input
disp(['-------------------- HARP HMD Input Parameters --------------------'])
disp(['Input Dir: ', PARAMS.ltsa.inputDir])
disp(['Output Dir: ', PARAMS.ltsa.outputDir])
disp(['Organization: ', PARAMS.ltsa.organization])
disp(['Project: ', PARAMS.ltsa.project])
disp(['Site: ', PARAMS.ltsa.site])
disp(['Start Frequency (Hz): ', PARAMS.ltsa.startF])
disp(['End Frequency (Hz): ', PARAMS.ltsa.endF])

%disp(['File: ',  PARAMS.ltsa.outfname])


% Run actual HMD computation
mypsd_compute
end