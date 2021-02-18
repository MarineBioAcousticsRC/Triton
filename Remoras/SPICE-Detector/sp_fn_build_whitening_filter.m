function p = sp_fn_build_whitening_filter(p,hdr)

%% TO DO: Make version of TF for filtering that starts at 0kHz

p = sp_fn_interp_tf_whiten(p,hdr.fs);

p.meanxfrOffset = mean(p.xfrOffset_whiten);
xFrRel = (p.xfrOffset_whiten-p.meanxfrOffset);
xFrRelLin = 10.^(xFrRel/20);
[~,minxfrIdx] = min(abs(p.xfr_f-p.bpRanges(1)));
xFrRelLin(1:minxfrIdx) = 0;
Nb = 40;
Na = 40;
try
    d = fdesign.arbmag('Nb,Na,F,A',Nb,Na,p.xfr_f_whiten,xFrRelLin,hdr.fs); % single-band design
    p.Hd1 = design(d,'iirlpnorm','SystemObject',true);
catch
    error('whitening failed in this version of matlab')
end