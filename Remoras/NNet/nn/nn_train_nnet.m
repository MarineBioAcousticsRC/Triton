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

if ~isdir(REMORA.nn.train_net.outDir)
    mkdir(REMORA.nn.train_net.outDir)
end
% make a file to write stuff to.
diary(fullfile(REMORA.nn.train_net.outDir,['NNet_train_',datestr(now,'YYDDMM_hhmmss'),'.txt']));
diary on
% figure out weights based on distribution of labels.
uLabels = unique(trainLabelsAll);
[labelOccurence,~] = histc(trainLabelsAll, uLabels);
uLabelWeights = round(max(labelOccurence)./labelOccurence);
% TODO: display table of weights in command line.

REMORA.nn.train_net.labelWeights = uLabelWeights;


[myNetwork, trainPrefs] = nn_build_network
fprintf('\n\n\n')

trainDataAll(isnan(trainDataAll))=0;

%trainDataAll(:,182:381)=abs(trainDataAll(:,182:381)-.5)*2;

train4D = table(mat2cell(trainDataAll,ones(size(trainDataAll,1),1)),categorical(trainLabelsAll));
%reshape(trainDataAll,[1,size(trainDataAll,2),1,...
%    size(trainDataAll,1)]);
%net = trainNetwork(train4D,categorical(trainLabelsAll),myNetwork,trainPrefs);
net = trainNetwork(train4D,myNetwork,trainPrefs);
fprintf('\n\n Confusion matrix:\n')

% May need a solution for older matlabs and no toolbox. In that case, keras
% might be the thing.

[YPred,scores] = classify(net,train4D);

confusionmat(YPred,categorical(trainLabelsAll))
fprintf('\n\n\n')

load(REMORA.nn.train_net.testFile);
testDataAll(isnan(testDataAll))=0;
% testDataAll(:,182:381)=abs(testDataAll(:,182:381)-.5)*2;
test4D = table(mat2cell(testDataAll,ones(size(testDataAll,1),1)),categorical(testLabelsAll));

[YPredTrain,scoresTrain] = classify(net,train4D);

[YPredEval,scoresEval] = classify(net,test4D);
confusionMatrixEval = confusionmat(YPredEval,categorical(testLabelsAll));
bestScores = max(scoresEval,[],2);

% confusionmat(YPredEval(strongScores),categorical(testLabelsAll(strongScores)))
[~,filenameStem,~] = fileparts(REMORA.nn.train_net.trainFile);
filenameStem = strrep(filenameStem,'_bin_train','');
REMORA.nn.train_net.networkFilename = fullfile(REMORA.nn.train_net.outDir,[filenameStem,'_trainedNetwork.mat']);
REMORA.nn.train_net.evalResultsFilename =  fullfile(REMORA.nn.train_net.outDir,[filenameStem,'_evalScores.mat']);

netTrainingInfo =  REMORA.nn.train_net.trainFile;
save(REMORA.nn.train_net.networkFilename,'net','netTrainingInfo','trainTestSetInfo','typeNames')
save(REMORA.nn.train_net.evalResultsFilename,'confusionMatrixEval','YPredEval',...
    'scoresEval','testLabelsAll','netTrainingInfo','trainTestSetInfo','typeNames')



REMORA.fig.nn.training_plots{6} = nn_fn_plotconfusion(trainLabelsAll,YPredTrain,typeNames);
REMORA.fig.nn.training_plots{6};
title('Confusion Matrix: Training Data')
REMORA.fig.nn.training_plots{7} = nn_fn_plotconfusion(testLabelsAll,YPredEval,typeNames);
REMORA.fig.nn.training_plots{7};
title('Confusion Matrix: Evaluation Data')

nn_fn_plotaccuracy(REMORA.nn.train_net.evalResultsFilename)

%crossentropy(double(YPredEval),testLabelsAll)

accuracyPercent = 100*(sum(testLabelsAll == double(YPredEval))/size(testLabelsAll,1));
fprintf('Overall accuracy on test dataset: %0.2f%%\n\n\n',accuracyPercent)

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
    title(sprintf('Category %0.0f',iR))
end

REMORA.fig.nn.training_plots{2} = figure;
clf;colormap(jet)
set(REMORA.fig.nn.training_plots{2},'name', 'Test Data')
for iR = 1:nPlots
    subplot(nRows,nCols,iR)
    imagesc(testDataAll(testLabelsAll==iR,:)')
    set(gca,'ydir','normal')
    title(typeNames{iR})
end

REMORA.fig.nn.training_plots{3} = figure;
clf;colormap(jet)
set(REMORA.fig.nn.training_plots{3},'name', 'Network Classifications on Test Set')
for iR = 1:nPlots
    subplot(nRows,nCols,iR)
    imagesc(testDataAll(double(YPredEval)==iR,:)')
    set(gca,'ydir','normal')
    title(typeNames{iR})
end

REMORA.fig.nn.training_plots{4} = figure;
clf;colormap(jet)
set(REMORA.fig.nn.training_plots{4} ,'name', 'Misclassified Events in on Test Set')
misclassSet = double(YPredEval)~=testLabelsAll;
for iR = 1:nPlots
    thisType = double(YPredEval)==iR;
    misclassIdx = find(thisType & misclassSet);
    subplot(nRows,nCols,iR)
    imagesc(testDataAll(misclassIdx,:)')
    set(gca,'ydir','normal')
    title(typeNames{iR})
end

diary off

if REMORA.nn.train_net.saveFigs
    nn_fn_save_training_figs(filenameStem)
end

disp('Training complete\n')
fprintf('Output saved to:    %s\n\n',REMORA.nn.train_net.outDir)
