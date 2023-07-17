function nn_fn_classify_dets

global REMORA
disp('Classifying detections from TPWS files')
% load network
trainedNet = load(REMORA.nn.classify.networkPath);
fprintf('Loaded network %s\n', REMORA.nn.classify.networkPath)

% identify files.
TPWSwild = [REMORA.nn.classify.wildcard,'*TPWS1.mat'];
if REMORA.nn.classify.searchSubDirsTF
    TPWSList = rdir(REMORA.nn.classify.inDir,TPWSwild);
else
    TPWSList = dir(fullfile(REMORA.nn.classify.inDir,TPWSwild));
end
nFiles = size(TPWSList,1);
fprintf('%0.0f TPWS files found\n',nFiles)

if ~exist('trainTestSetInfo','var')
    warning('No variable called ''trainTestSetInfo''')
    disp('Assume both spectra and waveform should be used.')
    trainTestSetInfo.useSpectra = 1;
    trainTestSetInfo.useWave = 1;
end

if ~exist('netTrainingInfo','var')
    warning('WARNING: No variable called ''netTrainingInfo''')
    netTrainingInfo = [];
end
typeNames = trainedNet.typeNames;
if ~exist('typeNames','var')
    warning('WARNING: No variable called ''typeNames''')
    typeNames = [];
end

if ~isdir(REMORA.nn.classify.saveDir)
    fprintf('Making output folder %s',REMORA.nn.classify.saveDir)
    mkdir(REMORA.nn.classify.saveDir)
end

classificationInfo = REMORA.nn.classify;


disp('Beginning classification.')

for iTPWS = 1:nFiles
    % load TPWS
    MSP = [];
    MSN = [];
    load(fullfile(TPWSList(iTPWS).folder,TPWSList(iTPWS).name),'MTT')
    
    if trainTestSetInfo.useSpectra
        load(fullfile(TPWSList(iTPWS).folder,TPWSList(iTPWS).name),'MSP')
    end
    
    if trainTestSetInfo.useWave
        load(fullfile(TPWSList(iTPWS).folder,TPWSList(iTPWS).name),'MSN')
    end
    
    test4D = table(mat2cell([nn_fn_normalize_spectrum(MSP),nn_fn_normalize_timeseries(MSN)],ones(size(MSN,1),1)));
    %test4D = table(mat2cell([(MSP),(MSN)],ones(size(MSN,1),1)));

    % classify
    [predLabels,predScores] = classify(trainedNet.net,test4D);
    predScoresMax = max(predScores,[],2);
    % save labels
    saveName = strrep(TPWSList(iTPWS).name,'.mat','_labels.mat');
    saveNameID = strrep(TPWSList(iTPWS).name,'TPWS','ID');
    if strcmp(saveName, TPWSList(iTPWS).name)
        error('Something went wrong: Input and output names match, might overwrite. Aborting.')
    end
    zID = [MTT,double(predLabels),double(predScoresMax)];
    save(fullfile(REMORA.nn.classify.saveDir,saveName),'zID','predScoresMax','trainTestSetInfo',...
        'netTrainingInfo','classificationInfo','typeNames','-v7.3')
    save(fullfile(REMORA.nn.classify.saveDir,saveNameID),'zID','typeNames','-v7.3')
    fprintf('Done with file %0.0f of %0.0f: %s\n',iTPWS, nFiles,TPWSList(iTPWS).name)
end