function [clickParamsOut,fOut] = dt_batch(fullFiles,fullLabels,p,encounterTimes,runMode)


N = size(fullFiles,1);
p.previousFs = 0; % make sure we build filters on first pass

% get file type list
fTypes = io_getFileType(fullFiles);
f = [];
cParams = [];
for idx1 = 1:N % for each data file
    pTemp = p;
    outFileName = fullLabels{idx1};
    if ~pTemp.overwrite && exist(outFileName, 'file') == 2
        fprintf('DetectionFile %s already exists.\n',outFileName)
        fprintf('Overwrite option is false, skipping to next file.\n')
        continue
    end
    fprintf('beginning file %d of %d \n',idx1,N)
    %(has to be inside loop for parfor, ie, filters are rebuilt every time,
    % can be outside for regular for)
    
    currentRecFile = fullFiles{idx1};
    %labelFile = fullLabels{idx1};
    
    % read file header
    hdr = io_readXWAVHeader(fullFiles{idx1}, pTemp,'fType', fTypes(idx1));
    
    if isempty(hdr)
        warning(fprintf('No header info returned for file %s',...
            currentRecFile));
        disp('Moving on to next file')
        continue % skip if you couldn't read a header
        % Read the file header info
    else
        if fTypes(idx1) == 1
            [startsSec,stopsSec,pTemp] = dt_LR_chooseSegments(pTemp,hdr);
        else
            % divide xwav by raw file
            [startsSec,stopsSec] = dt_chooseSegmentsRaw(hdr);
        end
        
    end
    
    if hdr.fs ~= pTemp.previousFs
        % otherwise, if this is the first time through, build your filters,
        % only need to do this once though, so if you already have this
        % info, this step is skipped
        
        [previousFs,pTemp] = fn_buildFilters(pTemp,hdr.fs);
        pTemp.previousFs = previousFs;
        pTemp = fn_interp_tf(pTemp);
        if ~isfield(pTemp,'countThresh') || isempty(pTemp.countThresh)
            pTemp.countThresh = (10^((pTemp.dBppThreshold - median(pTemp.xfrOffset))/20))/2;
        end
    end
    
    cParams = dt_init_cParams(pTemp); % set up storage for HR output.
    sIdx = 1;
    % Open audio file
    fid = fopen(currentRecFile, 'r');
    buffSamples = pTemp.LRbuffer*hdr.fs;
    % Loop through search area, running short term detectors
    pTemp.clickSampleLims = ceil((hdr.fs./1e6).*[pTemp.delphClickDurLims(1)*.75,...
        pTemp.delphClickDurLims(2)*1.25]);
    for k = 1:length(startsSec)
        
        % Select iteration start and end
        startK = startsSec(k);
        stopK = stopsSec(k);
        
        % Read in data segment
        if strncmp(hdr.fType,'wav',3)
            data = io_readWav(fid, hdr, startK, stopK, 'Units', 's',...
                'Channels', pTemp.channel, 'Normalize', 'unscaled')';
        else
            data = io_readRaw(fid, hdr, k, pTemp.channel);
        end
        if isempty(data)
            warning('No data read from current file segment. Skipping.')
            continue
        end
        
        % bandpass
        if pTemp.filterSignal
            filtData = filtfilt(pTemp.fB,pTemp.fA,data);
        else
            filtData = data;
        end
        energy = filtData.^2;
        
        %%% Run LR detection to identify candidates
        [detectionsSample,detectionsSec] =  dt_LR(energy,hdr,buffSamples,...
            startK,stopK,pTemp);
        
        
        %%% start HR detection on candidates
        for iD = 1:size(detectionsSample,1)
            filtSegment = filtData(detectionsSample(iD,1):detectionsSample(iD,2));
            [clicks, noise] = dt_HR(pTemp, hdr, filtSegment);
            
            if ~ isempty(clicks)
                % if we're in here, it's because we detected one or more possible
                % clicks in the kth segment of data
                % Make sure our click candidates aren't clipped
                validClicks = dt_pruneClipping(clicks,pTemp,hdr,filtSegment);
                
                % Look at power spectrum of clicks, and remove those that don't
                % meet peak frequency and bandwidth requirements
                clicks = clicks(validClicks==1,:);
                % Compute click parameters to decide if the detection should be kept
                [clickDets,f] = dt_parameters(noise,filtSegment,pTemp,clicks,hdr);
                
                if ~isempty(clickDets.clickInd)
                    % populate cParams
                    [cParams,sIdx] = dt_populate_cParams(clicks,pTemp,...
                        clickDets,detectionsSec(iD,1),hdr,sIdx,cParams);
                end
            end
        end
    end
    fclose(fid);
    
    % fclose all;
    fprintf('done with %s\n', currentRecFile);
    
    cParams = dt_prune_cParams(cParams,sIdx);
    
    % Run post processing to remove rogue loner clicks, prior to writing
    % the remaining output files.
    clickTimes = sortrows(cParams.clickTimes);
    
    keepFlag = dt_postproc(outFileName,clickTimes,p,hdr,encounterTimes);
    keepIdx = find(keepFlag==1);
    
    cParams = dt_prune_cParams_byIdx(cParams,keepIdx);
    
    if strcmp(runMode,'guiRun')
%         clickParamsOut{1} = cParams;
%         fOut{1} = f;
    end
    fn_saveDets2mat(strrep(outFileName,['.',p.ppExt],'.mat'),cParams,f,hdr,p);
    
end

