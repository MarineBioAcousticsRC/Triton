function dataInput = nn_fn_standardize_data(trainTestSetInfo,dataInput)
    trainTestSetInfo.specStd = [mean(min(dataInput(:,1:trainTestSetInfo.setSpecHDim),[],2)),mean(max(dataInput(:,1:trainTestSetInfo.setSpecHDim),[],2))];
   
    normSpec1 = dataInput(:,1:trainTestSetInfo.setSpecHDim)-trainTestSetInfo.specStd(1);
    dataInput(:,1:trainTestSetInfo.setSpecHDim) = normSpec1./(trainTestSetInfo.specStd(2)-trainTestSetInfo.specStd(1));

    ICIstart = trainTestSetInfo.setSpecHDim+1;
    if max(dataInput(:,ICIstart:(ICIstart+trainTestSetInfo.setICIHDim-1)),[],'all')>1 ...
        && trainTestSetInfo.iciStd>1
        trainTestSetInfo.iciStd = mean(max(dataInput(:,ICIstart:(ICIstart+trainTestSetInfo.setICIHDim-1)),[],2));
        dataInput(:,ICIstart:(ICIstart+trainTestSetInfo.setICIHDim-1)) = ...
            dataInput(:,ICIstart:(ICIstart+trainTestSetInfo.setICIHDim-1))/...
            trainTestSetInfo.iciStd(1);
    elseif max(dataInput(:,ICIstart:(ICIstart+trainTestSetInfo.setICIHDim-1)),[],'all')>1 ...
        && trainTestSetInfo.iciStd<=1

        dataInput(:,ICIstart:(ICIstart+trainTestSetInfo.setICIHDim-1)) = ...
            dataInput(:,ICIstart:(ICIstart+trainTestSetInfo.setICIHDim-1))./...
            max(dataInput(:,ICIstart:(ICIstart+trainTestSetInfo.setICIHDim-1)),[],2);
    else
       warning('ICI appears to be already normalized to [0,1] skipping standardization')
       trainTestSetInfo.iciStd = 1;
    end
    
    wavestart = trainTestSetInfo.setSpecHDim+trainTestSetInfo.setICIHDim+1;
    trainTestSetInfo.waveStd = std(max(dataInput(:,wavestart:(wavestart+trainTestSetInfo.setWaveHDim-1)),[],2));
    trainTestSetInfo.maxWave = 200;%max( dataInput(:,wavestart:(wavestart+trainTestSetInfo.setWaveHDim-1)),[],2);

    dataInput(:,wavestart:(wavestart+trainTestSetInfo.setWaveHDim-1)) = dataInput(:,wavestart:(wavestart+trainTestSetInfo.setWaveHDim-1))./trainTestSetInfo.maxWave;
    % optional neighbordata section
    neighborWidth = size(dataInput,2)-trainTestSetInfo.setWaveHDim-...
        trainTestSetInfo.setICIHDim-trainTestSetInfo.setSpecHDim;
    dataInput(:,(end-neighborWidth):end) = dataInput(:,(end-neighborWidth):end)/20;
