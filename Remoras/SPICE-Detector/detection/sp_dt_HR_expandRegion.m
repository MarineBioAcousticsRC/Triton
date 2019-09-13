function [c_starts,c_stops] = sp_dt_HR_expandRegion(p,hdr,sStarts,sStops,energy)
% Expand region to lower thresholds

N = length(energy);
c_starts = nan(length(sStarts),1);   % init complete clicks to single/partial clicks
c_stops = nan(length(sStarts),1);
k=1;

dataSmooth = sp_fn_fastSmooth(energy,15);

thresh = prctile(energy,p.energyPrctile);
for itr = 1:length(sStarts)
    rangeVec = sStarts(itr):sStops(itr);
    % make an envelope: TODO - try hilbert and first diff? While loops are
    % slow, but need to think of an alternative solution.
    [m, ~] = max(energy(rangeVec));
    
    % bpMean = mean(smoothEnergy([1:500,end-500:end]));
    % bpStd = std(dataSmooth([1:500,end-500:end]));
    % find the largest peak
    largePeakList = sort(find(energy(rangeVec) > .5*m));
    midx = rangeVec(largePeakList(1));
    
    leftmost = 5;
    % Repeat for complete clicks using running mean of smoothed energy
    leftIdx = max(midx - 1,leftmost);
    while (leftIdx > leftmost) && mean(dataSmooth(leftIdx-4:leftIdx) > thresh)~=0 % /2
        leftIdx = leftIdx - 1;
    end
    
    rightmost = N-5;
    rightIdx = midx+1;
    while rightIdx < rightmost && mean(dataSmooth(rightIdx:rightIdx+4) > thresh)~=0%+bpStd/2
        rightIdx = rightIdx+1;
    end
    c_starts(k,1) = leftIdx;
    c_stops(k,1) = rightIdx;
    % clf;plot(bpDataHi);hold on;plot(dataSmooth,'r');plot([c_starts,c_stops],zeros(size([c_starts,c_stops])),'*g');title(num2str(c_stops - c_starts));

    k = k+1;
    
end

if length(c_starts)>1
    [c_starts,IX] = sort(c_starts);
    c_stops = c_stops(IX);
    [c_stops,c_starts] = sp_dt_mergeCandidates(p.mergeThr,c_stops,c_starts);
    % clf;plot(bpDataHi);hold on;plot(dataSmooth,'r');plot([c_starts,c_stops],zeros(size([c_starts,c_stops])),'*g');title(num2str(c_stops - c_starts));

end
throwIdx = zeros(size(c_stops));
for k2 = 1:length(c_stops)
    % Discard short signals or those that run past end of signal
    if c_stops(k2) >= N-2 || c_stops(k2) - c_starts(k2) < p.delphClickDurLims(1) ||...
            c_stops(k2) - c_starts(k2) > p.delphClickDurLims(2)
        
        throwIdx(k2,1) = 1;
    end
end

c_starts(throwIdx==1) = [];
c_stops(throwIdx==1) = [];