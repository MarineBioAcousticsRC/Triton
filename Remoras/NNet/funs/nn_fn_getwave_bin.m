function [thisSetWave] = nn_fn_getwave_bin(clusterWave,clusterIdxThisSet,binIndices)

global REMORA
thisSetWave = clusterWave(clusterIdxThisSet(binIndices),:);
if REMORA.nn.train_test_set.addNoise
    waveNoise = wgn(size(thisSetWave,1),200,1)/100;
    thisSetWave = thisSetWave + abs(waveNoise);
    thisSetWave = thisSetWave./max(thisSetWave,[],2);
end