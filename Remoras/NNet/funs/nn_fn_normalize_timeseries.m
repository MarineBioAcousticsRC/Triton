function normTS = nn_fn_normalize_timeseries(TS)
meanTS = TS - mean(TS,2);
% stdTS = std(TS,0,2);
maxTS = mean(max(abs(meanTS),[],2),2);
normTS = meanTS./maxTS;
normTS(isnan(normTS)) = 0;
normTS = normTS/2+0.5;
