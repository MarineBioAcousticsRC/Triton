function nn_train_nnet

global REMORA

disp('Preparing to train network, please be patient.')

%check for and close old figures
if isfield(REMORA.fig.nn, 'training_plots') && ~isempty(REMORA.fig.nn.training_plots)
    for iFig = 1:size(REMORA.fig.nn.training_plots,2)
        if ~isempty(REMORA.fig.nn.training_plots{iFig}) && isvalid(REMORA.fig.nn.training_plots{iFig})
            close(REMORA.fig.nn.training_plots{iFig})
        end
    end
end
% having trouble closing confusion matrices, so do this instead.
figList = get(groot, 'Children');
confusionFigs = find(~cellfun(@isempty,strfind({figList(:).Name},'plotconfusion')));
if sum(confusionFigs)>1
    close(figList(confusionFigs).Name)
end

REMORA.fig.nn.training_plots = [];

% In matlab 2018+ this should work, OR if you have a GPU, AND if you have
% the deep learning toolbox.
load(REMORA.nn.train_net.trainFile);
%trainDataAll(:,191+200+1:(191+200+96+100)) = [];
if ~isdir(REMORA.nn.train_net.outDir)
    mkdir(REMORA.nn.train_net.outDir)
end
% make a file to write stuff to.
diary(fullfile(REMORA.nn.train_net.outDir,['NNet_train_',datestr(now,'YYDDMM_hhmmss'),'.txt']));
diary on

% set flag for wether or not to use validation set
REMORA.nn.train_test_set.validationTF = 0;
if isfield(REMORA.nn.train_net,'validFile') && ~isempty(REMORA.nn.train_net.validFile)
    REMORA.nn.train_test_set.validationTF = 1;
end

% figure out weights based on distribution of labels.
uLabels = unique(trainLabelsAll);
[labelOccurence,~] = histc(trainLabelsAll, uLabels);
uLabelWeights = round(max(labelOccurence)./labelOccurence);
% TODO: display table of weights in command line.

REMORA.nn.train_net.labelWeights = uLabelWeights;


fprintf('\n\n\n')
trainDataAll(isnan(trainDataAll))=0;

trainTestSetInfo.standardizeAll = 1;
if trainTestSetInfo.standardizeAll
    trainDataAll = nn_fn_standardize_data(trainTestSetInfo,trainDataAll);
end

trainDataAll = min(abs(trainDataAll),1);
%trainDataAll(:,182:381)=abs(trainDataAll(:,182:381)-.5)*2;
%train4D = table(mat2cell(trainDataAll,ones(size(trainDataAll,1),1)),categorical(trainLabelsAll));
%reshape(trainDataAll,[1,size(trainDataAll,2),1,...
%    size(trainDataAll,1)]);
%net = trainNetwork(train4D,categorical(trainLabelsAll),myNetwork,trainPrefs);
[myNetwork, trainPrefs] = nn_build_network(trainTestSetInfo)


net = trainnet(trainDataAll,categorical(trainLabelsAll),myNetwork,"crossentropy",trainPrefs);

if min(min(trainDataAll))<-1
    normMin = -1;
else
    normMin = 0;
end
fprintf('\n\n Confusion matrix:\n')

% May need a solution for older matlabs and no toolbox. In that case, keras
% might be the thing.

scores = predict(net,trainDataAll);
[YPred,score] = scores2label(scores,categorical(uLabels));

confusionmat(YPred,categorical(trainLabelsAll))
fprintf('\n\n\n')

load(REMORA.nn.train_net.testFile,'testDataAll','testLabelsAll');
%testDataAll(:,191+200+1:(191+200+96+100)) = [];

testDataAll(isnan(testDataAll))=0;
% testDataAll(:,182:381)=abs(testDataAll(:,182:381)-.5)*2;
if trainTestSetInfo.standardizeAll
    normSpec1 = testDataAll(:,1:trainTestSetInfo.setSpecHDim)-trainTestSetInfo.specStd(1);
    testDataAll(:,1:trainTestSetInfo.setSpecHDim) = normSpec1./(trainTestSetInfo.specStd(2)-trainTestSetInfo.specStd(1));
    
    %wavestart = trainTestSetInfo.setSpecHDim+trainTestSetInfo.setICIHDim+1;
    testDataAll(:,ICIstart:(ICIstart+trainTestSetInfo.setICIHDim-1)) = testDataAll(:,ICIstart:(ICIstart+trainTestSetInfo.setICIHDim-1))/trainTestSetInfo.iciStd(1);
    %maxWave= max( testDataAll(:,wavestart:(wavestart+trainTestSetInfo.setWaveHDim-1)),[],2);
    testDataAll(:,wavestart:(wavestart+trainTestSetInfo.setWaveHDim-1)) = testDataAll(:,wavestart:(wavestart+trainTestSetInfo.setWaveHDim-1))./trainTestSetInfo.maxWave;


    testDataAll(:,(end-neighborWidth):end) = testDataAll(:,(end-neighborWidth):end)/20;

end
%test4D = table(mat2cell(testDataAll,ones(size(testDataAll,1),1)),categorical(testLabelsAll));
testDataAll = min(abs(testDataAll),1);

scoresAllTrain = predict(net,trainDataAll);
[YPredTrain,scoresTrain] = scores2label(scoresAllTrain,categorical(uLabels));

scoresAllEval = predict(net,testDataAll);
[YPredEval,scoresEval] = scores2label(scoresAllEval,categorical(uLabels));

confusionMatrixEval = confusionmat(YPredEval,categorical(testLabelsAll));
bestScores = max(scoresEval,[],2);

% confusionmat(YPredEval(strongScores),categorical(testLabelsAll(strongScores)))
[~,filenameStem,~] = fileparts(REMORA.nn.train_net.trainFile);
if contains(filenameStem,'_bin_train')
    filenameStem = strrep(filenameStem,'_bin_train','');
    REMORA.nn.train_net.networkFilename = fullfile(REMORA.nn.train_net.outDir,[filenameStem,'_trainedNetwork_bin.mat']);
    REMORA.nn.train_net.evalResultsFilename =  fullfile(REMORA.nn.train_net.outDir,[filenameStem,'_evalScores_bin.mat']);
elseif contains(filenameStem,'_det_train')
    filenameStem = strrep(filenameStem,'_det_train','');
    REMORA.nn.train_net.networkFilename = fullfile(REMORA.nn.train_net.outDir,[filenameStem,'_trainedNetwork_det.mat']);
    REMORA.nn.train_net.evalResultsFilename =  fullfile(REMORA.nn.train_net.outDir,[filenameStem,'_evalScores_det.mat']);
end

netTrainingInfo =  REMORA.nn.train_net.trainFile;
save(REMORA.nn.train_net.networkFilename,'net','netTrainingInfo','trainTestSetInfo','typeNames','trainPrefs')
save(REMORA.nn.train_net.evalResultsFilename,'confusionMatrixEval','YPredEval',...
    'scoresEval','testLabelsAll','netTrainingInfo','trainTestSetInfo','typeNames')



REMORA.fig.nn.training_plots{6} = nn_fn_plotconfusionChart(trainLabelsAll,YPredTrain,typeNames);
REMORA.fig.nn.training_plots{6};
title('Confusion Matrix: Training Data')
REMORA.fig.nn.training_plots{7} = nn_fn_plotconfusionChart(testLabelsAll,YPredEval,typeNames);
REMORA.fig.nn.training_plots{7};
title('Confusion Matrix: Evaluation Data')

nn_fn_plotaccuracy(REMORA.nn.train_net.evalResultsFilename)

%crossentropy(double(YPredEval),testLabelsAll)

accuracyPercent = 100*(sum(testLabelsAll == double(YPredEval))/size(testLabelsAll,1));
fprintf('Overall accuracy on test dataset: %0.2f%%\n\n\n',accuracyPercent)

%%% TODO: make normalization indices informed by prior steps!!!
% trainDataNorm = [nn_fn_normalize_spectrum(trainDataAll(:,1:181)),nn_fn_normalize_timeseries(trainDataAll(:,192:end))];
nPlots = length(uLabels);
nRows = 3;
nCols = ceil(nPlots/nRows);
REMORA.fig.nn.training_plots{1} = figure;
clf;colormap(jet)
set(REMORA.fig.nn.training_plots{1},'name', 'Training Data')
for iR = 1:nPlots
    subplot(nRows,nCols,iR)
    
    imagesc(trainDataAll(trainLabelsAll==iR,:)')
    set(gca,'ydir','normal')
    title(typeNames{iR})
    set(gca,'clim',[normMin,1])
end

REMORA.fig.nn.training_plots{2} = figure;
clf;colormap(jet)
set(REMORA.fig.nn.training_plots{2},'name', 'Test Data')
%testDataNorm = [nn_fn_normalize_spectrum(testDataAll(:,1:181)),nn_fn_normalize_timeseries(testDataAll(:,192:end))];

for iR = 1:nPlots
    subplot(nRows,nCols,iR)
    imagesc(testDataAll(testLabelsAll==iR,:)')
    set(gca,'ydir','normal')
    title(typeNames{iR})
    set(gca,'clim',[normMin,1])
end

REMORA.fig.nn.training_plots{3} = figure;
clf;colormap(jet)
set(REMORA.fig.nn.training_plots{3},'name', 'Network Classifications on Test Set')
for iR = 1:nPlots
    subplot(nRows,nCols,iR)
    idxToPlot = find(double(YPredEval)==iR);
    [classScore,plotOrder] = sort(bestScores(idxToPlot),'descend');
    imagesc(testDataAll(idxToPlot(plotOrder),:)')
    set(gca,'ydir','normal')
    title(typeNames{iR})
    set(gca,'clim',[normMin,1])
end

REMORA.fig.nn.training_plots{4} = figure;
clf;colormap(jet)
set(REMORA.fig.nn.training_plots{4} ,'name', 'Misclassified Events in Test Set')
misclassSet = double(YPredEval)~=testLabelsAll;
for iR = 1:nPlots
    thisType = double(YPredEval)==iR;
    misclassIdx = find(thisType & misclassSet);
    [classScore,plotOrder] = sort(bestScores(misclassIdx),'descend');

    subplot(nRows,nCols,iR)
    imagesc(testDataAll(misclassIdx(plotOrder),:)')
    set(gca,'ydir','normal')
    title(typeNames{iR})   
    set(gca,'clim',[normMin,1])

end


REMORA.fig.nn.training_plots{5} = figure;
clf;colormap(jet)
set(REMORA.fig.nn.training_plots{5} ,'name', 'Misclassified Events in Training Set')
misclassSetTrain = double(YPredTrain)~=trainLabelsAll;
bestScoresTrain = max(scoresTrain,[],2);

for iR = 1:nPlots
    thisType = double(YPredTrain)==iR;
    misclassIdxTrain = find(thisType & misclassSetTrain);
    [~,plotOrder] = sort(bestScoresTrain(misclassIdxTrain),'descend');

    subplot(nRows,nCols,iR)
    imagesc(trainDataAll(misclassIdxTrain(plotOrder),:)')
    set(gca,'ydir','normal')
    title(typeNames{iR})   
    set(gca,'clim',[normMin,1])

end
diary off

if REMORA.nn.train_net.saveFigs
    nn_fn_save_training_figs(filenameStem)
end

disp('Training complete')
fprintf('Output saved to:    %s\n\n',REMORA.nn.train_net.outDir)
