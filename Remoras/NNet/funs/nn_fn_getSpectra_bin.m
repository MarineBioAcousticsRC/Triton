function [thisSetMSP,naugBins] = nn_fn_getSpectra_bin(clusterSpectra,clusterIdxThisSet,binIndices)
global REMORA

thisSetMSP = clusterSpectra(clusterIdxThisSet(binIndices),:);
if REMORA.nn.train_test_set.addNoise
    % add white noise:
    padZeros = wgn(size(thisSetMSP,1),400,10);
    [specNoise,fNoise] = pwelch(padZeros',hann(400)',0,400,200000);
    specNoise = specNoise'*200/2;
    
        %MAZ modification- add noise ONLY to repeated values (i.e. only when
    %need to augment data, and not otherwise)
    [~,uniqueIdx,~] = unique(thisSetMSP,'rows','stable');
    dupsIdx = find(~ismember(1:size(thisSetMSP,1),uniqueIdx));
    
    specNoise = thisSetMSP;
    specNoise(dupsIdx,:) = 10.*log10(abs(specNoise(dupsIdx,1:181) + 10.^(thisSetMSP(dupsIdx,:)./10)));
    thisSetMSP = max(specNoise./max(specNoise,[],2),0);
    disp(['Augmenting ',num2str(size(dupsIdx,2)),' repeated bins with noise'])
    
    naugBins = num2str(size(dupsIdx,2));
    
else
    naugBins = 'no';
   
    
%         specNoise = 10.*log10(abs(specNoise(:,1:181) + 10.^(thisSetMSP./10)));
%     thisSetMSP = max(specNoise./max(specNoise,[],2),0);
    % figure(101);imagesc(specNoise');set(gca,'yDir','normal')
end
