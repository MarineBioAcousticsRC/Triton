function bm_init_batch_detector

global REMORA


%% Determine which species we would like to detect 
if strcmp(REMORA.bm.settings.species, 'Blue whale')
    disp_msg('Detecting blue whale B calls');
    bm_autodet_batch_ST;
% elseif strcmp(REMORA.bm.settings.species, 'Fin whale')
%     disp_msg('Detecting fin whale calls');
%     bm_autodet_fw_batch_ST;
end
end