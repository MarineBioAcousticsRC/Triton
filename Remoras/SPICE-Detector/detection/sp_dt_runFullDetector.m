function sp_dt_runFullDetector()

global REMORA


detParams = REMORA.spice_dt.detParams;
disp_msg('Starting detector on directory of files');
disp_msg('Detector progress will appear in Matlab console');

disp('Starting Spice detector')
% Call spice detector 
spice_detector(detParams);