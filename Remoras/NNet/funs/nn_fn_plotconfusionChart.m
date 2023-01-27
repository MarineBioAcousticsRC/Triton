function cH = nn_fn_plotconfusionChart(testLabelsAll,YPredEval,typeNames)
cH = figure('Position',[[188 215 700 550]]);
testLabelsAllAbrev = categorical(testLabelsAll,(1:size(typeNames,1)),typeNames);
YPredEvalAbrev = renamecats(YPredEval,typeNames);
confH = confusionchart(testLabelsAllAbrev,YPredEvalAbrev);
confH.ColumnSummary = 'column-normalized';
confH.RowSummary = 'row-normalized';
confH.FontSize = 8;
