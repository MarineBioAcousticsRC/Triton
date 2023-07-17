function [cParams,sIdx] = sp_dt_populate_cParams(clicks,noise,p,clickDets,starts,hdr,sIdx,cParams)

[clkStarts,clkEnds] = sp_dt_processValidClicks(clicks,clickDets,...
    starts,hdr);


eIdx = sIdx + size(clickDets.nDur,1)-1;
cParams.clickTimes(sIdx:eIdx,1:2) = [clkStarts,clkEnds];
cParams.ppSignalVec(sIdx:eIdx,1) = clickDets.ppSignal;
cParams.durClickVec(sIdx:eIdx,1) = clickDets.durClick;
cParams.bw3dbVec(sIdx:eIdx,:) = clickDets.bw3db;
cParams.yFiltVec(sIdx:eIdx,:)= clickDets.yFilt';
cParams.specClickTfVec(sIdx:eIdx,:) = clickDets.specClickTf;
cParams.peakFrVec(sIdx:eIdx,1) = clickDets.peakFr;
cParams.yFiltBuffVec(sIdx:eIdx,:) = clickDets.yFiltBuff';
cParams.deltaEnvVec(sIdx:eIdx,1) = clickDets.deltaEnv;
cParams.nDurVec(sIdx:eIdx,1) = clickDets.nDur;
cParams.snrVec(sIdx:eIdx,1) = clickDets.snr;
if p.saveNoise
    if ~isempty(clickDets.yNFilt{1})
        [noiseStarts,noiseEnds] = sp_dt_processNoiseTimes(noise,...
            starts,hdr);
        newNoiseTimes = [noiseStarts,noiseEnds];
        cParams.noiseTimes = [cParams.noiseTimes;newNoiseTimes];
        cParams.yNFiltVec = [cParams.yNFiltVec;clickDets.yNFilt];
        cParams.specNoiseTfVec = [cParams.specNoiseTfVec;...
            clickDets.specNoiseTf];
    end
end

sIdx = eIdx+1;
