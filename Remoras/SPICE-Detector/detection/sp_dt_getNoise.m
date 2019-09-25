function noiseTimes = sp_dt_getNoise(candidatesRel,dataLen,p,hdr)
% Get noise

maxClickSamples = p.delphClickDurLims(2);
noiseTimes = [];
candidatesRelwEnds = [1,candidatesRel,dataLen];
dCR = diff(candidatesRelwEnds);
[mC,mI] = max(dCR);
% look for a stretch of data that has no detections
if dataLen - (candidatesRelwEnds(mI)+maxClickSamples/2) > maxClickSamples
    noiseStart = floor(candidatesRelwEnds(mI)+maxClickSamples/2);
    noiseTimes = [noiseStart, noiseStart+maxClickSamples];
end
