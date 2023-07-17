function [mergeNodeID,uMergeNodeID,countsMergeNodeID] = ct_merge_nodes(distClickEFull,tempN,specClickTf_norm_short)
plotOn = 0; % make true for plots
% initialize categories
mergeNodeID = 1:tempN;
mergeNodeID = mergeNodeID';
for iNode = 1:length(mergeNodeID)
    % find the next signal that looks like this one
    newNum = find(distClickEFull(iNode,iNode:end)>.999,1,'first');
    if ~isempty(newNum)
        % if there's a very close match, re-number the current node to that
        % new index.
        mergeNodeID(iNode) = newNum+iNode-1;
        % update any other nodes with this label too.
        associatedIDs = mergeNodeID(1:iNode) == iNode;
        mergeNodeID(associatedIDs) = newNum+iNode-1;
        % plot(clusterID,'*')
        % 1;
    end
end
if plotOn
    figure(22);
    subplot(1,2,1)
    histogram(reshape(distClickEFull,tempN^2,1),0:.01:1)
    subplot(1,2,2)
    [~,IX] = sort(mergeNodeID);
    imagesc(flipud(specClickTf_norm_short(IX,:)'))
    1;
end
uMergeNodeID = unique(mergeNodeID);
countsMergeNodeID = histc(mergeNodeID,uMergeNodeID);


fprintf('Merged %0.0f nodes down to %0.0f nodes\n',tempN,...
    length(uMergeNodeID(~isnan(uMergeNodeID))));
