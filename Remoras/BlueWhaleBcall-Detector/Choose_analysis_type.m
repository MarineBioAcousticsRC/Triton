function init_batch_detector

global REMORA


%% Determine which data type we're dealing with 
if REMORA.bw.settings.HARPdata == true
    %disp_msg('analysing HARP data');
    autodet_wav_test_HARP.m
elseif REMORA.bw.settings.SoundTrap == true
    %disp_msg('analysing Sound Trap data');
    bw_autodet_batch_ST.m
end
end