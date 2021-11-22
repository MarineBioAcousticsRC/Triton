function [savedTrainFile,savedTestFile,savedValidFile] = nn_fn_balanced_input_bin(inDir,...
    saveDir,saveName,trainPercent,validPercent,nExamples,boutGap)

global REMORA
% inDir = 'E:\Data\John Reports\WAT\WAT_2018_trainingExamples';
typeList = dir(inDir);
badDirs = find(~cellfun(@isempty, strfind({typeList(:).name},'.')));
typeList(badDirs) = [];

saveNameTrain = [saveName ,'_bin_train.mat'];
saveNameTest = [saveName ,'_bin_test.mat'];
saveNameValid = [saveName ,'_bin_validation.mat'];

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
trainSetLabels = [];
testSetLabels = [];
validSetLabels = [];
trainSetSize = [];
validSetMSP = [];
validSetICI = [];
validSetWave = [];

for iD = 1:size(typeList,1)
    fprintf('Beginning type %0.0f, name: %s\n',iD, typeList(iD).name)
    
    thisTypeDir = fullfile(typeList(iD).folder,typeList(iD).name);
    
    [~,typeID] = fileparts(thisTypeDir);
    
    typeNames{iD,1} = typeID;
    matList = dir(fullfile(thisTypeDir,REMORA.nn.train_test_set.binWild));
    if isempty(matList)
         disp('No files found for this type, skipping to next.')
    end 
    matListIdx = ~contains({matList(:).name},'detLevel');
    matList = matList(matListIdx);
    clusterSpectra = [];
    clusterICI = [];
    clusterTimes = [];
    clusterWave = [];
    for iM = 1:size(matList,1)
       
        inFile = load(fullfile(matList(iM).folder,matList(iM).name));
        for iRow = 1:size(inFile.thisType.Tfinal,1)
            clusterTimes = [clusterTimes;inFile.thisType.Tfinal{iRow,7}];
            clusterSpectra = [clusterSpectra;inFile.thisType.Tfinal{iRow,1}];
            try 
                clusterICI = [clusterICI;inFile.thisType.Tfinal{iRow,2}];
            catch
                nRows = size(inFile.thisType.Tfinal{iRow,2},1);
                nCols = size(clusterICI,2)- size(inFile.thisType.Tfinal{iRow,2},2);
                clusterICI = [clusterICI;[inFile.thisType.Tfinal{iRow,2},zeros(nRows,nCols)]];
            end
            if size(inFile.thisType.Tfinal,2)>=10
                clusterWave = [clusterWave;inFile.thisType.Tfinal{iRow,10}];
            end
            
        end
    end
    [clusterTimes,I] = sort(clusterTimes);
    clusterSpectra = clusterSpectra(I,:);
    
    % make sure spectra is normalized between 0 and 1
    if min(min(clusterSpectra)) > 0.5
        clusterSpectraMin = clusterSpectra-min(clusterSpectra,[],2);
        clusterSpectra = clusterSpectraMin./max(clusterSpectraMin,[],2);
    end
    clusterICI = clusterICI(I,:);
    if ~isempty(clusterWave)
        clusterWave = clusterWave(I,:);
    end
    % find bouts
    [boutSize,boutStartIdx,boutStartTime,boutEndIdx,...
        boutEndTime,boutMembership] = nn_fn_findBouts(clusterTimes,minGapTimeDnum);
    nBouts = length(boutSize);
    fprintf('   %0.0f encounters found\n',nBouts)

    %% Get training set
    trainBoutIdx = sort(randperm(nBouts,round(nBouts*(trainPercent/100))))';
    fprintf('   %0.0f train encounters selected\n',length(trainBoutIdx))
    
    % pull out training data
    boutSizeTrain = boutSize(trainBoutIdx);
    boutStartIdxTrain = boutStartIdx(trainBoutIdx);
    boutEndIdxTrain = boutEndIdx(trainBoutIdx);
    
    % randomly select desired number of events across bouts
    nBinsTrain = sum(boutSizeTrain);
    binIndicesTrain = sort(randi(nBinsTrain,1,nExamples));
    
    
    %binIndicesTrain = sort(randperm(nBinsTrain,min(nExamples,nBinsTrain)));
    clusterIdxTrainSet = vertcat(boutMembership{trainBoutIdx});
    if REMORA.nn.train_test_set.useSpectra
        trainSetMSP{iD} = nn_fn_getSpectra_bin(clusterSpectra,clusterIdxTrainSet,binIndicesTrain);
    else
        trainSetMSP{iD} = [];
    end
    
    if REMORA.nn.train_test_set.useICI
        trainSetICI{iD}  = nn_fn_getICI_bin(clusterICI,clusterIdxTrainSet,binIndicesTrain);
    else
        trainSetICI{iD} = [];
    end
    
    if REMORA.nn.train_test_set.useWave && ~isempty(clusterWave)
        trainSetWave{iD} = nn_fn_getwave_bin(clusterWave,clusterIdxTrainSet,binIndicesTrain);
    else
        trainSetWave{iD} = [];
        if REMORA.nn.train_test_set.useWave && isempty(clusterWave)
            warning('No waveform data available.')
        end
    end
    trainSetLabels{iD} = ones(size(binIndicesTrain,2),1)*iD;
    
    %% get validation set
    if REMORA.nn.train_test_set.validationTF 
        if (nBouts-length(trainBoutIdx))<2
            validBoutIdx = sort(randperm(nBouts,max(1,round(nBouts*(validPercent/100)))))';        
        else
            boutsLeft = setdiff(1:nBouts,trainBoutIdx);
            boutsLeft = boutsLeft(randperm(length(boutsLeft)));% shuffle it
            validBoutIdx = boutsLeft(1:max(1,floor(nBouts*(validPercent/100))))';
        end
        fprintf('   %0.0f validation encounters selected\n',length(validBoutIdx))
        
        % pull out validation data
        boutSizeValid = boutSize(validBoutIdx);
        boutStartIdxValid = boutStartIdx(validBoutIdx);
        boutEndIdxValid = boutEndIdx(validBoutIdx);
        
        % randomly select desired number of events across bouts
        nBinsValid  = sum(boutSizeValid);
        nValidExamples = round(nExamples*(round(100*(validPercent/trainPercent))/100));
        binIndicesValid = sort(randi(nBinsValid,1,nValidExamples));
        
        % binIndicesValid  = sort(randperm(nBinsValid,min(nExamples,nBinsValid )));
        clusterIdxValidSet = vertcat(boutMembership{validBoutIdx});
        if REMORA.nn.train_test_set.useSpectra
            validSetMSP{iD} = nn_fn_getSpectra_bin(clusterSpectra,clusterIdxValidSet,binIndicesValid);
        else
            validSetMSP{iD} = [];
        end
        
        if REMORA.nn.train_test_set.useICI
            validSetICI{iD}  = nn_fn_getICI_bin(clusterICI,clusterIdxValidSet,binIndicesValid);
        else
            validSetICI{iD} = [];
        end
        
        if REMORA.nn.train_test_set.useWave && ~isempty(clusterWave)
            validSetWave{iD} = nn_fn_getwave_bin(clusterWave,clusterIdxValidSet,binIndicesValid);
        else
            validSetWave{iD} = [];
            if REMORA.nn.train_test_set.useWave && isempty(clusterWave)
                warning('No waveform data available.')
            end
        end
        validSetLabels{iD} = ones(size(binIndicesValid,2),1)*iD;
    end
    %% pull out testing data
    [~,testBoutIdx] = setdiff(1:nBouts,[trainBoutIdx;validBoutIdx]);
    fprintf('   %0.0f test encounters selected\n',length(testBoutIdx))
    
    boutSizeTest = boutSize(testBoutIdx);
    if isempty(boutSizeTest)
        disp(sprintf('WARNING: No ''%s'' events available for test set',typeList(iD).name))
        continue
    end
    boutStartIdxTest = boutStartIdx(testBoutIdx);
    boutEndIdxTest = boutEndIdx(testBoutIdx);
    
    % randomly select desired number of events across bouts
    nBinsTest = sum(boutSizeTest);
    nTestExamples = nExamples*round(100*(100-validPercent-trainPercent)/trainPercent)/100;

    binIndicesTest = sort(randi(nBinsTest,1,nTestExamples));
    %binIndicesTest = sort(randperm(nBinsTest,min(nExamples,nBinsTest)));
    clusterIdxTestSet = vertcat(boutMembership{testBoutIdx});
    testSetMSP{iD} = clusterSpectra(clusterIdxTestSet(binIndicesTest),:);
    testSetICI{iD} = clusterICI(clusterIdxTestSet(binIndicesTest),:);
    if REMORA.nn.train_test_set.useSpectra
        testSetMSP{iD} = nn_fn_getSpectra_bin(clusterSpectra,clusterIdxTestSet,binIndicesTest);
    else
        testSetMSP{iD} = [];
    end
    if REMORA.nn.train_test_set.useICI
        testSetICI{iD} = nn_fn_getICI_bin(clusterICI,clusterIdxTestSet,binIndicesTest);
    else
        testSetICI{iD} = [];
    end
    if REMORA.nn.train_test_set.useWave && ~isempty(clusterWave)
        testSetWave{iD} = nn_fn_getwave_bin(clusterWave,clusterIdxTestSet,binIndicesTest);
    else
        testSetWave{iD} = [];
    end
    testSetLabels{iD} = ones(size(binIndicesTest,2),1)*iD;
    trainSetSize(iD) = nBinsTrain;
end
fprintf('Minimum available unique training set size is %0.0f\n', min(trainSetSize))
fprintf('Maximum available unique training set size is %0.0f\n', max(trainSetSize))

trainDataAll = max([vertcat(trainSetMSP{:}),vertcat(trainSetICI{:}),vertcat(trainSetWave{:})],0);
testDataAll = max([vertcat(testSetMSP{:}),vertcat(testSetICI{:}),vertcat(testSetWave{:})],0);
validDataAll= max([vertcat(validSetMSP{:}),vertcat(validSetICI{:}),vertcat(validSetWave{:})],0);

trainLabelsAll = vertcat(trainSetLabels{:});
testLabelsAll = vertcat(testSetLabels{:});
validLabelsAll = vertcat(validSetLabels{:});

savedTrainFile = fullfile(saveDir,saveNameTrain);
savedTestFile = fullfile(saveDir,saveNameTest);
savedValidFile = fullfile(saveDir,saveNameValid);
trainTestSetInfo = REMORA.nn.train_test_set;
save(fullfile(saveDir,saveNameTest),'testDataAll','testLabelsAll','typeNames','trainTestSetInfo','-v7.3')
save(fullfile(saveDir,saveNameTrain),'trainDataAll','trainLabelsAll','typeNames','trainTestSetInfo','-v7.3')
save(fullfile(saveDir,saveNameValid),'validDataAll','validLabelsAll','typeNames','trainTestSetInfo','-v7.3')
