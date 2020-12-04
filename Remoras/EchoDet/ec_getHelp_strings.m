function ecRunHelp = ec_getHelp_strings

%base settings information for echosounder detector
ecRunHelp.depName = 'Deployment name as written in input files';
ecRunHelp.echTemp = 'Full file path to echosounder template';
ecRunHelp.lowF = 'low bp filter cutoff in Hz';
ecRunHelp.highF = 'high bp filter cutoff in Hz';
ecRunHelp.prcTh = 'percent threshold for correlation between input signal and template';
ecRunHelp.gapT = 'minimum gap time in seconds between detections. Do not recommend modifying!';
ecRunHelp.thresholdC = 'Base value threshold for correlation between input signal and template';
ecRunHelp.threshPP = 'threshold for ddPP difference between noise sample preceding signal and signal. Set very low to be effectively ''off'' as it hasn''t proven useful yet';
ecRunHelp.ICI_range = 'allowable range for timing between detections';
ecRunHelp.ICIpad = 'time in seconds that will be added/subtracted to the mode time between detections to determine which detections to keep';
ecRunHelp.runIt = 'go for it you deserve this';