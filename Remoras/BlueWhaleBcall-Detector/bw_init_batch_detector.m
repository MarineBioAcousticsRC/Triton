function bw_init_batch_detector

global REMORA


%% Determine which species we would like to detect 
if strcmp(REMORA.bw.settings.species, 'Blue whale')
    disp_msg('Detecting blue whale B calls');
    bw_autodet_batch_ST;
elseif strcmp(REMORA.bw.settings.species, 'Fin whale')
    disp_msg('Detecting fin whale calls');
    bw_autodet_fw_batch_ST;
end
end