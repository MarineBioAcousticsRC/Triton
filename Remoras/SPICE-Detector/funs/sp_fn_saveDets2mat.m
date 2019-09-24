function sp_fn_saveDets2mat(fileName,cParams,f,hdr,p)

% Can't save directly in parfor loop, so save externally    
clickTimes = cParams.clickTimes;
ppSignal = cParams.ppSignalVec;
yFiltBuff = cParams.yFiltBuffVec;
specClickTf = cParams.specClickTfVec;
snr = cParams.snrVec;
if p.saveNoise
        noiseTimes = cParams.noiseTimes;
        yNFilt = cParams.yNFiltVec;
        specNoiseTf = cParams.specNoiseTfVec;
end
if p.saveForTPWS % only save what you need to build a TPWS file
    if p.saveNoise
        save(fileName,'clickTimes','ppSignal','f','hdr','specClickTf',...
            'noiseTimes','specNoiseTf','yFiltBuff','yNFilt','snr','p','-mat','-v7.3');
    else
        save(fileName,'clickTimes','ppSignal','f','hdr','specClickTf',...
            'yFiltBuff','p','snr','-mat','-v7.3');
    end
else 
    durClick = cParams.durClickVec;
    nDur = cParams.nDurVec;
    deltaEnv = cParams.deltaEnvVec;
    bw3db = cParams.bw3dbVec;
    yFilt = cParams.yFiltVec;
    peakFr = cParams.peakFrVec;
    if p.saveNoise
        save(fileName,'clickTimes','ppSignal','durClick','f','hdr','nDur',...
            'deltaEnv','yNFilt','specNoiseTf','bw3db','yFilt','specClickTf',...
            'noiseTimes','peakFr','yFiltBuff','snr','p','-mat','-v7.3');
    else
        save(fileName,'clickTimes','ppSignal','durClick','f','hdr','nDur',...
            'deltaEnv','bw3db','yFilt','specClickTf',...
            'peakFr','yFiltBuff','snr','p','-mat','-v7.3');
    end
end
