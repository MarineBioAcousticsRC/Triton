function [exitCode,ccOutput] = ct_composite_clusters(varargin)

exitCode = 0;
ccOutput = [];
% Cluster binned averages using a range of possible features
if nargin == 1
    % Check if settings file was passed in function call
    if ischar(varargin{1})
        % a file name was passed in, assume it is a script for generating
        % cluster params "p"
        ccParamsFile = varargin{1};
        % If so, load it
        fprintf('Loading settings file %s\n\n',ccParamsFile)
        run(ccParamsFile);
    elseif isstruct(varargin{1})
        % a struct was passed in, assume it contains the detection
        % parameters detParams
        s = varargin{1};
    end
    
else
    % If no settings file provided, prompt for input
    currentDir = mfilename('fullpath');
    expectedSettingsDir = fullfile(fileparts(currentDir),'settings');
    [settingsFileName,settingsFilePath , ~] = uigetfile(expectedSettingsDir);
    if ~isempty(settingsFileName)
        ccParamsFile = fullfile(settingsFilePath,settingsFileName);
        fprintf('Loading settings file %s\n\n',ccParamsFile)
        run(ccParamsFile);
        
    else
        error('No settings file selected')
    end
end

% Clusters a set of mean spectra and ici distributions to identify major
% click types in a dataset.
% ** Run this on the output from cluster_bins.m **

%%
% Check for output directory
if ~exist(s.outDir,'dir')
    mkdir(s.outDir)
else
    oldFileList = dir(fullfile(s.outDir,['*',s.outputName,'*']));
    if ~isempty(oldFileList)
        waitfor(warndlg(['WARNING: You are about to overwrite prior output. ',...
                    'If the number of clusters produced now is fewer than ',... 
                    'produced previously, you may end up with old cluster files ',...
                    'mixed in with new ones. To reduce risk of errors, consider ',...
                    'deleting, changing output folder, or changing output name. (Use Control-C to stop).'],...
                'Warning: File Overwrite','replace'));
            
    end
end
cd(s.outDir)
if s.diary
    diary(fullfile(s.outDir,sprintf('composite_clust_diary_%s.txt',datestr(now,'YYYYMMDD'))))
end
disp(s)
disp('Loading inputs...')
% load data from folder of files
inFileList = dir(fullfile(s.inDir,s.inFileString));
if isempty(inFileList)
    warning('on')
    warning('No input files found to match %s\n Check your input path and wildcard.',...
        fullfile(s.inDir,s.inFileString))
    return
end
TPWSList = {};
binDataPruned = [];
fileNum = [];
for iFile = 1:length(inFileList)
    if ~inFileList(iFile).isdir
        loadedData = load(fullfile(inFileList(iFile).folder,...
            inFileList(iFile).name));
        if ~isfield(loadedData,'binData')
            % code for backward compatibility with older input files.
            for iTval = 1:length(loadedData.tInt)
                if size(loadedData.dTT{iTval},1) > size(loadedData.dTT{iTval},2)
                    loadedData.dTT{iTval} = loadedData.dTT{iTval}';
                    loadedData.clickRate{iTval} = loadedData.clickRate{iTval}';
                end
                if isempty(loadedData.dTT{iTval})
                    loadedData.dTT{iTval} = zeros(1,51);
                    loadedData.clickRate{iTval} = zeros(1,30);
                end
            end
            binData = struct('sumSpec',loadedData.sumSpec,...
                'nSpec',loadedData.nSpec,'percSpec',loadedData.percSpec,...
                'cInt',num2cell(loadedData.cInt),'tInt',num2cell(loadedData.tInt(:,1)),...
                'dTT',loadedData.dTT,'clickRate',loadedData.clickRate);
            binDataPruned = [binDataPruned;binData];
            fileNum = [fileNum;iFile*ones(size(binData))];
        else
            binDataPruned = [binDataPruned;loadedData.binData];
            fileNum = [fileNum;iFile*ones(size(loadedData.binData))];
        end
        
        f = loadedData.f;
        p = loadedData.p;
        TPWSList{iFile} = loadedData.TPWSfilename;
    end
end
clear('loadedData')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global REMORA
tritonMode = 0;
if isfield(REMORA,'ct')
    tritonMode = 1; % if REMORA.ct is populated, assume we're running through a triton gui and
    % triton tools are fair game.
end
if  tritonMode && isfield(REMORA.ct.CC,'rm_simbins')...
        && REMORA.ct.CC_params.rmSimBins
    %     thresh = 0.95;
    %     dist = 0.1;
    specComp = REMORA.ct.CC.sbSet;
    [binDataPruned,fileNum] = ct_cc_modifyBinData(REMORA.ct.CC_params.SBperc,REMORA.ct.CC_params.SBdiff,binDataPruned,specComp,fileNum);
end
% %%%%%%%%%% Begin main functionality %%%%%%%%%%%%
%% Normalize everything
% Spectra:
% Put click spectra into a matrix
sumSpecMat = vertcat(binDataPruned.sumSpec);
nSpecMat = horzcat(binDataPruned.nSpec)';
dTTmat = vertcat(binDataPruned.dTT);
cRateMat = vertcat(binDataPruned.clickRate);
clickTimes = horzcat(binDataPruned(:).clickTimes);
if ~isfield(p,'maxDur')
    p.maxDur = 1;
end
for iEM = 1:size(binDataPruned,1)
    if ~isfield(binDataPruned,'envMean')
       binDataPruned(iEM).envMean = [];
    end
    if size(binDataPruned(iEM).envMean,2) == 1 || size(binDataPruned(iEM).envMean,2) == 0
        binDataPruned(iEM).envMean = zeros(1,p.maxDur);
    end
    %     if size(binDataPruned(iEM).envMean,2) == 1
    %         binDataPruned(iEM).envDur = zeros(1,p.envDur);
    %     end
end
envShape = vertcat(binDataPruned(:).envMean);
%envDistrib = vertcat(binDataPruned(:).envDur);

clustersInBin = nan(size(dTTmat,1),1);
tIntMat =  nan(size(dTTmat,1),1);
subOrder =  nan(size(dTTmat,1),1);
binOrder =  nan(size(dTTmat,1),1);
fileNumExpand = nan(size(dTTmat,1),1);
clickTimesExpanded = {};
clusteredTFmat = nan(size(dTTmat,1),1);
stepCounter = 1;
for iTimes = 1:size(binDataPruned,1)
    nCells = size(binDataPruned(iTimes).nSpec,2);
    clustersInBin(stepCounter:stepCounter+nCells-1) = repmat(nCells,...
        nCells,1);
    binIdx(stepCounter:stepCounter+nCells-1) = repmat(iTimes,...
        nCells,1);
    tIntMat(stepCounter:stepCounter+nCells-1) = repmat(binDataPruned(iTimes).tInt(1),...
        nCells,1);
    subOrder(stepCounter:stepCounter+nCells-1) = 1:size(binDataPruned(iTimes).nSpec,2);
    fileNumExpand(stepCounter:stepCounter+nCells-1) = repmat(fileNum(iTimes),...
        nCells,1);
    clusteredTFmat(stepCounter:stepCounter+nCells-1) = repmat(binDataPruned(iTimes).clusteredTF,...
        nCells,1);
    stepCounter = stepCounter+nCells;
    
end
if s.singleClusterOnly
    useBins = logical((nSpecMat >= s.minClicks).*(clustersInBin==1));
else
    useBins = (nSpecMat >= s.minClicks);
end

if isfield(s,'clusteredOnly')&& s.clusteredOnly
    useBins = logical(min(useBins,clusteredTFmat));
end

if ~isfield(s,'useEnvShapeTF')
    s.useEnvShapeTF = 0;
end
[~,s.stIdx] = min(abs(f-s.startFreq));
[~,s.edIdx] = min(abs(f-s.endFreq));

if ~isfield(s,'normalizeSpectra') 
    s.normalizeSpectra = 1;
end

if s.useEnvShapeTF
    noZeros = max(envShape,[],2)>0;
    useBins = logical(min(useBins,noZeros));
end
% s.rmMFA = 1;
% if s.rmMFA
%     [~,maxLoc] = max(mean(envShape));
%     badBins = (envShape(:,maxLoc-2)<.20&envShape(:,maxLoc+2)<.2);
%     useBins = logical(min(useBins,~badBins));
% 
% end

[specNorm,diffNormSpec] = ct_spec_norm_diff(sumSpecMat(useBins,:),s.stIdx,s.edIdx, s.linearTF,s);

[~,s.maxICIidx] = min(abs(p.barInt-s.maxICI));
[~,s.minICIidx] = min(abs(p.barInt-s.minICI));

dTTmat = dTTmat(useBins,1:s.maxICIidx); % truncate if needed to ignore high ici peaks
dTTmatNorm1 = dTTmat./repmat(sum(dTTmat,2),1,size(dTTmat,2));
dTTmatNorm = dTTmatNorm1./repmat(max(dTTmatNorm1,[],2),1,size(dTTmat,2));

% Handle ICI distributions that have saturation issues due to overlapping
% clicking.
% find dTT rows where first bin is largest
[~,iciModeIdx] = max(dTTmatNorm(:,s.minICIidx:end),[],2);

% find secondary ICI peak in saturated ICI distributions
if s.correctForSaturation
    iciModeIdx = ct_correct_for_saturation(p,s.maxICIidx,dTTmatNorm,iciModeIdx);
end
iciModes = p.barInt(iciModeIdx) + p.barInt(2)./2;
% [iciDist,~,~] = ici_dist(dTTmatNorm);

% Click rates - convert to matrix and normalize
cRateMat = cRateMat(useBins,:);
cRateNorm1 = cRateMat./repmat(sum(cRateMat,2),1,size(cRateMat,2));
cRateNorm = cRateNorm1./repmat(max(cRateNorm1,[],2),1,size(cRateMat,2));
[~,cRateModeIdx] = max(cRateNorm,[],2);
cRateModes = p.barRate(cRateModeIdx) + p.barRate(2)./2;
clickTimes = clickTimes(useBins);
tIntMat = tIntMat(useBins);
subOrder = subOrder(useBins);
fileNumExpand = fileNumExpand(useBins);
envShape = envShape(useBins,:);
%% Cluster N times for evidence accumulation/robustness
% CoMat = zeros(tempN,tempN);
subSamp = 1; % flag automatically goes to true if subsampling.
isolatedSet = [];
wNodeDeg = {};

% global REMORA
% tritonMode = 0;
% if isfield(REMORA,'ct')
%     tritonMode = 1; % if REMORA.ct is populated, assume we're running through a triton gui and 
%     % triton tools are fair game.
% end
if  tritonMode && isfield(REMORA.ct.CC,'rm_clusters')...
    && REMORA.ct.CC_params.rmPriorClusters
    badSet = REMORA.ct.CC.rmSet;
    [~,removeSetIndex] = setdiff([tIntMat,subOrder],badSet,'rows');
    cRateMat = cRateMat(removeSetIndex,:);
    clickTimes = clickTimes(removeSetIndex);
    tIntMat = tIntMat(removeSetIndex);
    subOrder = subOrder(removeSetIndex);
    fileNumExpand = fileNumExpand(removeSetIndex);
    dTTmatNorm = dTTmatNorm(removeSetIndex,:);
    specNorm = specNorm(removeSetIndex,:);
    diffNormSpec = diffNormSpec(removeSetIndex,:);
    envShape = envShape(removeSetIndex,:);
end
mergeSimilarNodes = 0;
if mergeSimilarNodes
    rmNode = zeros(size(specNorm,1),1);
    [specDist,~,~] = ct_spectra_dist(specNorm);
    sqSpecDist = squareform(specDist);
    mergeNodeID = (1:size(specNorm,1))';
    for iNode = 1:length(mergeNodeID)
        % find the next signal that looks like this one
        newNum = find(sqSpecDist(iNode,iNode:end)>.99,1,'first');
        if ~isempty(newNum)
            rmNode(iNode) = 1;
        end
    end
    rmSet = ~logical(rmNode);
    cRateMat = cRateMat(rmSet,:);
    clickTimes = clickTimes(rmSet);
    tIntMat = tIntMat(rmSet);
    subOrder = subOrder(rmSet);
    fileNumExpand = fileNumExpand(rmSet);
    dTTmatNorm = dTTmatNorm(rmSet,:);
    specNorm = specNorm(rmSet,:);
    diffNormSpec = diffNormSpec(rmSet,:);
    envShape = envShape(rmSet,:);
end
for iEA = 1:s.N
    % Select random subset if needed
    if size(cRateMat,1)> s.maxClust
        if s.subSampOnlyOnce && subSamp == 1
            % set flag back to zero if you only want to subsample once,
            % rather than taking a new subsample every time.
            subSamp = 0;
            excludedIn = sort(randperm(size(dTTmatNorm,1), s.maxClust));
            fprintf('Max number of bins exceeded. Selecting random subset of %d\n',s.maxClust)
        elseif ~s.subSampOnlyOnce
            excludedIn = sort(randperm(size(dTTmatNorm,1), s.maxClust));
            fprintf('Max number of bins exceeded. Selecting random subset of %d\n',s.maxClust)
        end
        
    else
        excludedIn = 1:size(dTTmatNorm,1);
        subSamp = 0;
    end
    s.subSamp = subSamp;
    if subSamp || iEA == 1
        % Only do this on first iteration, or on every iteration if you are subsampling
        % find pairwise distances between spectra
        if s.specDiffTF && s.useSpectraTF
            [specDist,~,~] = ct_spectra_dist(diffNormSpec(excludedIn,s.stIdx:s.edIdx-1));
        elseif s.useSpectraTF
            [specDist,~,~] = ct_spectra_dist(specNorm(excludedIn,s.stIdx:s.edIdx));
        end
        %         specSetHighs = zeros(size(specNorm(excludedIn,s.stIdx:s.edIdx)));
        %         specSetHighs(specNorm(excludedIn,s.stIdx:s.edIdx)>=.5) = 1;
        %         amplitudeMatch = exp(-(pdist(specSetHighs,'seuclidean')/10));
        
        if s.iciModeTF && s.useTimesTF % if true, use ici distributions for similarity calculations
            [iciModeDist,~,~,~] = ct_ici_dist_mode(iciModes(excludedIn),p.barInt(s.maxICIidx));
            compDist = squareform(sqrt(iciModeDist),'tomatrix');
            fprintf('Clustering on modal ICI ')
        elseif s.iciDistTF && s.useTimesTF
            % if true, use ici distributions for similarity calculations
            [iciDist,~,~] = ct_ici_dist(dTTmatNorm(excludedIn,s.minICIidx:s.maxICIidx));
            compDist = squareform(iciDist,'tomatrix');
            disp('Clustering on ICI distribution ')
        elseif s.cRateTF && s.useTimesTF
            % use click rate distributions for similarity calculations
            [cRateDist,~,~] = ct_ici_dist(cRateNorm(excludedIn,:));
            compDist = squareform(cRateDist,'tomatrix');
            disp('Clustering on modal click rate ')
        elseif s.useSpectraTF && ~s.useTimesTF
            % if nothing, only use spectra
            compDist = squareform(specDist,'tomatrix');
            disp('Clustering on spectral correlations')
        end
        
        if s.useSpectraTF && s.useTimesTF
            compDist = compDist.*squareform(specDist,'tomatrix');
            fprintf('and spectral correlations\n')
        else
            fprintf('\n')% terminate the statement.
        end
        
        % add cluster on waveform option:
        if s.useEnvShape
            disp('Add clustering on waveform envelope shape')
            [envShapeDist,~,~] = ct_spectra_dist(envShape(excludedIn,:));
            if exist('compDist','var')
                compDist = compDist.*squareform(envShapeDist,'tomatrix');
            else
                compDist = squareform(envShapeDist,'tomatrix');
            end
        elseif 0%s.useEnvDur
            [envDurDist,~,~] = ct_spectra_dist(envDur(excludedIn,:));
            if exist('compDist','var')
                compDist = compDist.*squareform(envDurDist,'tomatrix');
            else
                compDist = squareform(envDurDist,'tomatrix');
            end
        end
        % [gv_file,isolated] = write_gephi_input(compDist, s.minClust,s.pruneThr);
        
        
        % prune out weak linkages
        %     for iPrune=1:length(compDist)
        %         thrP = prctile(compDist(iPrune,:),s.pruneThr);% fluctuating threshold
        %         lowVals = compDist(iPrune,:)<=thrP;
        %         compDist(iPrune,lowVals) = 0;
        %     end
        
        % compDistVec = squareform(compDist);
        %         for iRow = 1:size(compDist,1)
        %             compDist(iRow,1:iRow) = NaN;
        %         end
        if s.mergeTF
            compDistNoNaN = compDist(~isnan(compDist));
            thrP = prctile(compDistNoNaN(compDistNoNaN<.99),s.pruneThr);
        else
            thrP = prctile(compDist(~isnan(compDist)),s.pruneThr);
        end
        %thrP = prctile(compDist(~isnan(compDist)),s.pruneThr);% fluctuating threshold
        compDist(compDist<thrP) = 0;
        % compDist = squareform(compDistVec);
        % clear compDistVec
        % compDist = compDist.*squareform(amplitudeMatch);
%         nodeVec1 = [];
%         nodeVec2 = [];
%         for iR = 1:size(compDist,1)-1
%         	nodeVec1 = [nodeVec1,iR*ones(1,size(compDist,1)-iR)];
%             nodeVec2 = [nodeVec2,(iR+1):size(compDist,1)];
%         end
    end
    
    tempN = size(compDist,1);
    if s.mergeTF
        [mergeNodeID,uMergeNodeID,~] = ct_merge_nodes(compDist,...
            tempN,specNorm);
        compDistOrig = compDist;
        compDist = compDist(uMergeNodeID,uMergeNodeID);
    end
    numNodes = size(compDist,1);% in case pruning has happened, compute this
    % for use in preallocation
    connectedList = nansum(compDist)>0; % isolated nodes have NAN
    allIndices = 1:numNodes;
    isolated = setdiff(allIndices, allIndices(connectedList));
    
    
    fprintf('Clustering for evidence accumulation: %d of %d\n',iEA,s.N)
    
    % cluster
    %    nodeN = size(compDist,1);
    %     [nodeAssign,excludedOut,rankAssign] = run_gephi_clusters(nodeN,...
    %         s.minClust,s.modular,s.pgThresh,s.javaPathVar,s.classPathVar,s.toolkitPath,gv_file);
    %     [~,nodeAssign,~,~,excludedOut] = cluster_clicks_cw_merge(specClickTf,p,...
    %         normalizeTF, mergeTF);
    clusterID = (1:numNodes)';
    %clusterID = clusterID';
    if s.mergeTF
        clusterID(~ismember(clusterID,uMergeNodeID)) = NaN;
    end
    clusterID(connectedList==0) = NaN;
    s.plotFlag = 0;
    s.maxCWiterations = s.maxCWIterations;
    clusterID = ct_run_CW_cluster(clusterID,compDist,s);
    
    if s.mergeTF
        % unwind node merge by assigning nodes that were merged to the category of
        % their parent.
        for iMerge = 1:length(uMergeNodeID)
            thisID = uMergeNodeID(iMerge);
            nodeClusterID = clusterID(thisID);
            clusterID(mergeNodeID == thisID) = nodeClusterID;
        end
    end
    
    
    percentIsolated = 100*((length(clusterID)-sum(~isnan(clusterID)))./length(clusterID));
    fprintf('%0.2f %% of nodes isolated.\n',percentIsolated)
    clustBins = 0:max(clusterID);
    counts = histc(clusterID,clustBins);
    keepClust = find(counts >= s.minClust);
    clustNums = clustBins(keepClust);
    nodeSet = {};
    withinClusterWDegree = {};
    if ~isempty(keepClust)
        for i4 = 1:length(keepClust)
            nodeIndex = clusterID==clustNums(i4);
            nodeSet{i4} = excludedIn(nodeIndex);
            withinClusterWDegree{i4} = nansum(compDist(nodeIndex,nodeIndex),2);
        end
    end
    
    % Recover from random permutation
    %     iL = 1;
    %     nodeSet = {};
    %     for iA = 1:length(nodeAssign)
    %         nodeSet{iA} = excludedIn(nodeAssign{iL});
    %         % update co-association matrix (Fred and Jain 2005)
    %         % CoMat(nodeSet{iA},nodeSet{iA}) = CoMat(nodeSet{iA},nodeSet{iA})+ 1/N;
    %         iL = iL+1;
    %     end
    wNodeDeg{iEA} = withinClusterWDegree;
    prunedNodeSetTemp = {};
    for iCluster = 1:length(withinClusterWDegree)
        wND = withinClusterWDegree{iCluster};
        wNDnorm = wND./max(wND);
        wNDpruned = find(wNDnorm>=s.clusterPrune);
        prunedNodeSetTemp{iCluster} = nodeSet{iCluster}(wNDpruned);
    end
    
    prunedNodeSet{iEA} = prunedNodeSetTemp;
    nList{iEA} = excludedIn;
    ka(iEA,1) = length(nodeSet);
    naiItr{iEA} = nodeSet;
    fprintf('found %d clusters\n',length(nodeSet))
    isolatedSet(iEA,1) = length(setdiff(excludedIn,horzcat(nodeSet{:})));
    inputSet{iEA} = setdiff(excludedIn,isolated);

end


% Best of K partitions based on NMI filkov and Skiena 2004
% Compute NMI
fprintf('Calculating NMI\n')

[NMIList] = ct_compute_NMI(nList,ka,naiItr,inputSet);
% the one with the highest mean score is the best
[bokVal,bokIdx] = max(sum(NMIList)./(size(NMIList,1)-1)); % account for empty diagonal.

bestPrunedNodeSet = prunedNodeSet{bokIdx};
nodeSet = bestPrunedNodeSet;% naiItr{bokIdx};

if isempty(nodeSet)
    disp('No clusters formed')
    if tritonMode;disp_msg('No clusters formed');end
    return
end

clusterIDreduced = zeros(size(compDist,1),1);
for iNodeSet = 1:length(nodeSet)
    [~,setIntersect] = intersect(excludedIn,nodeSet{iNodeSet});
    clusterIDreduced(setIntersect) = iNodeSet;
end

if tritonMode && (size(clusterIDreduced,1)<10000)

    fprintf('Plotting network\n')

    figure(110);clf
    G = graph(compDist);    
    h = plot(G,'layout','force');

    set(h,'MarkerSize',8,'NodeLabel',clusterIDreduced)
    
%     for iClustPlot=1:size(nodeSet,2)
%         highlight(h, nodeSet{iClustPlot},'nodeColor',rand(1,3))
%     end    

else
    disp('Too many nodes to plot as network.')
end


% % Final cluster using Co-assoc mat.
% disp('Clustering using accumulated evidence')
% compDist2 = compDist;
% compDist2(find(CoMat<1))=0;
% [nodeSet,excludedOut,rankAssign] = cluster_nodes(compDist2,...
%        minClust,pruneThr,modular,pgThresh);

%% calculate means, percentiles, std devs
fprintf('Creating output structures\n')

compositeData = struct(...
    'spectraMeanSet',[],'specPrctile',{},'iciMean',[],...
    'iciStd',[],'cRateMean',[],'cRateStd',[]);
Tfinal = {};

if s.linearTF
    specNorm = (20*log10(specNorm))-1;
end

for iTF = 1:length(nodeSet)
    % compute mean of spectra in linear space
    compositeData(iTF,1).spectraMeanSet = nanmean(specNorm(nodeSet{iTF},:),1);

    %linearSpec = 10.^(specNorm(nodeSet{iTF},:)./20);
    compositeData(iTF,1).specPrctile = prctile(specNorm(nodeSet{iTF},:),[25,75]);
    compositeData(iTF,1).iciMean = nanmean(dTTmatNorm(nodeSet{iTF},:));
    compositeData(iTF,1).iciStd = nanstd(dTTmatNorm(nodeSet{iTF},:));
    compositeData(iTF,1).cRateMean = nanmean(cRateNorm(nodeSet{iTF},:));
    compositeData(iTF,1).cRateStd = nanstd(cRateNorm(nodeSet{iTF},:));
    
    % Save stuff in a compact way for matching
    Tfinal{iTF,1} = specNorm(nodeSet{iTF},:);% all mean spectra
    Tfinal{iTF,2} = dTTmatNorm(nodeSet{iTF},:);% ici ditributions
    Tfinal{iTF,3} = diffNormSpec(nodeSet{iTF},:); % 1st diff spectra
    Tfinal{iTF,4} = iciModes(nodeSet{iTF}); % modal ICI vals
    Tfinal{iTF,5} = compositeData(iTF).spectraMeanSet; % mean spectrum
    Tfinal{iTF,6} = fileNumExpand(nodeSet{iTF}); % file it came from
    Tfinal{iTF,7} = tIntMat(nodeSet{iTF}); % time of bin
    Tfinal{iTF,8} = nodeSet{iTF};% primary index of bin in
    Tfinal{iTF,9} = subOrder(nodeSet{iTF}); % subIndex of bin
    Tfinal{iTF,10} = envShape(nodeSet{iTF},:); % all mean envelope shape
end
bestWNodeDeg = wNodeDeg{bokIdx};
s.barAdj = .5*mode(diff(p.barInt));%p.stIdx = 2;
exitCode = 1; % Call it a success if you made it this far.

% make default cluster names
labelStr = {};
for iEd = 1:length(nodeSet)
    % Make editable name field
    labelStr{iEd} = sprintf('Cluster%0.0f',iEd);
end

if s.subPlotSet
    fprintf('Plotting inter cluster comparisons\n')
    ct_intercluster_plots(p,s,f,nodeSet,compositeData,Tfinal,labelStr,s.outDir);
end

if s.indivPlots
    fprintf('Making individual type plots\n')
    ct_individual_click_plots(p,s,f,nodeSet,compositeData,Tfinal,labelStr,s.outDir)
end
% binDataUsed = binDataPruned(binIdx(useBins));
% for iR = 1:length(binDataUsed)
%     binDataUsed(iR).fileNum = fileNumExpand(iR);
% end
outputDataFile = [];
if s.saveOutput
    outputDataFile = fullfile(s.outDir,[s.outputName,'_types_all']);
    fprintf('Saving data file to %s\n',outputDataFile)
    save(outputDataFile,'inputSet','nodeSet','NMIList','bokVal','bokIdx','f',...
        'p','s','nList','ka','naiItr','isolatedSet','compositeData','Tfinal',...
        'specNorm','dTTmatNorm','iciModes','diffNormSpec','cRateNorm','fileNumExpand',...
        'bestWNodeDeg','prunedNodeSet','tIntMat','subOrder','binIdx','inFileList',...
        'clickTimes','labelStr','TPWSList')
    for iType = 1:size(Tfinal,1)
        thisType = [];
        outputTypeFile = fullfile(s.outDir,[s.outputName,'_type',num2str(iType)]);
        fprintf('Saving type file to %s\n',outputTypeFile)
        thisType.Tfinal = Tfinal(iType,:);
        % [~,~,bin2Nodes] = intersect(thisType.Tfinal{1,7},tIntMat,'stable');
        thisType.tIntMat = tIntMat(Tfinal{iType,8});
        thisType.clickTimes = clickTimes(Tfinal{iType,8});
        thisType.fileNumExpand = fileNumExpand(Tfinal{iType,8});
        if ~exist('TPWSList','var')
            TPWSList = [];
        end
        save(outputTypeFile,'thisType','inFileList','TPWSList')
    end
end

ccOutput.outputDataFile = outputDataFile;
ccOutput.p = p;
ccOutput.s = s;
ccOutput.f = f;
ccOutput.nodeSet = nodeSet;
ccOutput.compositeData = compositeData;
ccOutput.Tfinal = Tfinal;
ccOutput.tIntMat = tIntMat;
ccOutput.clickTimes = clickTimes;
ccOutput.fileNumExpand = fileNumExpand;
ccOutput.labelStr = labelStr;
ccOutput.inFileList = inFileList;
ccOutput.TPWSList = TPWSList;
ccOutput.partitions = naiItr;
if s.diary
    diary('off')
end
