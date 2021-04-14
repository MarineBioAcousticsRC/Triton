function [thisSetWave] = nn_fn_getwave_bin(clusterWave,clusterIdxThisSet,binIndices)

global REMORA
thisSetWave = clusterWave(clusterIdxThisSet(binIndices),:);
if REMORA.nn.train_test_set.addNoise
    waveNoise = wgn(size(thisSetWave,1),200,1)/100;
    %MAZ modification- add noise ONLY to repeated values (i.e. only when
    %need to augment data, and not otherwise)
    [~,uniqueIdx,~] = unique(thisSetWave,'rows','stable');
    dupsIdx = find(~ismember(1:size(thisSetWave,1),uniqueIdx));
    thisSetWave(dupsIdx,:) = thisSetWave(dupsIdx,:) + abs(waveNoise(dupsIdx,:));
    disp(['Augmenting ',num2str(size(dupsIdx,2)),' repeated bins with noise'])
    %     thisSetWave = thisSetWave + abs(waveNoise);
    thisSetWave = thisSetWave./max(thisSetWave,[],2);
    
    
end