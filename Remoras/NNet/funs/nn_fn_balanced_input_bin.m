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
saveNameTimes = [saveName,'_bin_times.mat'];

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
    clusterSpectra = [];
    clusterICI = [];
    clusterTimes = [];
    clusterWave = [];
    for iM = 1:size(matList,1)
        
        inFile = load(fullfile(matList(iM).folder,matList(iM).name));
        for iRow = 1:size(inFile.thisType.Tfinal,1)
            clusterTimes = [clusterTimes;inFile.thisType.Tfinal{iRow,7}];
            %correct for 320 kHz data spectra
            if size(inFile.thisType.Tfinal{iRow,1},2) == 301
                %if some deployments are 320 kHz stuff, was running
                %into issue
                %interpolate between points
                %find least common multiple of desired sample rate and
                %other
                lcb = 301;
                lcs = 181;
                lc = lcm(lcb,lcs);
                specTemp = [];
                for iT = 1:size(inFile.thisType.Tfinal{iRow,1},1)
                    specTemp(iT,:) = interp(inFile.thisType.Tfinal{iRow,1}(iT,:),(lc./lcb));
                end
                %downsample interpolated to 181 pts
                specAdd = downsample(specTemp',(lc/lcs));
                clusterSpectra = [clusterSpectra; specAdd'];
            else
                clusterSpectra = [clusterSpectra;inFile.thisType.Tfinal{iRow,1}];
            end
            clusterICI = [clusterICI;inFile.thisType.Tfinal{iRow,2}];
            if size(inFile.thisType.Tfinal,2)>=10
                if size(inFile.thisType.Tfinal{iRow,10},2) == 320
                    %if some deployments are 320 kHz stuff, was running
                    %into issue
                    %interpolate between points
                    lc2 = lcm(320,200);
                    wavTemp = [];
                    for iT = 1:size(inFile.thisType.Tfinal{iRow,10},1)
                        wavTemp(iT,:) = interp(inFile.thisType.Tfinal{iRow,10}(iT,:),(lc2./320));
                    end
                    %downsample interpolated to 200 pts
                    wavAdd = downsample(wavTemp',(lc2/200));
                    clusterWave = [clusterWave; wavAdd'];
                else
                    clusterWave = [clusterWave;inFile.thisType.Tfinal{iRow,10}];
                end
            end
            
        end
    end
    [clusterTimes,I] = sort(clusterTimes);
    clusterSpectra = clusterSpectra(I,:);
    %     clusterSpectraMin = clusterSpectra-min(clusterSpectra,[],2);
    %     clusterSpectra = clusterSpectraMin./max(clusterSpectraMin,[],2);
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
    
    %get times of selected bouts
    trainSetTimes = clusterTimes(clusterIdxTrainSet(binIndicesTrain));
    
    if REMORA.nn.train_test_set.useSpectra
        [trainSetMSP{iD},trainAugBins] = nn_fn_getSpectra_bin(clusterSpectra,clusterIdxTrainSet,binIndicesTrain);
    else
        trainSetMSP{iD} = [];
        trainAugBins = [];
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
    f1 = figure;
    subplot(3,1,1)
    imagesc(1:size(trainSetMSP{iD},1),1:size(trainSetMSP{iD},2),trainSetMSP{iD}'),set(gca,'ydir','normal')
    title([typeList(iD).name,' train data with ',trainAugBins,' aug bins'])
    subplot(3,1,2)
    imagesc(1:size(trainSetICI{iD},1),linspace(0,0.5,size(trainSetICI{iD},2)),trainSetICI{iD}'),set(gca,'ydir','normal')
    subplot(3,1,3)
    imagesc(1:size(trainSetWave{iD},1),1:size(trainSetWave{iD},2),trainSetWave{iD}'),set(gca,'ydir','normal')
    outplot1 = [saveDir,'\',saveName,'_',typeList(iD).name,'_traindata'];
    print(f1,outplot1,'-djpeg')
    
    trainSetLabels{iD} = ones(size(binIndicesTrain,2),1)*iD;
    
    %% get validation set
    if REMORA.nn.train_test_set.validationTF
        validBoutIdx = sort(randperm(nBouts,max(1,round(nBouts*(validPercent/100)))))';
        fprintf('   %0.0f validation encounters selected\n',length(validBoutIdx))
        
        % pull out validation data
        boutSizeValid = boutSize(validBoutIdx);
        boutStartIdxValid = boutStartIdx(validBoutIdx);
        boutEndIdxValid = boutEndIdx(validBoutIdx);
        
        % randomly select desired number of events across bouts
        nBinsValid  = sum(boutSizeValid);
        binIndicesValid = sort(randi(nBinsValid,1,nExamples));
        
        % binIndicesValid  = sort(randperm(nBinsValid,min(nExamples,nBinsValid )));
        clusterIdxValidSet = vertcat(boutMembership{validBoutIdx});
        
        %get times of selected bouts
        validSetTimes = clusterTimes(clusterIdxValidSet(binIndicesValid));
        
        if REMORA.nn.train_test_set.useSpectra
            [validSetMSP{iD},validAugBins] = nn_fn_getSpectra_bin(clusterSpectra,clusterIdxValidSet,binIndicesValid);
        else
            validSetMSP{iD} = [];
            validAugBins = [];
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
        f2 = figure;
        subplot(3,1,1)
        imagesc(1:size(validSetMSP{iD},1),1:size(validSetMSP{iD},2),validSetMSP{iD}'),set(gca,'ydir','normal')
        title([typeList(iD).name,' validation data with ',validAugBins,' aug bins'])
        subplot(3,1,2)
        imagesc(1:size(validSetICI{iD},1),linspace(0,0.5,size(trainSetICI{iD},2)),validSetICI{iD}'),set(gca,'ydir','normal')
        subplot(3,1,3)
        imagesc(1:size(validSetWave{iD},1),1:size(validSetWave{iD},2),validSetWave{iD}'),set(gca,'ydir','normal')
        outplot2 = [saveDir,'\',saveName,'_',typeList(iD).name,'_validdata_image'];
        print(f2,outplot2,'-djpeg')
        
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
    binIndicesTest = sort(randi(nBinsTest,1,nExamples));
    %binIndicesTest = sort(randperm(nBinsTest,min(nExamples,nBinsTest)));
    clusterIdxTestSet = vertcat(boutMembership{testBoutIdx});
    %get times of selected bouts
    testSetTimes = clusterTimes(clusterIdxTestSet(binIndicesTest));
    testSetMSP{iD} = clusterSpectra(clusterIdxTestSet(binIndicesTest),:);
    testSetICI{iD} = clusterICI(clusterIdxTestSet(binIndicesTest),:);
    if REMORA.nn.train_test_set.useSpectra
        [testSetMSP{iD},testAugBins] = nn_fn_getSpectra_bin(clusterSpectra,clusterIdxTestSet,binIndicesTest);
    else
        testSetMSP{iD} = [];
        testAugBins = [];
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
    f3 = figure;
    subplot(3,1,1)
    imagesc(1:size(testSetMSP{iD},1),1:size(testSetMSP{iD},2),testSetMSP{iD}'),set(gca,'ydir','normal')
    title([typeList(iD).name,' test data with ',testAugBins,' aug bins'])
    subplot(3,1,2)
    imagesc(1:size(testSetICI{iD},1),linspace(0,0.5,size(trainSetICI{iD},2)),testSetICI{iD}'),set(gca,'ydir','normal')
    subplot(3,1,3)
    imagesc(1:size(testSetWave{iD},1),1:size(testSetWave{iD},2),testSetWave{iD}'),set(gca,'ydir','normal')
    outplot = [saveDir,'\',saveName,'_',typeList(iD).name,'_testdata_image'];
    print(f3,outplot,'-djpeg')
    
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
savedTimesFile = fullfile(saveDir,saveNameTimes);
trainTestSetInfo = REMORA.nn.train_test_set;
save(fullfile(saveDir,saveNameTest),'testDataAll','testLabelsAll','typeNames','trainTestSetInfo','-v7.3')
save(fullfile(saveDir,saveNameTrain),'trainDataAll','trainLabelsAll','typeNames','trainTestSetInfo','-v7.3')
save(fullfile(saveDir,saveNameValid),'validDataAll','validLabelsAll','typeNames','trainTestSetInfo','-v7.3')
save(fullfile(saveDir,saveNameTimes),'trainSetTimes','testSetTimes','validSetTimes','trainTestSetInfo','-v7.3')
