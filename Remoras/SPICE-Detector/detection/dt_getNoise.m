function noiseTimes = dt_getNoise(candidatesRel,stop,p,hdr)
% Get noise

maxClickSamples = ceil(hdr.fs  /1e6 * p.maxClick_us);
noiseTimes = [];
candidatesRelwEnds = [1,candidatesRel,stop];
dCR = diff(candidatesRelwEnds);
[mC,mI] = max(dCR);
% look for a stretch of data that has no detections
if mC > 2 * maxClickSamples
    noiseStart = candidatesRelwEnds(mI)+maxClickSamples;
    noiseTimes = [noiseStart, noiseStart+maxClickSamples];
end