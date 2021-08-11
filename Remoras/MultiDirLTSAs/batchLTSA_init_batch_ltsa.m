function batchLTSA_init_batch_ltsa

global REMORA

%% Actually run the mk_ltsa code! 
    disp_msg('Creating LTSAs');
    batchLTSA_mk_ltsa_batch_precheck
    batchLTSA_mk_ltsa_batch
    
end