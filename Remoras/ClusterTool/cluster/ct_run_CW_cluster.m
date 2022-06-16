function clusterID = ct_run_CW_cluster(clusterID,distClickEFull,p)
% for iRow = 1:length(uMergeNodeID)
%     distClickEFull(:,iRow) = distClickEFull(:,iRow).*...
%      countsMergeNodeID(iRow);
% end
% Begin CW loops
% Biemann, C. (2006). Chinese Whispers - An Efficient Graph Clustering 
% Algorithm And Its Application To Natural Language Processing Problems.
list2cluster = clusterID(~isnan(clusterID));
distClickEIdx = 1:size(distClickEFull,1);
noChange = 0;
cwItr = 1;

% itrMax = 10;

while ~noChange && (cwItr<=p.maxCWiterations)
    rOrder = randperm(length(list2cluster));% randomize order
    noChange = 1; % set no change flag to 1, it will be flipped to 0 as soon as a change is made    
   
    for iNode = 1:length(list2cluster)    
        thisNode = list2cluster(rOrder(iNode));
        
        % which nodes are connected to this one?
        linkedNodes = distClickEIdx(distClickEFull(thisNode,:)>0);        
        linkedNodeLables = clusterID(linkedNodes);
        % what categories do those nodes fall into?
        uniqueLinkedNodeLabels = unique(linkedNodeLables(~isnan(linkedNodeLables)));
        categoryWeight = nan(size(uniqueLinkedNodeLabels));
        for iUNodes = 1:length(uniqueLinkedNodeLabels)
            thisCategory = uniqueLinkedNodeLabels(iUNodes);
            nodesInCategory = linkedNodeLables == thisCategory;
            vec2sum = distClickEFull(thisNode,...
                linkedNodes(nodesInCategory));
            categoryWeight(iUNodes) = sum(vec2sum(~isnan(vec2sum)));
        end
            
        [~,newIdx] = max(categoryWeight(~isnan(categoryWeight)));
        newLabel = uniqueLinkedNodeLabels(newIdx);
        if newLabel ~= clusterID(thisNode)
            clusterID(thisNode) = newLabel;
            noChange = 0;
        end
    end
    fprintf('Done with clustering iteration %0.0f\n',cwItr);
    cwItr = cwItr + 1;
  
end
if p.plotFlag && size(distClickEFull,1)<3000
     figure(110);clf
    cList = colormap(110,lines);
    % G = graph(squareform(distClickE));
    figure(110)
    G = graph(distClickEFull,'upper');
    h = plot(G,'layout','force');
    uID = unique(clusterID);
    h.EdgeColor = [.9,.9,.9];
    for iC=1:size(uID,1)
        highlight(h, clusterID==uID(iC),'nodeColor',cList(mod(uID(iC),64)+1,:))
    end
else
    disp('Too many nodes for network plotting')
end
fprintf('%0.0f iterations required\n',cwItr-1);
colormap(jet)