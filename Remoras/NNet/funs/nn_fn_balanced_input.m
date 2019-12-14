function [savedTrainFullfile,savedTestFullfile] = nn_fn_balanced_input(inDir,saveDir,saveName,...
    trainPercent,nExamples,boutGap)

% Make a train set

saveNameTrain = [saveName ,'_det_train.mat'];
saveNameTest = [saveName ,'_det_test.mat'];
if ~exist(saveDir,'dir')
    mkdir(saveDir)
end
subDirList = dir(inDir);
badDirs = find(~cellfun(@isempty, strfind({subDirList(:).name},'.')));
subDirList(badDirs) = [];
nTypes = size(subDirList,1);
typeList = {subDirList(:).name}';
typeIdNum = 1:nTypes;
trainSpecAll = [];
trainTSAll = [];
trainLabelsAll = [];
trainTimesAll = [];

testSpecAll = [];
testTSAll = [];
testLabelsAll = [];
testTimesAll = [];
minGapTimeHour = boutGap/60;
minGapTimeDnum = minGapTimeHour/24;    % gap time in datenum

for iT = 1:nTypes
    fprintf('Beginning type %0.0f, name: %s\n',iT, subDirList(iT).name)
    fList = dir(fullfile(inDir,subDirList(iT).name,'*detLevel.mat'));
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
    trainBoutIdx = sort(randperm(sum(nBouts),round(sum(nBouts)*(trainPercent/100))));
    [~,testBoutIdx] = setdiff(1:sum(nBouts),trainBoutIdx);
    
    fprintf('   %0.0f train encounters selected\n',length(trainBoutIdx))
    fprintf('   %0.0f test encounters selected\n',length(testBoutIdx))
    
    % vertcat start and ends for easier indexing
    boutSizeAllVec = vertcat(boutSizeAll{:});
    boutStartIdxAllVec = vertcat(boutStartIdxAll{:});
    boutEndIdxAllVec = vertcat(boutEndIdxAll{:});
    fListIdxVec = vertcat(fListIdx{:});
    
    
    %% TRAIN
    boutSizeAllTrain = boutSizeAllVec(trainBoutIdx);
    boutStartIdxAllAllTrain = boutStartIdxAllVec(trainBoutIdx);
    boutEndIdxAllAllTrain = boutEndIdxAllVec(trainBoutIdx);
    fListIdxTrain = fListIdxVec(trainBoutIdx);
    
    % randomly select desired number of events across bouts
    nClicksTrain = sum(boutSizeAllTrain);
    clickIndicesTrain = sort(randperm(nClicksTrain,min(nExamples,nClicksTrain)));
    [~,edges,bin] = histcounts(clickIndicesTrain,[1;cumsum(boutSizeAllTrain)+1]);
    
    trainSetSN = [];
    trainSetSP = [];
    sIdx = 1;
    for iBout = 1:length(trainBoutIdx)
        
        thisFileIdx = fListIdxTrain(iBout);
        thisTypeFile = fullfile(inDir,subDirList(iT).name,fList(thisFileIdx).name);
        % do partial load of just clicks in bout
        fileObj = matfile(thisTypeFile);
        
        boutIdxRange = boutStartIdxAllAllTrain(iBout):boutEndIdxAllAllTrain(iBout);
        thisBout.MSN = fileObj.trainMSN(boutIdxRange,:);
        thisBout.MSP = fileObj.trainMSP(boutIdxRange,:);
        if isempty(trainSetSN)
            % pre-allocate now that we know the horizontal dimensions if
            % this is the first pass.
            trainSetSN = zeros(nExamples,size(thisBout.MSN,2));
            trainSetSP = zeros(nExamples,size(thisBout.MSP,2));
        end
        % Figure out which of the randomly selected training events are in this bout
        whichEvents = clickIndicesTrain(bin==iBout)-edges(iBout)+1;
        eIdx = sIdx+size(whichEvents,2)-1;
        trainSetSN(sIdx:eIdx,:) = thisBout.MSN(whichEvents,:);
        trainSetSP(sIdx:eIdx,:) = thisBout.MSP(whichEvents,:);
        sIdx = sIdx+size(whichEvents,2);
    end
    
    trainTSAll = [trainTSAll;trainSetSN];
    trainSpecAll = [trainSpecAll;trainSetSP];
    
    trainLabelsAll = [trainLabelsAll;repmat(iT,size(trainSetSN,1),1)];
    
    
    %% TEST
    boutSizeAllTest = boutSizeAllVec(testBoutIdx);
    boutStartIdxAllAllTest = boutStartIdxAllVec(testBoutIdx);
    boutEndIdxAllAllTest = boutEndIdxAllVec(testBoutIdx);
    fListIdxTest = fListIdxVec(testBoutIdx);
    
    % randomly select desired number of events across bouts
    nClicksTest = sum(boutSizeAllTest);
    clickIndicesTest = sort(randperm(nClicksTest,min(nExamples,nClicksTest)));
    [N,edges,bin] = histcounts(clickIndicesTest,[1;cumsum(boutSizeAllTest)+1]);
    
    testSetSN = [];
    testSetSP = [];
    sIdx = 1;
    for iBout = 1:length(testBoutIdx)
        
        thisFileIdx = fListIdxTest(iBout);
        thisTypeFile = fullfile(inDir,subDirList(iT).name,fList(thisFileIdx).name);
        % do partial load of just clicks in bout
        fileObj = matfile(thisTypeFile);
        
        boutIdxRange = boutStartIdxAllAllTest(iBout):boutEndIdxAllAllTest(iBout);
        thisBout.MSN = fileObj.trainMSN(boutIdxRange,:);
        thisBout.MSP = fileObj.trainMSP(boutIdxRange,:);
        if isempty(testSetSN)
            % pre-allocate now that we know the horizontal dimensions if
            % this is the first pass.
            testSetSN = zeros(nExamples,size(thisBout.MSN,2));
            testSetSP = zeros(nExamples,size(thisBout.MSP,2));
        end
        % Figure out which of the randomly selected testing events are in this bout
        whichEvents = clickIndicesTest(bin==iBout)-edges(iBout)+1;
        eIdx = sIdx+size(whichEvents,2)-1;
        testSetSN(sIdx:eIdx,:) = thisBout.MSN(whichEvents,:);
        testSetSP(sIdx:eIdx,:) = thisBout.MSP(whichEvents,:);
        sIdx = sIdx+size(whichEvents,2);
    end

    testTSAll = [testTSAll;testSetSN];
    testSpecAll = [testSpecAll;testSetSP];
    
    testLabelsAll = [testLabelsAll;repmat(iT,size(testSetSN,1),1)];
    
    fprintf('  %0.0f Training examples gathered\n',length(trainLabelsAll))
    fprintf('  %0.0f Testing examples gathered\n',length(testLabelsAll))    
    fprintf('Done with type %0.0f of %0.0f\n',iT,nTypes)

end

normSpecTrain = normalize_spectrum(trainSpecAll);
normTSTrain = normalize_timeseries(trainTSAll);
trainDataAll = [normSpecTrain,normTSTrain];
savedTrainFullfile = fullfile(saveDir,saveNameTrain);
save(savedTrainFullfile,'trainDataAll','trainLabelsAll','-v7.3')

normSpecTest = normalize_spectrum(testSpecAll);
normTSTest = normalize_timeseries(testTSAll);
testDataAll = [normSpecTest,normTSTest];
savedTestFullfile = fullfile(saveDir,saveNameTest);
save(savedTestFullfile,'testDataAll','testLabelsAll','-v7.3')

% to compare:
% confusionmat(double(testOut),y_test)

function normTS = normalize_timeseries(TS)
meanTS = TS - mean(TS,2);
% stdTS = std(TS,0,2);
maxTS = mean(max(abs(meanTS),[],2),2);
normTS = meanTS./maxTS;
normTS(isnan(normTS)) = 0;
normTS = normTS/2+0.5;

function normSpec = normalize_spectrum(SP)
% minNormSpec = SP - mean(min(SP,[],2));
minNormSpec = SP - min(SP,[],2);
minNormSpec = max(minNormSpec,0);
normSpec = minNormSpec./(max(minNormSpec,[],2));