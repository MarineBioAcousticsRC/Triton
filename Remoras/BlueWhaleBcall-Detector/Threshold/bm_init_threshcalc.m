function bm_init_threshcalc

global REMORA

tmin = REMORA.bm.settings.tmin;
tmax = REMORA.bm.settings.tmax;
stsize = REMORA.bm.settings.stsize;

thresh = tmin:stsize:tmax;

for t = 1:length(thresh)
    cthresh = thresh(t);
    REMORA.bm.settings.thresh = cthresh;
    bm_init_batch_detector;
end

bm_DetPickCompare
end