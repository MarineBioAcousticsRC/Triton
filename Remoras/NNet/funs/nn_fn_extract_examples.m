function [setSN,setSP,setAmp,setNeighborData] = nn_fn_extract_examples(folderPath,fList,...
    nExamples,fListIdx,boutStartIdxAll,boutEndIdxAll,clickIndices,edges,bin)

global REMORA

setSN = [];
setSP = [];
setAmp = [];
sIdx = 1;
nBouts = length(fListIdx);

for iBout = 1:nBouts

    thisFileIdx = fListIdx(iBout);
    thisTypeFile = fullfile(fList(thisFileIdx).folder,fList(thisFileIdx).name);

    % do partial load of just clicks in bout
    fileObj = matfile(thisTypeFile);
    details = whos(fileObj) ;
    if contains([details.name],'neighborMetrics')
        neighborMetrics = fileObj.neighborMetrics;
    end

    if iBout == 1
        % pre-allocate now that we know the horizontal dimensions if
        % this is the first pass.
        SNwidth = size(fileObj.trainMSN(1,:),2);
        SPwidth = size(fileObj.trainMSP(1,:),2);
        setSN = zeros(nExamples,SNwidth);
        setSP = zeros(nExamples,SPwidth);
        setAmp = zeros(nExamples,1);
        setMaxAmpNeighbor = [];
        setPeakFrNeighbor = [];
        setICINeighbor = [];
    end

    boutIdxRange = boutStartIdxAll(iBout):boutEndIdxAll(iBout);
    whichEvents = clickIndices(bin==iBout)-edges(iBout)+1;
    eIdx = sIdx+size(whichEvents,2)-1;

    if size(boutIdxRange,2)<200000
        % load a big set, then pick what you want
        if REMORA.nn.train_test_set.useWave
            thisBout.MSN = fileObj.trainMSN(boutIdxRange,:);
            thisBout.amplitude = sqrt(mean(thisBout.MSN.^2,2))./...
                max(abs(thisBout.MSN),[],2);
        else
            thisBout.MSN = [];
            thisBout.amplitude = [];
        end
        if REMORA.nn.train_test_set.useSpectra
            thisBout.MSP = fileObj.trainMSP(boutIdxRange,:);
        else
            thisBout.MSP = [];
        end
        % add handling for neighbor data
        if contains([details.name],'neighborMetrics')
            thisBout.setMaxAmpNeighbor = neighborMetrics.trainMaxAmpNeighbor(boutIdxRange,:);
            thisBout.setPeakFrNeighbor = neighborMetrics.trainPeakFrnNeighbor(boutIdxRange,:);
            thisBout.setICINeighbor = neighborMetrics.trainICINeighbor(boutIdxRange,:);
        end

        % Figure out which of the randomly selected training events are in this bout
        if REMORA.nn.train_test_set.useWave
            setSN(sIdx:eIdx,:) = thisBout.MSN(whichEvents,:);
            setAmp(sIdx:eIdx,1) = thisBout.amplitude(whichEvents,:);

        end
        if REMORA.nn.train_test_set.useSpectra
            setSP(sIdx:eIdx,:) = thisBout.MSP(whichEvents,:);
        end

        if exist('neighborMetrics', 'var')
            setMaxAmpNeighbor(sIdx:eIdx,:) = thisBout.setMaxAmpNeighbor(whichEvents,:);
            setPeakFrNeighbor(sIdx:eIdx,:) = thisBout.setPeakFrNeighbor(whichEvents,:);
            setICINeighbor(sIdx:eIdx,:) = thisBout.setICINeighbor(whichEvents,:);
        end
        sIdx = sIdx+size(whichEvents,2);

    else
        % if that's too much to load, do it one at a time
        for iDet = 1:length(whichEvents)
            if REMORA.nn.train_test_set.useWave
                setSN(sIdx,:) = fileObj.trainMSN(boutIdxRange(1)+whichEvents(iDet),:);
            end
            if REMORA.nn.train_test_set.useSpectra
                setSP(sIdx,:) = fileObj.trainMSP(boutIdxRange(1)+whichEvents(iDet),:);
            end


            % add handling for neighbor data
            if exist('neighborMetrics', 'var')
                setMaxAmpNeighbor(sIdx,:)  = neighborMetrics.trainMaxAmpNeighbor(boutIdxRange(1)+whichEvents(iDet),:);
                setPeakFrNeighbor(sIdx,:)  = neighborMetrics.trainPeakFrnNeighbor(boutIdxRange(1)+whichEvents(iDet),:);
                setICINeighbor(sIdx,:)  = neighborMetrics.trainICINeighbor(boutIdxRange(1)+whichEvents(iDet),:);
            end

            sIdx = sIdx+1;

        end
        setAmp = sqrt(mean(setSN.^2,2))./...
            max(abs(setSN),[],2);
    end
    fprintf('. ')
    if mod(iBout,25)==0
        fprintf('\n')
    end
end
setNeighborData.setMaxAmpNeighbor = setMaxAmpNeighbor;
setNeighborData.setPeakFrNeighbor = setPeakFrNeighbor;
setNeighborData.setICINeighbor = setICINeighbor;

fprintf('\n')