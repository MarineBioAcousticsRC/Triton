function nn_train_nnet

global REMORA

disp('Preparing to train network, please be patient.')
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
confusionMatrixEval = confusionmat(YPredEval,categorical(testLabelsAll));
bestScores = max(scoresEval,[],2);

% confusionmat(YPredEval(strongScores),categorical(testLabelsAll(strongScores)))
[~,filenameStem,~] = fileparts(REMORA.nn.train_net.trainFile);
filenameStem = strrep(filenameStem,'_bin_train','');
REMORA.nn.train_net.networkFilename = fullfile(REMORA.nn.train_net.outDir,[filenameStem,'_trainedNetwork.mat']);
REMORA.nn.train_net.evalResultsFilename =  fullfile(REMORA.nn.train_net.outDir,[filenameStem,'_evalScores.mat']);
save(REMORA.nn.train_net.networkFilename,'net')
save(REMORA.nn.train_net.evalResultsFilename,'confusionMatrixEval','YPredEval','scoresEval','testLabelsAll')

nn_fn_plotconfusion(testLabelsAll,YPredEval,typeNames)
nn_fn_plotaccuracy(REMORA.nn.train_net.evalResultsFilename)

%crossentropy(double(YPredEval),testLabelsAll)

accuracyPercent = 100*(sum(testLabelsAll == double(YPredEval))/size(testLabelsAll,1));
fprintf('Overall accuracy on test dataset: %0.2f%%\n',accuracyPercent)

nPlots = length(uLabels);
nRows = 3;
nCols = ceil(nPlots/nRows);
figure(210);clf;colormap(jet)
set(210,'name', 'Training Data')
for iR = 1:nPlots
    subplot(nCols,nRows,iR)
    imagesc(trainDataAll(trainLabelsAll==iR,:)')
    set(gca,'ydir','normal')
    title(sprintf('Category %0.0f',iR))
end

figure(211);clf;colormap(jet)
set(211,'name', 'Test Data')
for iR = 1:nPlots
    subplot(nCols,nRows,iR)
    imagesc(testDataAll(testLabelsAll==iR,:)')
    set(gca,'ydir','normal')
    title(sprintf('Category %0.0f',iR))
end

figure(212);clf;colormap(jet)
set(212,'name', 'Network Classifications on Test Set')
for iR = 1:nPlots
    subplot(nCols,nRows,iR)
    imagesc(testDataAll(double(YPredEval)==iR,:)')
    set(gca,'ydir','normal')
    title(sprintf('Category %0.0f',iR))
end
