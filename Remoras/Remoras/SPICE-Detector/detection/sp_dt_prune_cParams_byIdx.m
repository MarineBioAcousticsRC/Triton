function cParams = sp_dt_prune_cParams_byIdx(cParams,keepIdx)
% save a mat file now, rather than recalculating later
cParams.clickTimes = cParams.clickTimes(keepIdx,:);
cParams.ppSignalVec = cParams.ppSignalVec(keepIdx,:);
cParams.snrVec = cParams.snrVec(keepIdx,:);
cParams.durClickVec = cParams.durClickVec(keepIdx,:);
cParams.bw3dbVec = cParams.bw3dbVec(keepIdx,:);

cParams.specClickTfVec = cParams.specClickTfVec(keepIdx,:);

cParams.peakFrVec = cParams.peakFrVec(keepIdx,:);
cParams.deltaEnvVec = cParams.deltaEnvVec(keepIdx,:);
cParams.nDurVec = cParams.nDurVec(keepIdx,:);

if ~isempty(keepIdx)
    cParams.yFiltVec = cParams.yFiltVec(keepIdx);
    cParams.yFiltBuffVec = cParams.yFiltBuffVec(keepIdx);
    
else
    cParams.yFiltVec = {};
    cParams.yFiltBuffVec = {};
end
