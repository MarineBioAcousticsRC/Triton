function [spectraMean,clickAssign,clustSizes,spectraHolder,isolatedAll,envDurDistrib,envSetHolder,envMean] = ...
    ct_cluster_clicks_cw_merge(specClickTf,p,normalizeTF,envDur,envSet)

spectraMean = [];
envMean = [];
clickAssign = [];
clustSizes = 0;
spectraHolder = [];
isolatedAll = [];
envDurDistrib = [];
envSetHolder = [];

if ~p.useSpectra && p.useSpectra
    error('Either ''Cluster on Spectra'', or ''Cluster on Waveform'', or both must be true.')
end

if normalizeTF 
    [specClickTfNorm,specClickTfNormDiff] = ct_normalize_click_spectra(specClickTf,p);
else
    if p.linearTF
        specClickTfNorm = 10.^((specClickTf+1)./20);
    else
        specClickTfNorm = specClickTf;
    end
    if p.diff; specClickTfNormDiff = diff(specClickTfNorm,1,2); end
end
tempN = size(specClickTf,1);

distClickE = ones(1,(tempN*(tempN-1)/2));
if p.useSpectra && p.diff
    distClickE = ct_compute_node_dist(specClickTfNormDiff(:,...
        p.startFreqIdx:p.endFreqIdx-1),p.wcorTF);
elseif p.useSpectra 
    distClickE = ct_compute_node_dist(specClickTfNorm(:,p.startFreqIdx:p.endFreqIdx),p.wcorTF);
end

if p.mergeTF && tempN>p.mergeThresh  % determine whether to merge or not.
    mergeTF = 1;
else
    mergeTF = 0;
end

% find distance between all nodes
if p.useEnvelope
    if p.normalizeTF
        distEnv = ct_compute_node_dist(envSet./max(envSet,[],2),p.wcorTF);
    else
        distEnv = ct_compute_node_dist(envSet,p.wcorTF);
    end
    % [distEnv,~,~,~] = ct_ici_dist_mode(envDur',p.maxDur);
    distClickE = distClickE.*distEnv;
end

% prune out weak linkages
if p.variableThreshold
    % fluctuating threshold
    if mergeTF	
        thrP = prctile(distClickE(distClickE<.99),p.pruneThr);
    else
        thrP = prctile(distClickE,p.pruneThr);
    end
    fprintf('Variable pruning threshold value = %0.2f\n',thrP)
else %static threshold
    thrP = p.pruneThr/100;
end
%distClickE = max((distClickE-thrP)./(1-thrP),0);
distClickE(distClickE<thrP) = 0; 



distClickEFull = squareform(distClickE);

% for iR = 1:tempN
%     thisRowMax = max(distClickEFull(iR,min(iR+1,tempN):end));
%     tooLow = (distClickEFull(iR,:)<thrP & distClickEFull(iR,:)<thisRowMax);
%     distClickEFull(iR,tooLow) = 0;
% end

if mergeTF
    [mergeNodeID,uMergeNodeID,~] = ct_merge_nodes(distClickEFull,...
        tempN,specClickTfNorm(:,p.startFreqIdx:p.endFreqIdx));
end

connectedList = nansum(distClickEFull)>0; % isolated nodes have NAN
nodesRemaining = sum(connectedList);
fprintf('%.0f (%.2f%%) of %.0f components are isolated\n', ...
    tempN-nodesRemaining, 100*((tempN-nodesRemaining)/tempN),tempN)

if nodesRemaining < p.minClust
    fprintf('Too few nodes remaining after pruning, skipping iteration \n')
    return % if there aren't nodes/edges left, skip iteration
end


% Begin CW loops
% initialize categories
clusterID = 1:tempN;
clusterID = clusterID';
if mergeTF
    clusterID(~ismember(clusterID,uMergeNodeID)) = NaN;
end
clusterID(isnan(connectedList)) = NaN;
clusterID = ct_run_CW_cluster(clusterID,distClickEFull,p);


if mergeTF
    % unwind node merge by assigning nodes that were merged to the category of
    % their parent.
    for iMerge = 1:length(uMergeNodeID)
        thisID = uMergeNodeID(iMerge);
        nodeClusterID = clusterID(thisID);
        clusterID(mergeNodeID == thisID) = nodeClusterID;
    end
end
uniqueLabels = unique(clusterID(~isnan(clusterID)));
clusterIDNew = zeros(size(clusterID));
% rescale cluster numbers to start at 1 and increment by 1
clusterCounter = 1;
for iUL = 1:length(uniqueLabels)
    thisULabel = uniqueLabels(iUL);
    hasThisLabel = (clusterID==thisULabel) ;
    if sum(hasThisLabel)>= p.minClust
        clusterIDNew(hasThisLabel) = clusterCounter;
        clusterCounter = clusterCounter+1;
    else
        clusterIDNew(hasThisLabel) = NaN;
    end
end

uniqueLabelsNew = unique(clusterIDNew(~isnan(clusterIDNew)));
clustBins = 0:max(clusterIDNew);
clustSizes = histc(clusterIDNew,clustBins);
spectraMean = [];
spectraHolder = {};
clickAssign = {};

% Organize output into cell arrays by clusters
if ~isempty(uniqueLabelsNew)
    for i4 = 1:length(uniqueLabelsNew)
        
        thisClickSet = find(clusterIDNew==uniqueLabelsNew(i4));
        if 1
            thisNConnectionsSet = sum(distClickEFull>0);
            gt1Idx = thisNConnectionsSet(thisClickSet)>1;
            thisClickSet = thisClickSet(gt1Idx);
        end
        thisSpectralSet = specClickTf(thisClickSet,:);
        thisEnvDurSet = envDur(thisClickSet,:);

        envDurDistrib(i4,:) = histc(thisEnvDurSet,1:p.maxDur);
        
        if ~p.linearTF
            linearSpec = 10.^((thisSpectralSet+1)./20);
            meanSpectra = 20*log10(mean(linearSpec,1));
        else
            meanSpectra = mean(thisSpectralSet,1);
        end
        
        %linearSpecMean = mean(specClickTf(clusterIDNew==uniqueLabelsNew(i4),:));
        if p.normalizeTF
            spectraMean(i4,:) = (meanSpectra-min(meanSpectra(:,p.startFreqIdx:p.endFreqIdx)))...
                ./max(meanSpectra(:,p.startFreqIdx:p.endFreqIdx)-min(meanSpectra(:,p.startFreqIdx:p.endFreqIdx)));
            envMean(i4,:) = mean(envSet(thisClickSet,:)./max(envSet(thisClickSet,:),[],2),1);
            
        else
            spectraMean(i4,:) = meanSpectra;
            envMean(i4,:) = mean(envSet(thisClickSet,:));
            

        end
        % spectraStd(i4,:) = std(specClickTf_norm(nodeNums(clusters==clustNums(i4)),:));
        clickAssign{i4} = thisClickSet;
        spectraHolder{i4} = specClickTf(thisClickSet,:);
        envSetHolder{i4} = envSet(thisClickSet,:);
        % imagesc(specClickTf_norm(clickAssign{i4},p.stIdx:p.edIdx)');set(gca,'ydir','normal')
    end
end
% 
isolatedAll = setdiff(1:size(specClickTf,1),find(~isnan(clusterIDNew)));
