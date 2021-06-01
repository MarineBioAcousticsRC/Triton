function cH = nn_fn_plotconfusion(testLabelsAll,YPredEval,typeNames)
cH = figure;
confH = plotconfusion(categorical(testLabelsAll),YPredEval);
set(gca,'xticklabel',vertcat(typeNames,' '))
set(gca,'yticklabel',vertcat(typeNames,' '))
conf1=gca;
for iC = 1:length(conf1.Children)
    try
        set(conf1.Children(iC),'FontSize',8)
    catch
        continue
    end
end