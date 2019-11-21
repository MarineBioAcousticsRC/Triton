function [layerSet, trainPrefs] = nn_build_network

global REMORA
% should check that train and test data have same dimensions.

trainFileObj = matfile(REMORA.nn.train_net.trainFile);
testFileObj = matfile(REMORA.nn.train_net.testFile);

% Sanity check that train and test data have same dimensions.
trainDataSize = size(trainFileObj.trainDataAll);%figure out dims of training data.
testDataSize =  size(testFileObj.testDataAll);%figure out dims of training data.
numClasses = length(unique(trainFileObj.trainLabelsAll));
if trainDataSize(2) ~= testDataSize(2)
    error('Dimensions of training and test sets do not match.')
end

layerSet = imageInputLayer([trainDataSize(2),1,1]);

for iD = 1:REMORA.nn.train_net.nHiddenLayers
    layerSet = [layerSet;...
    fullyConnectedLayer(REMORA.nn.train_net.hLayerSize);...
    reluLayer;...
    dropoutLayer(REMORA.nn.train_net.dropout/100)];

end

layerSet = [layerSet;...
	fullyConnectedLayer(numClasses);...
	softmaxLayer;...
	classificationLayer];

trainPrefs = trainingOptions('sgdm',...
    'MaxEpochs',REMORA.nn.train_net.nEpochs, ...
    'MiniBatchSize',REMORA.nn.train_net.batchSize
    );

   % 'Shuffle','every-epoch');% ...
   % 'Plots','training-progress');


