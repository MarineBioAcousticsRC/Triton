function exHelpStrings = ex_get_help_strings

% Explosion parameter choices:

exHelpStrings.baseDirHelp = 'Base directory where audio files are stored.';

exHelpStrings.outDirHelp = 'Directory where detector files will be stored.';

exHelpStrings.datatypeHelp = 'For .xwav files, choose HARP. For .wav files, choose Sound Trap.';

exHelpStrings.thresholdHelp = 'Threshold for correlation coefficient.';

exHelpStrings.thresholdOffsetHelp = 'Threshold offset above median square of correlation coefficient';
 
exHelpStrings.minTimeHelp = 'Minimum time distance between consecutive explosions.';

exHelpStrings.noiseSampHelp = 'Number of noise samples to be pulled out.';

exHelpStrings.rmsNoiseAfterHelp = 'RMS noise after signal <rmsAS (dB) difference will be eliminated.';

exHelpStrings.rmsNoiseBeforeHelp = 'RMS noise before signal.';

exHelpStrings.ppNoiseAfterHelp = 'PP noise after signal <ppAS (dB) difference will be eliminated.';

exHelpStrings.ppNoiseBeforeHelp =  'PP noise before signal.';

exHelpStrings.durAfterHelp = 'Durations >= durAfter_s (s) will be eliminated.';

exHelpStrings.durBeforeHelp = 'Durations >= dur_s (s) will be eliminated.';

