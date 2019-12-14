function nn_train_nnet

global REMORA


% In matlab 2018+ this should work, OR if you have a GPU, AND if you have
% the deep learning toolbox.
load(REMORA.nn.train_net.trainFile);
% figure out weights based on distribution of labels.
uLabels = unique(trainLabelsAll);
[labelOccurence,~] = histc(trainLabelsAll, uLabels);
uLabelWeights = round(max(labelOccurence)./labelOccurence);
% TODO: display table of weights in command line.

REMORA.nn.train_net.labelWeights = uLabelWeights;


[myNetwork, trainPrefs] = nn_build_network;
trainDataAll(isnan(trainDataAll))=0;

train4D = table(mat2cell(trainDataAll,ones(size(trainDataAll,1),1)),categorical(trainLabelsAll));
%reshape(trainDataAll,[1,size(trainDataAll,2),1,...
%    size(trainDataAll,1)]);
%net = trainNetwork(train4D,categorical(trainLabelsAll),myNetwork,trainPrefs);
net = trainNetwork(train4D,myNetwork,trainPrefs);

% May need a solution for older matlabs and no toolbox. In that case, keras
% might be the thing.

[YPred,scores] = classify(net,train4D);

confusionmat(YPred,categorical(trainLabelsAll))

load(REMORA.nn.train_net.testFile);
testDataAll(isnan(testDataAll))=0;
test4D = table(mat2cell(testDataAll,ones(size(testDataAll,1),1)),categorical(testLabelsAll));

[YPredEval,scoresEval] = classify(net,test4D);
confusionmat(YPredEval,categorical(testLabelsAll))
bestScores = max(scoresEval,[],2);
strongScores = bestScores>.99;
confusionmat(YPredEval(strongScores),categorical(testLabelsAll(strongScores)))

1;
