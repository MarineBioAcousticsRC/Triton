function normSpec = nn_fn_normalize_spectrum(SP)
% minNormSpec = SP - mean(min(SP,[],2));
minNormSpec = SP - min(SP,[],2);
minNormSpec = max(minNormSpec,0);
normSpec = minNormSpec./(max(minNormSpec,[],2));