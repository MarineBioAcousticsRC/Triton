function [thisSetMSP] = nn_fn_getSpectra_bin(clusterSpectra,clusterIdxThisSet,binIndices)
global REMORA
thisSetMSP = clusterSpectra(clusterIdxThisSet(binIndices),:);
if REMORA.nn.train_test_set.addNoise
    % add white noise:
    padZeros = wgn(size(thisSetMSP,1),400,10);
    [specNoise,fNoise] = pwelch(padZeros',hann(400)',0,400,200000);
    specNoise = specNoise'*200/2;
    specNoise = 10.*log10(abs(specNoise(:,1:181) + 10.^(thisSetMSP./10)));
    thisSetMSP = max(specNoise./max(specNoise,[],2),0);
    % figure(101);imagesc(specNoise');set(gca,'yDir','normal')
end