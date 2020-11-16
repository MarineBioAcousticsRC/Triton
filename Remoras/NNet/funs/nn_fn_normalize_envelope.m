function normEnvTS = nn_fn_normalize_envelope(TS)
envTS = abs(hilbert(TS));
% stdTS = std(TS,0,2);
normEnvTS = envTS./max(envTS,[],2);
1;