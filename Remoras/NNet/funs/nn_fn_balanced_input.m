function [savedTrainFullfile,savedTestFullfile] = nn_fn_balanced_input(inDir,saveDir,saveName,...
    trainPercent,validPercent,nExamples,boutGap)

% Make a train set
global REMORA 

saveNameTrain = [saveName ,'_det_train.mat'];
saveNameValid = [saveName ,'_det_validation.mat'];
saveNameTest = [saveName ,'_det_test.mat'];
if ~exist(saveDir,'dir')
    mkdir(saveDir)
end
subDirList = dir(inDir);
badDirs = find(~cellfun(@isempty, strfind({subDirList(:).name},'.')));
subDirList(badDirs) = [];
nTypes = size(subDirList,1);
typeNames = {subDirList(:).name}';
typeIdNum = 1:nTypes;
trainSpecAll = [];
trainTSAll = [];
trainLabelsAll = [];
trainTimesAll = [];
trainAmpAll = [];

testSpecAll = [];
testTSAll = [];
testLabelsAll = [];
testTimesAll = [];
testAmpAll = [];


validSpecAll = [];
validTSAll = [];
validLabelsAll = [];

minGapTimeHour = boutGap/60;
minGapTimeDnum = minGapTimeHour/24;    % gap time in datenum

for iT = 1:nTypes
    fprintf('Beginning type %0.0f, name: %s\n',iT, subDirList(iT).name)
    folderPath = fullfile(subDirList(iT).folder,subDirList(iT).name);
    fList = dir(fullfile(folderPath,'*detLevel.mat'));
    if isempty(fList)
         disp('No files found for this type, skipping to next.')
         continue
    end 
    timesCat = []; fListIdx = []; indexCat = [];
    
    % iterate over "training set" files, and load times so we can determine
    % bout start/ends.
    boutSizeAll = {};
    boutStartIdxAll = {};
    boutStartTimeAll = {};
    boutEndIdxAll = {};
    boutEndTimeAll = {};
    fListIdx = {};
    nBouts = [];
    fprintf('%0.0f files found\n',length(fList))
    for iFile = 1:length(fList)
        load(fullfile(fList(iFile).folder, fList(iFile).name),'trainTimes')
        [boutSize,boutStartIdx,boutStartTime,boutEndIdx,boutEndTime,~] =...
            nn_fn_findBouts(trainTimes,minGapTimeDnum);
        boutSizeAll{iFile} = boutSize;
        boutStartIdxAll{iFile} = boutStartIdx;
        boutStartTimeAll{iFile} = boutStartTime;
        boutEndIdxAll{iFile} = boutEndIdx;
        boutEndTimeAll{iFile} = boutEndTime;
        fListIdx{iFile} = iFile*ones(size(boutSize));
        nBouts(iFile,1) = length(boutSize);
    end
    % TODO: handle case where there is only one bout! (hint: probably
    % should be warning that there's not enough to train on).
    fprintf('   %0.0f encounters found\n',sum(nBouts))

    
    % pick training bouts
    nBoutsTotal = sum(nBouts);
    trainBoutIdx = sort(randperm(nBoutsTotal,round(nBoutsTotal*(trainPercent/100))));
    boutsLeft = setdiff(1:nBoutsTotal,trainBoutIdx);
    boutsLeft = boutsLeft(randperm(length(boutsLeft)));% shuffle it
    validBoutIdx = boutsLeft(1:max(1,floor(nBoutsTotal*(validPercent/100))));
    if nBoutsTotal<=3
        disp('Too few bouts of this type to include in validation set')
        validBoutIdx = [];
    end
    [~,testBoutIdx] = setdiff(boutsLeft,validBoutIdx);
    
    fprintf('   %0.0f train encounters selected\n',length(trainBoutIdx))
    fprintf('   %0.0f test encounters selected\n',length(testBoutIdx))
    
    % vertcat start and ends for easier indexing
    boutSizeAllVec = vertcat(boutSizeAll{:});
    boutStartIdxAllVec = vertcat(boutStartIdxAll{:});
    boutEndIdxAllVec = vertcat(boutEndIdxAll{:});
    fListIdxVec = vertcat(fListIdx{:});
    
    
    %% TRAIN
    boutSizeAllTrain = boutSizeAllVec(trainBoutIdx);
    boutStartIdxAllTrain = boutStartIdxAllVec(trainBoutIdx);
    boutEndIdxAllTrain = boutEndIdxAllVec(trainBoutIdx);
    fListIdxTrain = fListIdxVec(trainBoutIdx);
    
    % randomly select desired number of events across bouts
    nClicksTrain = sum(boutSizeAllTrain);
    clickIndicesTrain = sort(randi(nClicksTrain,1,nExamples));
    [~,edges,bin] = histcounts(clickIndicesTrain,[1;cumsum(boutSizeAllTrain)+1]);

    [trainSetSN,trainSetSP,trainSetAmp] = nn_fn_extract_examples(folderPath,fList,...
        nExamples,fListIdxTrain,boutStartIdxAllTrain,boutEndIdxAllTrain,clickIndicesTrain,edges,bin);

    fprintf('\n')
    trainTSAll = [trainTSAll;trainSetSN];
    trainSpecAll = [trainSpecAll;trainSetSP];
    %trainAmpAll = [trainAmpAll;trainSetAmp];
                 
    trainLabelsAll = [trainLabelsAll;repmat(iT,size(trainSetSN,1),1)];
    
    fprintf('  %0.0f Training examples gathered\n',length(trainLabelsAll))

    %% Validation
    boutSizeAllValid = boutSizeAllVec(validBoutIdx);
    boutStartIdxAllValid = boutStartIdxAllVec(validBoutIdx);
    boutEndIdxAllValid = boutEndIdxAllVec(validBoutIdx);
    fListIdxValid = fListIdxVec(validBoutIdx);
    
    % randomly select desired number of events across bouts
    nClicksValid = sum(boutSizeAllValid);
    
    nExamplesValid  = round(nExamples*(validPercent/100));
    clickIndicesValid = sort(randi(nClicksValid,1,nExamplesValid));
    [~,edges,bin] = histcounts(clickIndicesValid,[1;cumsum(boutSizeAllValid)+1]);

    [validSetSN,validSetSP,validSetAmp] = nn_fn_extract_examples(folderPath,...
        fList,nExamplesValid,fListIdxValid,boutStartIdxAllValid,boutEndIdxAllValid,clickIndicesValid,edges,bin);

    fprintf('\n')
    validTSAll = [validTSAll;validSetSN];
    validSpecAll = [validSpecAll;validSetSP];
    %validAmpAll = [validAmpAll;validSetAmp];
                 
    validLabelsAll = [validLabelsAll;repmat(iT,size(validSetSN,1),1)];
    
    fprintf('  %0.0f Validation examples gathered\n',length(validLabelsAll))
    
    %% TEST
    boutSizeAllTest = boutSizeAllVec(testBoutIdx);
    boutStartIdxAllTest = boutStartIdxAllVec(testBoutIdx);
    boutEndIdxAllTest = boutEndIdxAllVec(testBoutIdx);
    fListIdxTest = fListIdxVec(testBoutIdx);
    
    nClicksTest = sum(boutSizeAllTest);
  
    if nClicksTest == 0 
        disp(sprintf('WARNING: No ''%s'' events available for test set',typeNames{iT}))
        continue
    end
    % randomly select desired number of events across bouts
    nExamplesTest = round(nExamples*(1-(validPercent+trainPercent)/100));
    clickIndicesTest = sort(randi(nClicksTest,1,nExamplesTest));
    [N,edges,bin] = histcounts(clickIndicesTest,[1;cumsum(boutSizeAllTest)+1]);

    [testSetSN,testSetSP,testSetAmp] = nn_fn_extract_examples(folderPath,fList,...
        nExamplesTest,fListIdxTest,boutStartIdxAllTest,boutEndIdxAllTest,clickIndicesTest,edges,bin);
 
    testTSAll = [testTSAll;testSetSN];
    testSpecAll = [testSpecAll;testSetSP];
    %testAmpAll = [testAmpAll;testSetAmp];
    testLabelsAll = [testLabelsAll;repmat(iT,size(testSetSN,1),1)];
    
    fprintf('  %0.0f Testing examples gathered\n',length(testLabelsAll))    
    fprintf('Done with type %0.0f of %0.0f\n',iT,nTypes)

end
trainTestSetInfo = REMORA.nn.train_test_set;
normData = 0;
% Save training set
if normData
    normSpecTrain = nn_fn_normalize_spectrum(trainSpecAll);
    normTSTrain = nn_fn_normalize_timeseries(trainTSAll);
	trainDataAll = [normSpecTrain,normTSTrain];%trainAmpAll
else
    trainDataAll = [trainSpecAll,trainTSAll];%trainAmpAll
end

savedTrainFullfile = fullfile(saveDir,saveNameTrain);
save(savedTrainFullfile,'trainDataAll','trainLabelsAll','typeNames','trainTestSetInfo','-v7.3')

% Save validation set
if normData
    normSpecValid = nn_fn_normalize_spectrum(validSpecAll);
    normTSValid = nn_fn_normalize_timeseries(validTSAll);
    validDataAll = [normSpecValid,normTSValid];%validAmpAll
else
    validDataAll = [validSpecAll,validTSAll];%validAmpAll
end
savedValidFullfile = fullfile(saveDir,saveNameValid);
save(savedValidFullfile,'validDataAll','validLabelsAll','typeNames','trainTestSetInfo','-v7.3')

% Save test set
if normData
    normSpecTest = nn_fn_normalize_spectrum(testSpecAll);
    normTSTest = nn_fn_normalize_timeseries(testTSAll);
    testDataAll = [normSpecTest,normTSTest];%testAmpAll
else
    testDataAll = [testSpecAll,testTSAll];
end
savedTestFullfile = fullfile(saveDir,saveNameTest);
save(savedTestFullfile,'testDataAll','testLabelsAll','typeNames','trainTestSetInfo','-v7.3')

% to compare:
% confusionmat(double(testOut),y_test)

