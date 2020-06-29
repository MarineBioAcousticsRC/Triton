function nn_fn_classify_bins

global REMORA
disp('Classifying bins from cluster bins output files')
% load network
trainedNet = load(REMORA.nn.classify.networkPath);
fprintf('Loaded network %s\n', REMORA.nn.classify.networkPath)

% identify files.
fWild = [REMORA.nn.classify.wildcard,'*.mat'];
if REMORA.nn.classify.searchSubDirsTF
    fList = rdir(REMORA.nn.classify.inDir,fWild);
else
    fList = dir(fullfile(REMORA.nn.classify.inDir,fWild));
end
nFiles = size(fList,1);
fprintf('%0.0f files found\n',nFiles)

if ~exist('trainTestSetInfo','var')
    warning('No variable called ''trainTestSetInfo''')
    disp('Assume spectra, ici and waveform should be used.')
    trainTestSetInfo.useSpectra = 1;
    trainTestSetInfo.useICI = 1;
    trainTestSetInfo.useWave = 1;
end

if ~exist('netTrainingInfo','var')
    warning('WARNING: No variable called ''netTrainingInfo''')
    netTrainingInfo = [];
end

if ~exist('typeNames','var')
    warning('WARNING: No variable called ''typeNames''')
    typeNames = [];
end

if ~isdir(REMORA.nn.classify.saveDir)
    fprintf('Making output folder %s',REMORA.nn.classify.saveDir)
    mkdir(REMORA.nn.classify.saveDir)
end

classificationInfo = REMORA.nn.classify;

for iFile = 1:nFiles
    specSet = []; iciSet = []; waveSet = [];
    load(fullfile(fList(iFile).folder,fList(iFile).name))
    if ~exist('binData','var')
        warning('File doesn''t have the expected contents. Skipping.')
        continue
    end
    tooFew = find([binData(:).nSpec]'<5);
    numClusters = [];
    rowCounter = [];
    for iRow = 1:size(binData)
        numClusters(iRow,1) = size(binData(iRow).sumSpec,1);
        rowCounter = [rowCounter;[repmat(iRow,numClusters(iRow,1) ,1),...
            nInt+[0:1:numClusters(iRow,1)-1]]];
        nInt = nInt+1;
    end
    if trainTestSetInfo.useSpectra
        specSet = vertcat(binData.sumSpec);
        specSet(tooFew) = [];
    end
    
    if trainTestSetInfo.useICI
        iciSet = vertcat(binData.dTT);
        iciSet(tooFew) = [];
    end
        
    if trainTestSetInfo.useWave
        waveSet = vertcat(binData.envMean);
        waveSet(tooFew) = [];
    end
    
    test4D = table(mat2cell([specSet,iciSet,waveSet],ones(size(MSN,1),1)));
    
    % classify
    [predLabels,predScores] = classify(trainedNet.net,test4D);
    predScoresMax = max(predScores,[],2);
    % save labels
    saveName = strrep(TPWSList(iTPWS).name,'.mat','_labels.mat');
    if strcmp(saveName, TPWSList(iTPWS).name)
        error('Something went wrong: Input and output names match, might overwrite. Aborting.')
    end
    
    
    binData.label
    bindata.labelProb
    zID = [MTT,double(predLabels)];
    save(fullfile(REMORA.nn.classify.saveDir,saveName),'zID','predScoresMax','trainTestSetInfo',...
        'netTrainingInfo','classificationInfo','typeNames', '-v7.3')
    fprintf('Done with file %0.0f of %0.0f: %s\n',iTPWS, nFiles,TPWSList(iTPWS).name)

end
