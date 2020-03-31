function init_batch_detector

global REMORA


%% Determine which data type we're dealing with 
if REMORA.bm.settings.HARPdata == true
    %disp_msg('analysing HARP data');
    autodet_wav_test_HARP.m
elseif REMORA.bm.settings.SoundTrap == true
    %disp_msg('analysing Sound Trap data');
    bm_autodet_batch_ST.m
end
end