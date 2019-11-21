function [savedTrainFile,savedTestFile] = nn_fn_balanced_input_bin(inDir,saveDir,saveName,...
    trainPercent,nExamples,boutGap)

% inDir = 'E:\Data\John Reports\WAT\WAT_2018_trainingExamples';
typeList = dir(inDir);
badDirs = find(~cellfun(@isempty, strfind({typeList(:).name},'.')));
typeList(badDirs) = [];

saveNameTrain = [saveName ,'_bin_train.mat'];
saveNameTest = [saveName ,'_bin_test.mat'];

if ~exist(saveDir,'dir')
    mkdir(saveDir)
end

minGapTimeHour = boutGap/60;
minGapTimeDnum = minGapTimeHour/24;    % gap time in datenum
mergedTypes = {};
typeNames =  {};
nClicks = [];
saveNames = {};
trainSetMSP = {};
trainSetICI = {};
testSetLabels = [];
trainSetSize = [];

for iD = 1:size(typeList,1)
    fprintf('Beginning type %0.0f, name: %s\n',iD, typeList(iD).name)

    thisTypeDir = fullfile(typeList(iD).folder,typeList(iD).name);
    [~,typeID] = fileparts(thisTypeDir);
    typeNames{iD,1} = typeID;
    matList = dir(fullfile(thisTypeDir,'*.mat'));
   
    clusterSpectra = [];
    clusterICI = [];
    clusterTimes = [];
    for iM = 1:size(matList,1)
        
        inFile = load(fullfile(matList(iM).folder,matList(iM).name));
        thisSpec = inFile.thisType.Tfinal{1};
%         if size(thisSpec,2)>188
%             thisSpec = thisSpec(:,2:end);
%         end
        thisBinTime = inFile.thisType.Tfinal{7};
        clusterTimes = [clusterTimes;thisBinTime];
        clusterSpectra = [clusterSpectra;thisSpec];
        clusterICI = [clusterICI;inFile.thisType.Tfinal{2}];
    end
    [clusterTimes,I] = sort(clusterTimes);
    clusterSpectra = clusterSpectra(I,:);
    clusterICI = clusterICI(I,:);

    % find bouts
    [boutSize,boutStartIdx,...
        boutStartTime,boutEndIdx,...
        boutEndTime,boutMembership] = nn_fn_findBouts(clusterTimes,minGapTimeDnum);
    nBouts = length(boutSize);
    fprintf('   %0.0f encounters found\n',nBouts)
    trainBoutIdx = sort(randperm(nBouts,round(nBouts*(trainPercent/100))))';
    [~,testBoutIdx] = setdiff(1:nBouts,trainBoutIdx);
    fprintf('   %0.0f train encounters selected\n',length(trainBoutIdx))
    fprintf('   %0.0f test encounters selected\n',length(testBoutIdx))
    
    
    % pull out training data
    boutSizeTrain = boutSize(trainBoutIdx);
    boutStartIdxTrain = boutStartIdx(trainBoutIdx);
    boutEndIdxTrain = boutEndIdx(trainBoutIdx);
    
    % randomly select desired number of events across bouts
    nBinsTrain = sum(boutSizeTrain);
    binIndicesTrain = sort(randi(nBinsTrain,1,nExamples));
    clusterIdxTrainSet = vertcat(boutMembership{trainBoutIdx});
    trainSetMSP{iD} = clusterSpectra(clusterIdxTrainSet(binIndicesTrain),:);
    trainSetICI{iD} = clusterICI(clusterIdxTrainSet(binIndicesTrain),:);
    trainSetLabels{iD} = ones(size(trainSetMSP{iD},1),1)*iD;

    % pull out testing data
    boutSizeTest = boutSize(testBoutIdx);
    boutStartIdxTest = boutStartIdx(testBoutIdx);
    boutEndIdxTest = boutEndIdx(testBoutIdx);
    
    % randomly select desired number of events across bouts
    nBinsTest = sum(boutSizeTest);
    binIndicesTest = sort(randi(nBinsTest,1,nExamples));
    clusterIdxTestSet = vertcat(boutMembership{testBoutIdx});
    testSetMSP{iD} = clusterSpectra(clusterIdxTestSet(binIndicesTest),:);
    testSetICI{iD} = clusterICI(clusterIdxTestSet(binIndicesTest),:);
    testSetLabels{iD} = ones(size(testSetMSP{iD},1),1)*iD;
    trainSetSize(iD) = nBinsTrain;
end
fprintf('Minimum available unique training set size is %0.0f\n', min(trainSetSize))
fprintf('Maximum available unique training set size is %0.0f\n', max(trainSetSize))

testDataAll = max([vertcat(testSetMSP{:}),vertcat(testSetICI{:})],0);
trainDataAll = [vertcat(trainSetMSP{:}),vertcat(trainSetICI{:})];

trainLabelsAll = vertcat(trainSetLabels{:});
testLabelsAll = vertcat(testSetLabels{:});

savedTrainFile = fullfile(saveDir,saveNameTrain);
savedTestFile = fullfile(saveDir,saveNameTest);
save(fullfile(saveDir,saveNameTest),'testDataAll','testLabelsAll','-v7.3')
save(fullfile(saveDir,saveNameTrain),'trainDataAll','trainLabelsAll','-v7.3')
