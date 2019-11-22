function smHelpStrings = sm_cmpt_get_help_strings

% Airgun parameter choices:

smHelpStrings.indirHelp = 'Input directory where ltsa files are stored';

smHelpStrings.outdirHelp = 'Output directory where soundscape metric files will be saved';

smHelpStrings.fstartHelp = 'Define which LTSA file should be used to start computation';

smHelpStrings.bpassHelp = 'Define lower and upper frequency boundary of computation';

smHelpStrings.lfreqHelp = 'Low frequency boundary of computation in Hertz';

smHelpStrings.hfreqHelp = 'High frequency boundary of computation in Hertz';

smHelpStrings.avgtHelp = 'Define time bin size in seconds';

smHelpStrings.avgfHelp = 'Define frequency bin size for power spectral density in Hertz';

smHelpStrings.percHelp = 'Define what percentage of time bins should at least go into average';

smHelpStrings.atypeHelp = 'Select one or multiple soundscape metrics computations';

smHelpStrings.avgtypeHelp = 'Select one or multiple averaging types';

smHelpStrings.fifoHelp = 'Remove ''fist in/first out'' (FIFO) noise';

smHelpStrings.dwHelp = 'Remove disk write noise in HARP data';

smHelpStrings.strumHelp = 'Remove noise from flow or strumming';

smHelpStrings.calHelp = 'Select to calibrate data with either single value or transfer function';

smHelpStrings.svalHelp = 'Single value calibration adjusting with full system sensitivity';

smHelpStrings.caldbHelp = 'Single calibration value for full system sensitivity in decibels';
