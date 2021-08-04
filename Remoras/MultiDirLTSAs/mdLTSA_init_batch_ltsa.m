function mdLTSA_init_batch_ltsa

global REMORA

%% Actually run the mk_ltsa code! 
    disp_msg('Creating LTSAs');
    mdLTSA_mk_ltsa_batch
    
end