function dt_runFullDetector()

global REMORA


detParams = REMORA.ship_dt.detParams;
disp_msg('Starting detector on directory of files');
disp_msg('Detector progress will appear in Matlab console');

disp('Starting Ship detector')
% Call spice detector 
ship_detector(detParams);