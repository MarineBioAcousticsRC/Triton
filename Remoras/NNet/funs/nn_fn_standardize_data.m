function [dataInput,trainTestSetInfo] = nn_fn_standardize_data(trainTestSetInfo,dataInput, trainTF)
    % trainTF should be true if you want to update trainTestSetInfo values,
    % false otherwise.
    if trainTF
        trainTestSetInfo.specStd = [mean(min(dataInput(:,1:trainTestSetInfo.setSpecHDim),[],2)),mean(max(dataInput(:,1:trainTestSetInfo.setSpecHDim),[],2))];
    end
    normSpec1 = dataInput(:,1:trainTestSetInfo.setSpecHDim)-trainTestSetInfo.specStd(1);
    dataInput(:,1:trainTestSetInfo.setSpecHDim) = normSpec1./(trainTestSetInfo.specStd(2)-trainTestSetInfo.specStd(1));

    ICIstart = trainTestSetInfo.setSpecHDim+1;
    
    if max(dataInput(:,ICIstart:(ICIstart+trainTestSetInfo.setICIHDim-1)),[],'all')>1 ...
        && trainTestSetInfo.iciStd>1
        if trainTF
            trainTestSetInfo.iciStd = mean(max(dataInput(:,ICIstart:(ICIstart+trainTestSetInfo.setICIHDim-1)),[],2));
        end
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
    % check icis for infs and nans
    tempICI = dataInput(:,ICIstart:(ICIstart+trainTestSetInfo.setICIHDim-1));
    tempICI(isnan(tempICI)) = 0;
    tempICI(isinf(tempICI)) = 0;
    dataInput(:,ICIstart:(ICIstart+trainTestSetInfo.setICIHDim-1)) = tempICI;


    wavestart = trainTestSetInfo.setSpecHDim+trainTestSetInfo.setICIHDim+1;
    if trainTF 
        
        trainTestSetInfo.waveMed = median(max(dataInput(:,wavestart:(wavestart+trainTestSetInfo.setWaveHDim-1)),[],2));
        trainTestSetInfo.waveMode = mode(max(dataInput(:,wavestart:(wavestart+trainTestSetInfo.setWaveHDim-1)),[],2));

    end

    if trainTestSetInfo.waveMode==1 % sometimes most of the waveforms are normalized to 1, if so, make them all that way.
        trainTestSetInfo.maxWave = max( dataInput(:,wavestart:(wavestart+trainTestSetInfo.setWaveHDim-1)),[],2);

        dataInput(:,wavestart:(wavestart+trainTestSetInfo.setWaveHDim-1)) = dataInput(:,wavestart:(wavestart+trainTestSetInfo.setWaveHDim-1))./trainTestSetInfo.maxWave;
    
    else % otherwise divide by the training set median.
        dataInput(:,wavestart:(wavestart+trainTestSetInfo.setWaveHDim-1)) = dataInput(:,wavestart:(wavestart+trainTestSetInfo.setWaveHDim-1))./trainTestSetInfo.waveMed;

    end
    % optional neighbordata section
    neighborWidth = size(dataInput,2)-trainTestSetInfo.setWaveHDim-...
        trainTestSetInfo.setICIHDim-trainTestSetInfo.setSpecHDim;
    dataInput(:,(end-neighborWidth):end) = dataInput(:,(end-neighborWidth):end)/20;
