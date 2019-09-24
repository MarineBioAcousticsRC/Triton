function cParams = sp_dt_prune_cParams(cParams,sIdx)

eIdx = sIdx-1;
% prune off any extra cells that weren't filled
cParams.clickTimes = cParams.clickTimes(1:eIdx,:);
cParams.ppSignalVec = cParams.ppSignalVec(1:eIdx,:);
cParams.durClickVec = cParams.durClickVec(1:eIdx,:);
cParams.bw3dbVec = cParams.bw3dbVec(1:eIdx,:);
cParams.yFiltVec = cParams.yFiltVec(1:eIdx,:);
cParams.specClickTfVec = cParams.specClickTfVec(1:eIdx,:);
cParams.peakFrVec = cParams.peakFrVec(1:eIdx,:);
cParams.yFiltBuffVec = cParams.yFiltBuffVec(1:eIdx,:);
cParams.deltaEnvVec = cParams.deltaEnvVec(1:eIdx,:);
cParams.nDurVec = cParams.nDurVec(1:eIdx,:);
cParams.snr = cParams.snrVec(1:eIdx,:);