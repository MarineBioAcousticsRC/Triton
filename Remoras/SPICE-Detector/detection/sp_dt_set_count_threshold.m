function p = sp_dt_set_count_threshold(p)

if ~p.whiten
    [~,minxfrIdx] = min(abs(p.xfr_f-p.bpRanges(1)));
    [~,maxxfrIdx] = min(abs(p.xfr_f-p.bpRanges(2)));
    
    p.countThresh = (10^((p.dBppThreshold -...
        median(p.xfrOffset(minxfrIdx:maxxfrIdx)))/20))/2;
else
    p.countThresh = (10^((p.dBppThreshold -...
        p.meanxfrOffset)/20))/2;
end