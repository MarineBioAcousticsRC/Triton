function [thisSetICI] = nn_fn_getICI_bin(clusterICI,clusterIdxThisSet,binIndices)
global REMORA

thisSetICI = clusterICI(clusterIdxThisSet(binIndices),:);
if REMORA.nn.train_test_set.addNoise
    myDistr = cumsum(mean(thisSetICI));
    r = rand(size(thisSetICI,1),100)*max(myDistr);p = @(r) find(r<myDistr,1,'first');
    rR = arrayfun(p,r);[C,~] = histc(rR,1:101,2);
    thisSetICI = thisSetICI +C/100;
    thisSetICI = thisSetICI./max(thisSetICI,[],2);
end