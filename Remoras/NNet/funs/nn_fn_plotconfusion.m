function cH = nn_fn_plotconfusion(testLabelsAll,YPredEval,typeNames)
cH = figure;
confH = plotconfusion(categorical(testLabelsAll),YPredEval);
set(gca,'xticklabel',vertcat(typeNames,' '))
set(gca,'yticklabel',vertcat(typeNames,' '))
