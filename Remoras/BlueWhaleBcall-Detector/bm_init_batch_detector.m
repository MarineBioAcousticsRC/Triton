function bm_init_batch_detector

global REMORA


%% Determine which species we would like to detect 
if strcmp(REMORA.bm.settings.datatype, 'Wav')
    disp_msg('Detecting blue whale B calls in wav files');
    bm_autodet_batch_ST;

elseif strcmp(REMORA.bm.settings.datatype, 'XWav')
    disp_msg('Detecting blue whale B calls in xwav files');
%    bm_autodet_dir_HA;
    bm_autodet_dir_LB;

% elseif strcmp(REMORA.bm.settings.species, 'Fin whale')
%     disp_msg('Detecting fin whale calls');
%     bm_autodet_fw_batch_ST;
end
end