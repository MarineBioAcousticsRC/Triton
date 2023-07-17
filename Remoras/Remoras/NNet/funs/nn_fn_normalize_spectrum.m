function normSpec = nn_fn_normalize_spectrum(SP)
% original
% minNormSpec = SP - min(SP,[],2);
% minNormSpec = max(minNormSpec,0);
% normSpec = minNormSpec./(max(minNormSpec,[],2));



% subtract some typical min in dB including TF, and divide by a typical
% max, use standard vals
 minNormSpec = SP - 80;
% minNormSpec = max(minNormSpec,0);
normSpec = minNormSpec./(130-80);

1;