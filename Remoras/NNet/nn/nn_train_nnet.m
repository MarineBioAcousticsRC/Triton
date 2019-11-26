function nn_train_nnet

global REMORA


% In matlab 2018+ this should work, OR if you have a GPU, AND if you have
% the deep learning toolbox.

[myNetwork, trainPrefs] = nn_build_network;

load(REMORA.nn.train_net.trainFile);
trainDataAll(isnan(trainDataAll))=0;
train4D = reshape(trainDataAll,[size(trainDataAll,2),1,1,...
    size(trainDataAll,1)]);
net = trainNetwork(train4D,categorical(trainLabelsAll),myNetwork,trainPrefs);

% May need a solution for older matlabs and no toolbox. In that case, keras
% might be the thing.

[YPred,scores] = classify(net,train4D);

confusionmat(YPred,categorical(trainLabelsAll))