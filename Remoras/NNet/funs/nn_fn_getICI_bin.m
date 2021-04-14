function [thisSetICI] = nn_fn_getICI_bin(clusterICI,clusterIdxThisSet,binIndices)
global REMORA

thisSetICI = clusterICI(clusterIdxThisSet(binIndices),:);
if REMORA.nn.train_test_set.addNoise
    ICIlength = size(thisSetICI,2);
    myDistr = cumsum(mean(thisSetICI));
    r = rand(size(thisSetICI,1),100)*max(myDistr);p = @(r) find(r<myDistr,1,'first');
    rR = arrayfun(p,r);[C,~] = histc(rR,1:ICIlength,2);
    
    %MAZ modification- add noise ONLY to repeated values (i.e. only when
    %need to augment data, and not otherwise)
    [~,uniqueIdx,~] = unique(thisSetICI,'rows','stable');
    dupsIdx = find(~ismember(1:size(thisSetICI,1),uniqueIdx));
    thisSetICI(dupsIdx,:) = thisSetICI(dupsIdx,:) + C(dupsIdx,:)./100;
    
    disp(['Augmenting ',num2str(size(dupsIdx,2)),' repeated bins with noise'])
    
 
    %thisSetICI = thisSetICI +C/100;
    %thisSetICI = thisSetICI./max(thisSetICI,[],2);
end