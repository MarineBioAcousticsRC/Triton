function ltTlabHelp = lt_tLab_getHelp_strings

%%%%tLab settings choices, helpful strings for figuring out what the hell
%%%%to do

ltTlabHelp.saveDir = 'Where do you want to save your output?';
ltTlabHelp.filePrefix = 'What do you want your output file prefix to be?';
ltTlabHelp.filePath = 'Full path to your file for conversion';
ltTlabHelp.FDpath = 'Full path to false detections file';
ltTlabHelp.rmvFDs = 'Check box to remove false detections if filePath is to TPWS file and want to remove FDs';

%%what kind of labels do you want?
%ltTlabHelp.trueL = 'Check to create labels';
ltTlabHelp.trueLabel = 'Name for output label. Overwritten with detEdit labels if using ID file as input';

%%other
ltTlabHelp.timeOffset = 'time offset in years; set to 0 if no offset. PIFSC data originally used started with different year than triton datenums';
ltTlabHelp.dur = 'duration for click labels in seconds, necessary to create an end time for data coming from detEdit. Default is a good option for echolocation clicks.'; 

ltTlabHelp.runButton = 'I mean like... run the code, man';