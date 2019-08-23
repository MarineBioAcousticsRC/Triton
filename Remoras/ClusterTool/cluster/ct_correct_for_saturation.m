function iciModeIdx = ct_correct_for_saturation(p,maxICI,dTTmatNorm,iciModeIdx)

lowMin = find(p.barInt<.03,1,'last');
saturatedSet = find(iciModeIdx <= lowMin);

for iSat = 1:length(saturatedSet)
    thisDTTsmoothDiff = diff(dTTmatNorm(saturatedSet(iSat),1:maxICI));
    minIdx = find(thisDTTsmoothDiff(2:end)>0, 1,'first')+1;
    if isempty(minIdx)
        minIdx = 1;
    end
    trucatedICIDist = dTTmatNorm(saturatedSet(iSat),minIdx:maxICI);
    trucatedICIDistNorm = trucatedICIDist/max(trucatedICIDist);
    
    [mVal,mTemp] = max(trucatedICIDistNorm,[],2);
    
    % compute rough peak prominence metric
    if mTemp>1 && mTemp<length(trucatedICIDistNorm)
        peakProm = mVal-((trucatedICIDistNorm(mTemp-1)+...
            trucatedICIDistNorm(mTemp+1))/2);
    elseif mTemp == 1
        peakProm = mVal-(trucatedICIDistNorm(mTemp+1)/2);
    elseif mTemp == length(trucatedICIDistNorm)
        peakProm = mVal-(trucatedICIDistNorm(mTemp-1)/2);
    end
    if peakProm>.2 && sum(trucatedICIDist)>.5% don't adjust unless the peak is strong enough
        iciModeIdx(saturatedSet(iSat)) = minIdx+mTemp-1;
    end
    % figure(1);clf;
    % plot(iciModeIdx(saturatedSet(iSat)),mVal,'*');
    % hold on;plot(dTTmatNorm(saturatedSet(iSat),:));plot([0,40],[0,0],'r');
    % plot(thisDTTsmoothDiff,'g');hold off
end