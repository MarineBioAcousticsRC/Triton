function mdLTSA_init_batch_detector

global REMORA


%% Actually run the mk_ltsa code! 
    disp_msg('Creating LTSAs');
    bm_autodet_batch_ST;
    
end