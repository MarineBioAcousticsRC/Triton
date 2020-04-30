function nn_fn_plotconfusion(testLabelsAll,YPredEval,typeNames)
figure(253);clf;
confH = plotconfusion(categorical(testLabelsAll),YPredEval);
set(gca,'xticklabel',vertcat(typeNames,' '))
set(gca,'yticklabel',vertcat(typeNames,' '))
