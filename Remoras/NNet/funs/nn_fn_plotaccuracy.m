function nn_fn_plotaccuracy(evalFileName)

load(evalFileName)
% precision/recall
accuracyWhole = [];
accuracySubset = [];
percClassified = [];
accuracyCutoffs = [0,50,75,85,90,95,98,99]./100;
bestScores = max(scoresEval,[],2);
for iA = 1:length(accuracyCutoffs)
    myScoresIdx = find(bestScores>=accuracyCutoffs(iA));
    percClassified(iA) = size(myScoresIdx,1)/size(testLabelsAll,1);
    nCorrect = sum(testLabelsAll(myScoresIdx) == double(YPredEval(myScoresIdx)));
    accuracyWhole(iA) = nCorrect/size(testLabelsAll,1);
    accuracySubset(iA) = nCorrect/size(myScoresIdx,1);
end 


figure(254);clf;plot(percClassified,accuracySubset,'o')
legend('Minimum Classification Score')
hold on
for iA = 1:length(accuracyCutoffs)
    text((percClassified(iA)+.01),accuracySubset(iA),num2str(accuracyCutoffs(iA)),...
        'HorizontalAlignment','Left','VerticalAlignment','bottom')
end
xlabel('Proportion of Data Classified')
ylabel('Classification Accuracy')
grid on