function nn_compute_neighbor_metrics_TPWS(inFile)%trainMSN,trainMSP,trainTimes)

if sum(contains(who('-file',inFile),'neighborMetrics')>0)
     return
end
load(inFile,'MSN','MSP','MTT')

%%
    
nClicks = size(MSN,1);
localWin = 50;
% set ranges from which to compute histogram bins
ICIint = 0:0.01:1;
ampInt = 1:100:10000;
peakfrIdxInt= 0:2:size(MSP,2);
day2sec = 24*60*60;

% preallocate
trainICINeighbor = zeros(nClicks,length(ICIint));
trainMaxAmpNeighbor =  zeros(nClicks,length(ampInt));
trainPeakFrnNeighbor = zeros(nClicks,length(peakfrIdxInt));
for iC = 1:nClicks
    neighborIdx = max(1,iC-localWin):min(nClicks,iC+localWin);
    trainICINeighbor(iC,:) = histc(diff(MTT(neighborIdx))*day2sec,ICIint)';
    trainMaxAmpNeighbor(iC,:) = histc(max(MSN(neighborIdx,:),[],2),ampInt)';
    [C,IX] = max(MSP(neighborIdx,:),[],2);
    trainPeakFrnNeighbor(iC,:) = histc(IX,peakfrIdxInt)';

end
neighborMetrics = struct;
neighborMetrics.trainICINeighbor = trainICINeighbor;
neighborMetrics.trainMaxAmpNeighbor = trainMaxAmpNeighbor;
neighborMetrics.trainPeakFrnNeighbor = trainPeakFrnNeighbor;
neighborMetrics.ICIint = ICIint;
neighborMetrics.ampInt = ampInt;
neighborMetrics.peakfrIdxInt = peakfrIdxInt;
neighborMetrics.localWin = localWin;

save(inFile,'neighborMetrics',"-append")
