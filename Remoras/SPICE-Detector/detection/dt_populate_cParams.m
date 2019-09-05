function [cParams,sIdx] = dt_populate_cParams(clicks,p,clickDets,starts,hdr,sIdx,cParams)

[clkStarts,clkEnds] = dt_processValidClicks(clicks,clickDets,...
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
        cParams.yNFiltVec = [cParams.yNFiltVec;clickDets.yNFilt];
        cParams.specNoiseTfVec = [cParams.specNoiseTfVec;...
            clickDets.specNoiseTf];
    end
end

sIdx = eIdx+1;
