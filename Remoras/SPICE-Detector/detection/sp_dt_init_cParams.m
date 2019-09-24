function cParams = sp_dt_init_cParams(p)
% Initialize vectors for main detector loop
cParams.clickTimes = nan(1E5,2);
cParams.ppSignalVec = nan(1E5,1);
cParams.durClickVec = nan(1E5,1);
cParams.bw3dbVec = nan(1E5,3);
cParams.specClickTfVec = nan(1E5,length(p.specRange));
cParams.peakFrVec = nan(1E5,1);
cParams.deltaEnvVec = nan(1E5,1);
cParams.nDurVec = nan(1E5,1);
cParams.snrVec = nan(1E5,1);
% time series stored in cell arrays because length varies
cParams.yFiltVec = cell(1E5,1);
cParams.yFiltBuffVec = cell(1E5,1);


if p.saveNoise
    cParams.yNFiltVec = [];
    cParams.specNoiseTfVec = [];
    cParams.noiseTimes = [];
end
