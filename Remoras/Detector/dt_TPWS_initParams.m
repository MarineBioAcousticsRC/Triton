function params = dt_TPWS_initParams(p)
% Initialize vectors for main detector loop
N = p.estimSize;

params.clickTimes = nan(N,2);
params.ppSignalVec = nan(N,1);
params.specClickTfVec = nan(N,length(p.specRange));
params.yFiltBuffVec = cell(N,1);

if p.exclDetections
params.durClickVec = nan(N,1);
params.bw3dbVec = nan(N,3);
params.peakFrVec = nan(N,1);
params.deltaEnvVec = nan(N,1);
params.nDurVec = nan(N,1);
% time series stored in cell arrays because length varies
params.yFiltVec = cell(N,1);
end

if p.saveNoise
    params.yNFiltVec = [];
    params.specNoiseTfVec = [];
end