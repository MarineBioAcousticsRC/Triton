function ct_cluster_TPWS(thisFile,fdAll,p,outDir)

global f fkeep HANDLES

p.tritonMsg = 0;
if isfield(HANDLES,'msg')
    p.tritonMsg = 1; % if the field exists, then we have access to triton messaging.
end
% Things to make set-able someday
%p.normalizeTF = 1; % flag to turn on click normalization
p.mergeThresh = 300; % arbitrary threshold above which node merging is attempted 
% if merging is desired. Node merging is a strategy for clustering large 
% networks more quickly, but it comes with a cost, so you shouldn't just
% do it for all network sizes.
p.wcorTF = 0; % flag for weighted correlation. 
% Weighted option lets you give more weight to similarities at some
% frequencies than others.
% Also should think about alternatives for merging distances from envelope
% and spectra, 
% Also need option to use env duration rather than envelope shape.

% initialize data structure
binData = struct(...
	'sumSpec',{}, 'nSpec',{}, 'percSpec',{},...
	'cInt',[], 'tInt',[], 'dTT',{},...
	'clickRate',{},'clickTimes', {},'nIsolated', {},...
    'clusteredTF',[], 'clickClusterIds', {}, 'clickSubset',{});

MTT = [];
MPP = [];
MSP = [];
f = [];

load(thisFile,'MPP','MTT','MSP','MSN','f')
zeroRowsMSN = find(sum(abs(MSN),2)==0);
MSN(zeroRowsMSN,:) = [];

if size(MSP,1) ~= size(MSN,1)
    
    % if these don't have the same vertical dimension, but they are
    % the same in the horizontal, assume they are
    % oriented wrongly (columns represent individual detections instead of
    % rows representing detections) and flip them.
    if size(MSP,2) == size(MSN,2)
        MSP = MSP';
        MSN = MSN';
    else
        
        error('Error: MSP and MSN don''t have the same dimensions. Each detection should be on one row.')
    end
end
    
if ~isempty(f)
    fkeep = f;
elseif isempty(f) && ~isempty(fkeep)
    f = fkeep;
elseif isfield(p,'sampleRate')
    warning(['Warning: Missing frequency vector in input file. ',...
         'Estimating using sample rate and some possibly incorrect assumptions.'])
    sizeMSP2 = size(MSP,2);% this is dangerous, MSP could be flipped.
    
    f = ((p.sampleRate/2)/(sizeMSP2-1))*(1:sizeMSP2) -(p.sampleRate/2)/(sizeMSP2-1);
else
    error(['Error: No frequency vector in input file, and no sample rate in parameters.',... 
      'Please add f to TPWS or add sampleRate to settings file.'])
end

% Turn specified frequencies into indices
[~,p.startFreqIdx] = min(abs(f-p.startFreq));
[~,p.endFreqIdx] = min(abs(f-p.endFreq));

% make output file name that incorporates settings:
[~,fName,fExt] = fileparts(thisFile);
fNameExt = strcat(fName,fExt);
if p.diff
    fnameNewEnding = sprintf('clusters_diff_PR%.0f_PPmin%.0f',...
        p.pruneThr,p.ppThresh);
else
    fnameNewEnding = sprintf('clusters_PR%.0f_PPmin%.0f',...
        p.pruneThr,p.ppThresh);
end

outName = strrep(fNameExt,['TPWS',p.TPWSitr],fnameNewEnding);

% remove false positive clicks
[~, keepIdx] = setdiff(MTT,fdAll);
MTT = MTT(keepIdx);
MSP = MSP(keepIdx,:);
MSN = MSN(keepIdx,:);
MPP = MPP(keepIdx);
fprintf('%0.0f clicks left after removing false positives.\n',length(MTT))

% remove low amplitude clicks
ppKeep = MPP>=p.ppThresh;
MSP = MSP(ppKeep,:);
clear('MPP','fdAll') % don't need anymore.
MTT = MTT(ppKeep);
MSN = MSN(ppKeep,:);
fprintf('%0.0f clicks left after applying amplitude threshold.\n',length(MTT))
if isempty(MTT)
    warning('All clicks pruned out by amplitude threshold, nothing left to cluster.')
end

% Remove clicks that are really close together if desired.
if p.minCueGap>0
    dMTT = diff(MTT);
    gapCues = dMTT >= (p.minCueGap/(24*60*60));
    gapCues = [1;gapCues]; 
    MTT = MTT(gapCues>0);
    MSP = MSP(gapCues>0,:);
    MSN = MSN(gapCues>0,:);
    fprintf('%0.0f clicks left after applying minimum gap.\n',length(MTT))
    if isempty(MTT)
        warning('All clicks pruned out by cue gap threshold, nothing left to cluster.')
    end
end

if isempty(MTT) % go to next file if no clicks left in this one.
    warning('Continuing to next TPWS file')
    return
end

% Build vector of bin starts/ends.
if isinf(p.timeStep)
    dateInterval = [floor(MTT(1)), ceil(MTT(end))];
else
    dateInterval = floor(MTT(1)):datenum([0,0,0,0,p.timeStep,0]):ceil(MTT(end));
end
% Figure out which clicks are in which time bin.
[testN,testBin] = histc(MTT,dateInterval);

% Prune out bins with no clicks, and re-index to adjust remaining click to
% bin references.
binKeep = find(testN>0);
testBinNew = zeros(size(testBin));
for iBin = 1:length(binKeep)
    thisClickSet = testBin == binKeep(iBin);
    testBinNew(thisClickSet) = iBin;
end
testBin = testBinNew;
dateInterval = dateInterval(binKeep);
testN = testN(binKeep);

idxer = 1:length(testBin);

cIdx = 1;        
noCluster = 0;
% loop over bins
figCounter = 1;
for iC = 1:length(dateInterval)
    nClicks = testN(iC); % store number of clicks in interval
    idSet = idxer(testBin == iC);
    specSet = MSP(idSet,:);
    ttSet = MTT(idSet);
    envSet = abs(hilbert(MSN(idSet,:)'))';
    if 1
        envSet = ct_align_env(envSet);
    end
    envDur = sum(envSet>median(median(envSet)*5),2);
    p.maxDur = size(envSet,2);
    
    
    if nClicks >=  p.minClust
        if nClicks > p.maxNetworkSz        
            % if the interval contains more than p.maxNetworkSz good clicks, 
            % randomly select a subset for clustering
            fprintf('%d clicks in bin, selecting subset of %d\n',nClicks,p.maxNetworkSz)
            rList = sort(randperm(nClicks,p.maxNetworkSz));
        else
            rList = 1:nClicks;
        end
        specSet = specSet(rList,:);
        ttSet = ttSet(rList);
        envDur = envDur(rList,:);
        envSet = envSet(rList,:);
        % Cluster
        [spectraMean,clickAssign,~,specHolder,isolatedSet,envDistrib,envSetHolder,envMean] = ...
            ct_cluster_clicks_cw_merge(specSet,p,p.normalizeTF,envDur,envSet);
        
        % If you finish clustering with populated cluster(s)
        if ~isempty(clickAssign)
            % Calculate mean spectra, click rates, and interclick-intervals
            sizeCA = zeros(size(clickAssign));
            dtt = zeros(size(clickAssign,2),length(p.barInt));
            cRate = zeros(size(clickAssign,2),length(p.barRate));
            % meanSim = zeros(size(clickAssign));
            clickTimesByCluster = {};
            for iS = 1:size(clickAssign,2)
                sizeCA(1,iS) = size(clickAssign{iS},1);
                [dtt(iS,:),cRate(iS,:)] = ct_compute_rate_distributions(ttSet(clickAssign{iS}),p);
                clickTimesByCluster{1,iS} = ttSet(clickAssign{iS});
                
                % temporay calculation of within cluster similarity.
                % distClickTemp = pdist(specHolder{iS},'correlation');
                % meanSim(1,iS) = mean(exp(-distClickTemp));
            end
            binData(cIdx,1).clickClusterIds = clickAssign; % store index of clicks assigned to each cluster
            % WARNING: if data were subsetted, this clickClusterIds
            % is relative to the permuted subset rList in clickSubset
            binData(cIdx,1).clickSubset = rList;% store indices of the clicks that were clustered.
            binData(cIdx,1).nIsolated = isolatedSet; % store indices of clicks isolated from clusters
            binData(cIdx,1).sumSpec = spectraMean; % store summary spectra
            binData(cIdx,1).nSpec = sizeCA; % store # of clicks associated with each summary spec
            binData(cIdx,1).percSpec = sizeCA./size(specSet,1); % store % of clicks associated with each summary spec
            binData(cIdx,1).cInt = nClicks; % store number of clicks in interval
            binData(cIdx,1).tInt = [dateInterval(iC),dateInterval(iC)+(p.timeStep/(24*60))]; % store start and end time of interval
            binData(cIdx,1).dTT = dtt; % store ici distribution
            binData(cIdx,1).clickRate = cRate;% store click rate distribution
            binData(cIdx,1).clusteredTF = 1; % 1 means this bin was clustered
            binData(cIdx,1).clickTimes = clickTimesByCluster;
            binData(cIdx,1).envDur = envDistrib;
            binData(cIdx,1).envMean = envMean;
            cIdx = cIdx +1;
            % meanSimilarity{cIdx,:} = meanSim;
            
            if p.plotFlag 
                % figure(111);imagesc(specSet(isolatedSet,:));set(gca,'ydir','normal')
                % plotting option
                ct_plot_bin_clusters(p,f,spectraMean,envDistrib,thisFile,dtt,...
                    specHolder,envSetHolder,sizeCA,iC,length(dateInterval),figCounter) 
                figCounter = figCounter+1;
            end
        else
            noCluster = 1;
            fprintf('No clusters >= %0.0f formed in this bin.\n',p.minClust)
        end
    elseif nClicks>0
        noCluster = 1;
        fprintf('Too few clicks to cluster (%0.0f)\n',nClicks)
    end
    
    if noCluster 
        % noCluster happens if there are not enough clicks to cluster
        % OR if no large clusters were formed.
        
        binData(cIdx,1).nIsolated = NaN; % nothing isolated in no cluster case
        binData(cIdx,1).clickSubset =  1:nClicks; % all clicks are passed into this subset since no cluster
        binData(cIdx,1).clickClusterIds = {1:nClicks}; % all clicks are considered to be in cluster 1
        binData(cIdx,1).sumSpec = ct_calc_norm_spec_mean(specSet,p);%(:,p.startFreqIdx:p.endFreqIdx)); % store summary spectra
        binData(cIdx,1).nSpec = nClicks; % store # of clicks associated with each summary spec
        binData(cIdx,1).percSpec = 1; % store % of clicks associated with each summary spec
        binData(cIdx,1).cInt = nClicks; % store number of clicks in interval
        binData(cIdx,1).tInt = [dateInterval(iC),dateInterval(iC)+(p.timeStep/(24*60))]; % store start and end time of interval
        binData(cIdx,1).clickTimes = {ttSet}; % store click times.
        binData(cIdx,1).clusteredTF = 0;
        binData(cIdx,1).envDur = envDur;
        if size(envSet,1)>1
            binData(cIdx,1).envMean = mean(envSet);%./max(envSet,[],2));
        elseif size(envSet,1)==1
            binData(cIdx,1).envMean = envSet;%./max(envSet,[],2);
        end
        [binData(cIdx,1).dTT,binData(cIdx,1).clickRate] = ct_compute_rate_distributions(ttSet,p);
        
        cIdx = cIdx +1;
        noCluster = 0;
    end
    if mod(iC,200) == 0
        fprintf('done with bin # %d of %d, file %s\n',iC-1,...
            length(dateInterval),thisFile)
    end
end
TPWSfilename = fNameExt;
% save output
save(fullfile(outDir,outName),'TPWSfilename','binData','p','f')

