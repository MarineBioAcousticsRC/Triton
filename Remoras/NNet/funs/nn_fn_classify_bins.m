function nn_fn_classify_bins(varargin)

global REMORA

if ~isempty(varargin)
    excludeList = varargin{1};
else
    excludeList = [];
end

minSize = 2;
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

if ~isfield(trainedNet,'trainTestSetInfo')
    warning('No variable called ''trainedNet.trainTestSetInfo''')
    disp('Assume spectra, ici and waveform should be used.')
    trainedNet.trainTestSetInfo.useSpectra = 1;
    trainedNet.trainTestSetInfo.useICI = 1;
    trainedNet.trainTestSetInfo.useWave = 1;
end

if ~isfield(trainedNet,'netTrainingInfo')
    warning('WARNING: No variable called ''trainedNet.netTrainingInfo''')
    trainedNet.netTrainingInfo = [];
end

if ~isfield(trainedNet,'typeNames')
    warning('WARNING: No variable called ''trainedNet.typeNames''')
    typeNames = [];
end

if ~isdir(REMORA.nn.classify.saveDir)
    fprintf('Making output folder %s',REMORA.nn.classify.saveDir)
    mkdir(REMORA.nn.classify.saveDir)
end

classificationInfo = REMORA.nn.classify;

for iFile = 1:nFiles
    specSet = []; iciSet = []; waveSet = [];
    inFile = fullfile(fList(iFile).folder,fList(iFile).name);
    load(inFile)
    if ~exist('binData','var')
        warning('File doesn''t have the expected contents. Skipping.')
        continue
    end
    
    saveName = strrep(fList(iFile).name,'.mat','_labels.mat');
    saveFullFile = fullfile(REMORA.nn.classify.saveDir,saveName);
    if strcmp(inFile, saveFullFile)
        error('Something went wrong: Input and output names match, might overwrite. Aborting.')
    end

    tooFew = find([binData(:).nSpec]'< minSize);
    goodSize = find([binData(:).nSpec]'>= minSize);
    nRows = size(goodSize,1);
%     numClusters = [];
%     rowCounter = [];
%     nInt = 1;
%     for iRow = 1:size(binData)
%         numClusters(iRow,1) = size(binData(iRow).sumSpec,1);
%         rowCounter = [rowCounter;[repmat(iRow,numClusters(iRow,1) ,1),...
%             nInt+[0:1:numClusters(iRow,1)-1]']];
%         nInt = nInt+1;
%     end
    tTSI = trainedNet.trainTestSetInfo;
    specSet = vertcat(binData(:).sumSpec);
    iciSet = vertcat(binData.dTT);
    waveSet = vertcat(binData.envMean);
    dataInput = [specSet,iciSet,waveSet];

    dataInputStd = nn_fn_standardize_data(trainedNet.trainTestSetInfo,dataInput);
    % if trainedNet.trainTestSetInfo.useSpectra
    %     specSet = vertcat(binData(:).sumSpec);
    %     specSet(tooFew,:) = [];
    %     %specSet = (specSet*60)+60; %TEMP!!!
    %     specSet= (specSet-tTSI.specStd(1))/(tTSI.specStd(2)-tTSI.specStd(1));
    % end
    % 
    % if trainedNet.trainTestSetInfo.useICI
    %     iciSet = vertcat(binData.dTT);
    %     iciSet = iciSet./max(iciSet,[],2);
    %     max0 = find(max(iciSet,[],2)>0);
    %     iciSet(max0,:) = iciSet(max0,:)./(tTSI.iciStd);
    %     iciSet(tooFew,:) = [];
    % 
    % end
    % 
    % if trainedNet.trainTestSetInfo.useWave
    %     % check for old bug where envs were averaged to a single value
    %     % along wrong dimension.
    %     waveLen = arrayfun(@(x) size(binData(x).envMean,2),1:numel(binData));
    %     tooShort = find(waveLen ==1);
    %     for iS = 1:length(tooShort)
    %         binData(tooShort(iS)).envMean = ones(1,max(waveLen));
    %     end
    %     waveSet = vertcat(binData.envMean);
    %     waveSet(tooFew,:) = [];
    %     maxWave = max(waveSet,[],2);
    %     waveSet= waveSet./maxWave;
    % end
    % 

    %test4D = table(mat2cell([specSet,iciSet,waveSet],ones(nRows,1)));

    % classify
    dataInputStdR = reshape(dataInputStd,[1,size(dataInputStd,2),1,...
    size(dataInputStd,1)]);
    predScoresAll = predict(trainedNet.net,dataInputStdR);
%    if ~isempty(excludeList)
    [~,keepCols] = setdiff(trainedNet.typeNames,excludeList);
    typeNames = trainedNet.typeNames;
    if ~isempty(excludeList)
         typeNames = typeNames(keepCols);
    end
    predScoresAll = predScoresAll(:,keepCols);
    [predLabels,predScoresMax] = scores2label(predScoresAll,categorical(1:length(typeNames)));

    % else
    %     predLabels = double(predLabels);
    %     predScoresMax = max(predScores,[],2);       
    % 
    % end
    % map bin labels back into binData
    predLabelsExpand = nan(size([binData(:).nSpec]',1),1);
    predLabelsExpand(goodSize) = predLabels;
    predScoresMaxExpand = nan(size([binData(:).nSpec]',1),1);
    predScoresMaxExpand(goodSize) = predScoresMax;
    myIndex = 1;
    for iBin = 1:size(binData,1)
        nSpecSize = size(binData(iBin).nSpec);
        subIndex = myIndex:(myIndex+nSpecSize(2)-1);
        binData(iBin).predLabels = predLabelsExpand(subIndex);
        binData(iBin).predLabelScore = predScoresMaxExpand(subIndex);
        myIndex = max(subIndex)+1;
    end
    % save all the things
    netTrainingInfo = trainedNet.netTrainingInfo;
    trainTestSetInfo = trainedNet.trainTestSetInfo;

    save(saveFullFile,'predScoresMax','trainTestSetInfo',...
        'netTrainingInfo','classificationInfo','typeNames','binData',...
        'f','p','TPWSfilename','-v7.3')
    fprintf('Done with file %0.0f of %0.0f: %s\n',iFile, nFiles,inFile)
    % should we plot here?

    if REMORA.nn.classify.intermedPlotCheck
        classifiedThings  = [specSet,iciSet,waveSet];
        nPlots = length(typeNames);
        nRows = 3;
        nCols = ceil(nPlots/nRows);
        if ~isfield(REMORA.fig, 'nn')
            REMORA.fig.nn = [];
        end
        if ~isfield(REMORA.fig.nn,'binClass') || ~isvalid(REMORA.fig.nn.binClass)
            REMORA.fig.nn.binClass = figure;
        else
            figure(REMORA.fig.nn.binClass)
        end
        clf;colormap(jet)
        set(gcf,'name', 'Bin Classifications (Intermediate)')
        for iR = 1:nPlots
            ax1 = subplot(nRows,nCols,iR);
            idxToPlot = find(double(predLabels)==iR);
            [classScore,plotOrder] = sort(predScoresMax(idxToPlot),'descend');
            imagesc(classifiedThings(idxToPlot(plotOrder),:)')
            set(gca,'ydir','normal','clim',[0,1.8])
            title(typeNames{iR})
            if size(classScore,1)>1
                ax2 = axes('Position', get(ax1, 'Position'),'Color', 'none');
                set(ax2, 'XAxisLocation', 'top','YAxisLocation','Right');
                
                set(ax2, 'XLim', get(ax1, 'XLim'),'YLim', get(ax1, 'YLim'));
                confidenceLevelIdx = [find(classScore>=.99,1,'last'),find(classScore>=.9,1,'last')];
                [~,iA] =  unique(confidenceLevelIdx);
                confidenceLabels = {'0.99>';'0.9>'};
                box(ax2,'off')
                set(ax2, 'XTick',confidenceLevelIdx(iA)+.5,...
                    'XTickLabel',confidenceLabels(iA),'TickDir','out','YTick',[],'FontSize',8);
            end
           
        end
        disp('Paused: Press any key to continue.')
        drawnow
        pause
    end
    % TODO: Have option to hold on to output and make plot of everything
    % classified at the end. 
    % also disaggregate times above to make quick and dirty timeseries
    % (not won't work for mixed simultaneous sites).
%     if aggregateOutput
%     ALLclassifiedThings = [ALLclassifiedThings;classifiedThings]
%     classifiedThings   = 
%     end
end
if isfield(REMORA.fig.nn,'binClass')&& isvalid(REMORA.fig.nn.binClass)
    close(REMORA.fig.nn.binClass)
end
