function agHelpStrings = ag_get_help_strings

% Airgun parameter choices:

agHelpStrings.baseDirHelp = 'Base directory where audio files are stored.';

agHelpStrings.outDirHelp = 'Directory where detector files will be stored.';

agHelpStrings.datatypeHelp = 'Source of the data, pick "HARP" for x.wav, "Sound Trap" for wav files.';
agHelpStrings.thresholdHelp = 'Threshold for correlation coefficient.';

agHelpStrings.thresholdOffsetHelp = 'Threshold offset above median square of correlation coefficient';
 
agHelpStrings.minTimeHelp = 'Minimum time distance between consecutive explosions.';

agHelpStrings.noiseSampHelp = 'Number of noise samples to be pulled out.';

agHelpStrings.rmsNoiseAfterHelp = 'RMS noise after signal <rmsAS (dB) difference will be eliminated.';

agHelpStrings.rmsNoiseBeforeHelp = 'RMS noise before signal.';

agHelpStrings.ppNoiseAfterHelp = 'PP noise after signal <ppAS (dB) difference will be eliminated.';

agHelpStrings.ppNoiseBeforeHelp =  'PP noise before signal.';

agHelpStrings.durAfterHelp = 'Durations >= durAfter_s (s) will be eliminated.';

agHelpStrings.durBeforeHelp = 'Durations >= dur_s (s) will be eliminated.';

