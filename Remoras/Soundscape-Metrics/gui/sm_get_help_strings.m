function smHelpStrings = sm_get_help_strings

% Airgun parameter choices:

smHelpStrings.indirHelp = 'Input directory where audio files are stored';

smHelpStrings.outdirHelp = 'Output directory where LTSA files will be stored';

smHelpStrings.taveHelp = 'Spectral averaging time in seconds';

smHelpStrings.dfreqHelp = 'Frequency bin size in Hz';
 
smHelpStrings.ndaysHelp = 'Length of each output LTSA in days';

smHelpStrings.ftypeHelp = 'File type: 1 = WAV; 2 = XWAV';

smHelpStrings.dtypeHelp = 'Data type: 1 = HARP; 4 = towed array/sonobuoy; 5 = SoundTrap';

smHelpStrings.chHelp = 'Data channel for LTSA calculation, numeric entry';

