function [savedTrainFullfile,savedTestFullfile] = nn_fn_balanced_input(inDir,saveDir,saveName,...
    trainPercent,validPercent,nExamples,boutGap)

% Make a train set
global REMORA
nAll.nExamples = nExamples;
nAll.inDir = inDir;
nAll.validPercent = validPercent;
nAll.trainPercent = trainPercent;
nAll.boutGap = boutGap;
nAll.normData = 1;
nAll.myPerc = 98;
if ~nAll.normData
    disp('No pruning because data are not normalized.\n')
    nAll.myPerc = 0;
else
    fprintf('Pruning at %0.2f\n',nAll.myPerc)
end
nExamplesPad = ceil(nAll.nExamples/(nAll.myPerc/100));

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
normData = 1;

validSpecAll = [];
validTSAll = [];
validLabelsAll = [];
validAmpAll = [];

minGapTimeHour = boutGap/60;
minGapTimeDnum = minGapTimeHour/24;    % gap time in datenum
for iT = 1:nTypes
    %wBar = waitbar(0,sprintf('Processing type %0.0f',subDirList(iT).name));
    fprintf('Beginning type %0.0f, name: %s\n',iT, subDirList(iT).name)
    folderPath = fullfile(subDirList(iT).folder,subDirList(iT).name);
    n(iT).fList = dir(fullfile(folderPath,'*detLevel.mat'));
    if isempty(n(iT).fList)
        disp('No files found for this type, skipping to next.')
        continue
    end
    timesCat = []; n(iT).fListIdx = []; indexCat = [];
    
    % iterate over "training set" files, and load times so we can determine
    % bout start/ends.
    n(iT).boutSizeAll = {};
    n(iT).boutStartIdxAll = {};
    n(iT).boutStartTimeAll = {};
    n(iT).boutEndIdxAll = {};
    n(iT).boutEndTimeAll = {};
    n(iT).fListIdx = {};
    n(iT).nBouts = [];
    fprintf('%0.0f files found\n',length(n(iT).fList))
    for iFile = 1:length(n(iT).fList)
        load(fullfile(n(iT).fList(iFile).folder, n(iT).fList(iFile).name),'trainTimes')
        [boutSize,boutStartIdx,boutStartTime,boutEndIdx,boutEndTime,~] =...
            nn_fn_findBouts(trainTimes,minGapTimeDnum);
        n(iT).boutSizeAll{iFile} = boutSize;
        n(iT).boutStartIdxAll{iFile} = boutStartIdx;
        n(iT).boutStartTimeAll{iFile} = boutStartTime;
        n(iT).boutEndIdxAll{iFile} = boutEndIdx;
        n(iT).boutEndTimeAll{iFile} = boutEndTime;
        n(iT).fListIdx{iFile} = iFile*ones(size(boutSize));
        n(iT).nBouts(iFile,1) = length(boutSize);
    end
    % TODO: handle case where there is only one bout! (hint: probably
    % should be warning that there's not enough to train on).
    fprintf('   %0.0f encounters found\n',sum(n(iT).nBouts))
    
    % waitbar(.05,wBar, sprintf('Processing type %0.0f : Training Set',subDirList(iT).name));

    % pick training bouts
    n(iT).nBoutsTotal = sum(n(iT).nBouts);
    n(iT).trainBoutIdx = sort(randperm(n(iT).nBoutsTotal,round(n(iT).nBoutsTotal*(nAll.trainPercent/100))));
    boutsLeft = setdiff(1:n(iT).nBoutsTotal,n(iT).trainBoutIdx);
    boutsLeft = boutsLeft(randperm(length(boutsLeft)));% shuffle it
    n(iT).validBoutIdx = boutsLeft(1:max(1,floor(n(iT).nBoutsTotal*(nAll.validPercent/100))));
    if n(iT).nBoutsTotal<=3
        disp('Too few bouts of this type to have independent validation set')
        n(iT).validBoutIdx = sort(n(iT).trainBoutIdx(randperm(length(n(iT).trainBoutIdx),...
            ceil(n(iT).nBoutsTotal*(nAll.validPercent/100)))));

    end
    [~,n(iT).testBoutIdx] = setdiff(boutsLeft,n(iT).validBoutIdx);
    
    fprintf('   %0.0f train encounters selected\n',length(n(iT).trainBoutIdx))
    fprintf('   %0.0f test encounters selected\n',length(n(iT).testBoutIdx))
    
    % vertcat start and ends for easier indexing
    boutSizeAllVec = vertcat(n(iT).boutSizeAll{:});
    boutStartIdxAllVec = vertcat(n(iT).boutStartIdxAll{:});
    boutEndIdxAllVec = vertcat(n(iT).boutEndIdxAll{:});
    fListIdxVec = vertcat(n(iT).fListIdx{:});
    
    
    %% TRAIN
    n(iT).boutSizeAllTrain = boutSizeAllVec(n(iT).trainBoutIdx);
    n(iT).boutStartIdxAllTrain = boutStartIdxAllVec(n(iT).trainBoutIdx);
    n(iT).boutEndIdxAllTrain = boutEndIdxAllVec(n(iT).trainBoutIdx);
    n(iT).fListIdxTrain = fListIdxVec(n(iT).trainBoutIdx);
    
    % randomly select desired number of events across bouts
    n(iT).nClicksTrain = sum(n(iT).boutSizeAllTrain);
    n(iT).clickIndicesTrain = sort(randi(n(iT).nClicksTrain,1,nExamplesPad));
    [~,edges,bin] = histcounts(n(iT).clickIndicesTrain,[1;cumsum(n(iT).boutSizeAllTrain)+1]);
    
    [trainSetSN,trainSetSP,trainSetAmp] = nn_fn_extract_examples(folderPath,n(iT).fList,...
        nExamplesPad,n(iT).fListIdxTrain,n(iT).boutStartIdxAllTrain,...
        n(iT).boutEndIdxAllTrain,n(iT).clickIndicesTrain,edges,bin);
    
    fprintf('\n')
    
    
    % prune 1% noisiest examples relative to mean
    myDistsTrain= pdist2(trainSetSP,mean(trainSetSP,1),'correlation');
    n(iT).keepersTrain = find(myDistsTrain<=prctile(myDistsTrain,nAll.myPerc));
    if nAll.normData
        trainSetSP = nn_fn_normalize_spectrum(trainSetSP);
        trainSetSN = nn_fn_normalize_timeseries(trainSetSN);
    end
    trainTSAll = [trainTSAll;trainSetSN(n(iT).keepersTrain(1:nExamples),:)];
    trainSpecAll = [trainSpecAll;trainSetSP(n(iT).keepersTrain(1:nExamples),:)];
    trainAmpAll = [trainAmpAll;trainSetAmp(n(iT).keepersTrain(1:nExamples),:)];     
    
    trainLabelsAll = [trainLabelsAll;repmat(iT,size(trainSetSN(n(iT).keepersTrain(1:nExamples),:),1),1)];
    
    fprintf('  %0.0f Training examples gathered\n',length(trainLabelsAll))
    
    %% Validation
    if ~isempty(n(iT).validBoutIdx)
        n(iT).boutSizeAllValid = boutSizeAllVec(n(iT).validBoutIdx);
        n(iT).boutStartIdxAllValid = boutStartIdxAllVec(n(iT).validBoutIdx);
        n(iT).boutEndIdxAllValid = boutEndIdxAllVec(n(iT).validBoutIdx);
        n(iT).fListIdxValid = fListIdxVec(n(iT).validBoutIdx);
        
        % randomly select desired number of events across bouts
        n(iT).nClicksValid = sum(n(iT).boutSizeAllValid);
        
        nAll.nExamplesValid  = round(nExamplesPad*(nAll.validPercent/nAll.trainPercent));
        n(iT).clickIndicesValid = sort(randi(n(iT).nClicksValid,1,nAll.nExamplesValid));
        [~,edges,bin] = histcounts(n(iT).clickIndicesValid,[1;cumsum(n(iT).boutSizeAllValid)+1]);
        
        [validSetSN,validSetSP,validSetAmp] = nn_fn_extract_examples(folderPath,...
            n(iT).fList,nAll.nExamplesValid,n(iT).fListIdxValid,n(iT).boutStartIdxAllValid,...
            n(iT).boutEndIdxAllValid,n(iT).clickIndicesValid,edges,bin);
        
        fprintf('\n')
        
        % prune 1% noisiest examples relative to mean
        nAll.nValid = nExamples*(nAll.validPercent/nAll.trainPercent);
        myDistsValid= pdist2(validSetSP,mean(validSetSP,1),'correlation');
        n(iT).keepersValid = find(myDistsValid<=prctile(myDistsValid,nAll.myPerc));
        
        if nAll.normData
            validSetSP = nn_fn_normalize_spectrum(validSetSP);
            validSetSN = nn_fn_normalize_timeseries(validSetSN);
        end
        validTSAll = [validTSAll;validSetSN(n(iT).keepersValid(1:nAll.nValid),:)];
        validSpecAll = [validSpecAll;validSetSP(n(iT).keepersValid(1:nAll.nValid),:)];
        validAmpAll = [validAmpAll;validSetAmp(n(iT).keepersValid(1:nAll.nValid),:)];
        
        validLabelsAll = [validLabelsAll;repmat(iT,size(validSetSN(n(iT).keepersValid(1:nAll.nValid),:),1),1)];
        
        fprintf('  %0.0f Validation examples gathered\n',length(validLabelsAll))
    else
        disp(sprintf('WARNING: No Validation examples for %s\n',typeNames{iT}))
    end
    %% TEST
    n(iT).boutSizeAllTest = boutSizeAllVec(n(iT).testBoutIdx);
    n(iT).boutStartIdxAllTest = boutStartIdxAllVec(n(iT).testBoutIdx);
    n(iT).boutEndIdxAllTest = boutEndIdxAllVec(n(iT).testBoutIdx);
    n(iT).fListIdxTest = fListIdxVec(n(iT).testBoutIdx);
    
    n(iT).nClicksTest = sum(n(iT).boutSizeAllTest);
    
    if n(iT).nClicksTest == 0
        disp(sprintf('WARNING: No ''%s'' events available for test set',typeNames{iT}))
        continue
    end
    % randomly select desired number of events across bouts
    nAll.testPercent = (100-nAll.validPercent-nAll.trainPercent);
    nAll.nExamplesTest = round(nExamplesPad*(nAll.testPercent./nAll.trainPercent));
    n(iT).clickIndicesTest = sort(randi(n(iT).nClicksTest,1,nAll.nExamplesTest));
    [N,edges,bin] = histcounts(n(iT).clickIndicesTest,[1;cumsum(n(iT).boutSizeAllTest)+1]);
    
    [testSetSN,testSetSP,testSetAmp] = nn_fn_extract_examples(folderPath,n(iT).fList,...
        nAll.nExamplesTest,n(iT).fListIdxTest,n(iT).boutStartIdxAllTest,...
        n(iT).boutEndIdxAllTest,n(iT).clickIndicesTest,edges,bin);
    
    nAll.nTest = nExamples*(nAll.testPercent/nAll.trainPercent);
    myDistsTest= pdist2(testSetSP,mean(testSetSP,1),'correlation');
    n(iT).keepersTest = find(myDistsTest<=prctile(myDistsTest,nAll.myPerc));
    
    if nAll.normData
        testSetSP = nn_fn_normalize_spectrum(testSetSP);
        testSetSN = nn_fn_normalize_timeseries(testSetSN);
    end
    testTSAll = [testTSAll;testSetSN(n(iT).keepersTest(1:nAll.nTest),:)];
    testSpecAll = [testSpecAll;testSetSP(n(iT).keepersTest(1:nAll.nTest),:)];
    testAmpAll = [testAmpAll;testSetAmp(n(iT).keepersTest(1:nAll.nTest),:)];
    
    testLabelsAll = [testLabelsAll;repmat(iT,size(testSetSN(n(iT).keepersTest(1:nAll.nTest),1)),1)];
    
    fprintf('  %0.0f Testing examples gathered\n',length(testLabelsAll))
    fprintf('Done with type %0.0f of %0.0f\n',iT,nTypes)
    
end

trainTestSetInfo = REMORA.nn.train_test_set;
% Save training set
trainDataAll = [trainSpecAll,trainTSAll];%trainAmpAll
nAll.specSize = size(trainSpecAll,2);
nAll.tsSize = size(trainTSAll,2);
savedTrainFullfile = fullfile(saveDir,saveNameTrain);
save(savedTrainFullfile,'trainDataAll','trainLabelsAll','typeNames','trainTestSetInfo','nAll','-v7.3')

% Save validation set
validDataAll = [validSpecAll,validTSAll];%validAmpAll

savedValidFullfile = fullfile(saveDir,saveNameValid);
save(savedValidFullfile,'validDataAll','validLabelsAll','typeNames','trainTestSetInfo','nAll','-v7.3')

% Save test set
testDataAll = [testSpecAll,testTSAll];

savedTestFullfile = fullfile(saveDir,saveNameTest);
save(savedTestFullfile,'testDataAll','testLabelsAll','typeNames',...
    'trainTestSetInfo','nAll','n','-v7.3')

% to compare:
% confusionmat(double(testOut),y_test)

