function [c_stopsM ,c_startsM] = sp_dt_mergeCandidates(mergeThr,stops,starts)

% merge candidates that are too close together so they will be considered
% to be one larger detection
c_startsM(1) = starts(1);
c_stopsM = [];
iT1 = 1;
startCtr = 2;
stopCtr = 1;
while iT1 <= length(starts)
    k = 0;
    mergeI = iT1;
    while (k+iT1)<(length(starts)) && starts(iT1+k+1,1) - stops(iT1+k,1)<= mergeThr    
        k = k+1;
        mergeI = [mergeI,iT1+k];
    end
    if(k+iT1)==(length(starts))
         c_stopsM(stopCtr,1) = max(stops(mergeI));
         break
    else
        c_startsM(startCtr,1) = starts(iT1+k+1,1);
        c_stopsM(stopCtr,1) = stops(iT1+k);
        iT1 = iT1+1+k;
        startCtr = startCtr + 1;
        stopCtr = stopCtr + 1;
        k = 0;
    end
end