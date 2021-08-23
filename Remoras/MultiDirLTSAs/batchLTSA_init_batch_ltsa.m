function batchLTSA_init_batch_ltsa

global REMORA PARAMS

%% Actually run the mk_ltsa code! 
    disp_msg('Creating LTSAs');
    precheck = batchLTSA_mk_batch_ltsa_precheck;
    batchLTSA_mk_batch_ltsa(precheck);
    
end