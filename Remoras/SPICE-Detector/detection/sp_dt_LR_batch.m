function sp_dt_LR_batch(fullLabels,fullFiles,p)
% Runs a quick energy detector on a set of files using
% the specified set of detection parameters. Flags times containing signals
% of interest, and outputs the results to a .c file

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N = size(fullFiles,1);
p.previousFs = 0; % make sure we build filters on first pass

% get file type list
fTypes = sp_io_getFileType(fullFiles);

parfor idx = 1:N  % "parfor" works here, parallellizing the process across as
    % many cores as your machine has available.
    % It's faster, but the drawback is that if the code crashes,
    % it's hard to figure out where it was, and how many files
    % have been completed. It will also eat up your cpu.
    % You can use regular "for" too.
    pTemp = p;
    outFileName = fullLabels{idx};
    if ~pTemp.overwrite && exist(outFileName, 'file') == 2
        fprintf('DetectionFile %s already exists.\n',outFileName)
        fprintf('Overwrite option is false, skipping to next file.\n')
        continue
    end
    detections = []; % initialize
    
    % Pull in a file to examine
    currentRecFile = fullFiles{idx};
    hdr = sp_io_readXWAVHeader(currentRecFile,pTemp,'fType',fTypes(idx));
    
    if isempty(hdr)
        warning(fprintf('No header info returned for file %s',...
            currentRecFile));
        disp('Moving on to next file')
        continue
    end
    
    % Read the file header info
    if fTypes(idx) == 1 
        [startsSec,stopsSec,pTemp] = sp_dt_LR_chooseSegments(pTemp,hdr);
    else
        % divide xwav by raw file
        [startsSec,stopsSec] = sp_dt_chooseSegmentsRaw(hdr);
    end    

    % Build a bandpass filter on first pass or if sample rate has changed
    if hdr.fs ~= pTemp.previousFs
        [previousFs,pTemp] = sp_fn_buildFilters(pTemp,hdr.fs);
        pTemp.previousFs = previousFs;
        % also need to compute an amplitude threshold cutoff in counts
        % keep it conservative for now by using the transfer function
        % maximum across the band of interest
        pTemp = sp_fn_interp_tf(pTemp);
        if ~isfield(pTemp,'countThresh') || isempty(pTemp.countThresh)
            pTemp.countThresh = (10^((pTemp.dBppThreshold - median(pTemp.xfrOffset))/20))/2;
        end
    end
    
    % Open audio file
    fid = fopen(currentRecFile, 'r');
    buffSamples = pTemp.LRbuffer*hdr.fs;
    % Loop through search area, running short term detectors
    for k = 1:length(startsSec)
        % Select iteration start and end
        startK = startsSec(k);
        stopK = stopsSec(k);
        
        % Read in data segment
        if strncmp(hdr.fType,'wav',3)
            data = sp_io_readWav(fid, hdr, startK, stopK, 'Units', 's',...
                'Channels', pTemp.channel, 'Normalize', 'unscaled')';
        else
            data = sp_io_readRaw(fid, hdr, k, pTemp.channel);
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
        
        % Flag times when the amplitude rises above a threshold
        aboveThreshold = find(energy>((pTemp.countThresh^2)));        
        
        % add a buffer on either side of detections.
        detStart = max((((aboveThreshold - buffSamples)/hdr.fs) + startK), startK);
        detStop = min((((aboveThreshold + buffSamples)/hdr.fs) + startK), stopK);
        
        % Merge flags that are close together.
        if length(detStart)>1
            [stopsM,startsM] = sp_dt_mergeCandidates(buffSamples/hdr.fs,...
                detStop', detStart');
        else
            startsM = detStart;
            stopsM = detStop;
        end
        
        % Add current detections to overall detection vector
        if ~isempty(startsM)
            detections = [detections; [startsM,stopsM]];
        end
    end
    
    % done with current audio file
    fclose(fid);
    
    % Write out .c file for this audio file
    if ~isempty(detections)
        sp_io_writeLabel(outFileName, detections);
    else % write zeros to file if no detections.
        sp_io_writeLabel(outFileName, [0,0])
    end
end
