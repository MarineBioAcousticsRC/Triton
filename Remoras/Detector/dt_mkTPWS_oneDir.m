function dt_mkTPWS_oneDir(detFiles,recFiles,p)

lfs = length(detFiles); % number of files

% file type
if strcmp(p.recFileExt,'.x.wav')
    ftype = 2;
elseif strcmp(p.recFileExt,'.wav')
    ftype = 1;
else
    error('Audio file type not supported')
end

% Initialize temporal settings,to track sampling frequency and only rebuild
% the filters if the sampling frequency changes. 
pTemp = p;
firstloop = true;
for itr1 = 1:lfs % for each detection file
    
    currentRecFile = recFiles{itr1};
    currentDetFile = detFiles{itr1};
    
    % read file header info
    hdr = ioReadXWAVHeader(currentRecFile,'ftype', ftype);
    
    if isempty(hdr)
        warning('No header info returned for file %s',currentRecFile);
        disp('Moving on to next file')
        continue % skip if you couldn't read a header
    end
    
    if hdr.fs ~= pTemp.previousFs
        % otherwise, if this is the first time through, build your filters,
        % only need to do this once though, so if you already have this
        % info, this step is skipped
        [previousFs,pTemp] = dt_buildFilters(pTemp,hdr.fs);
        pTemp.previousFs = previousFs;
        pTemp = dt_interp_tf(pTemp);
    end
    
    % set up storage TPWS variables in the first run
    if firstloop
        detParams = dt_TPWS_initParams(pTemp);
        firstloop = false;
    end
    
    % read detection file and get first column with start times of detections
    detID = fopen(currentDetFile);
    if detID ~=-1
        [detText] = textscan(detID,'%f %f %s'); % load text file
        fclose(detID);
    else
        error('Unable to open detection file %s',currentDetFile);
    end
    
    % click start/end position (sec) in reference from the beggining of the audio file
    starts = detText{:,1}; 
    stops = detText{:,2};
    
    % Open audio file
    recID = fopen(currentRecFile, 'r');
    
    % Samples to on either side of click
    buffSamples = pTemp.framebuffer*hdr.fs;
    
    for k = 1:length(starts)
        
        % Select iteration start and end
        startClick = starts(k);
        stopClick = stops(k);
        
        %%%%%%%%%% change energyyyy to length of xwav file length
        startSample = max(((aboveThreshold - buffSamples)), 1);
        stopSample = min(((aboveThreshold + buffSamples)), length(energy));
        
         % Read in data segment
        if strncmp(hdr.filetype,'wav',3)
            data = io_readWav(fid, hdr, startK, stopK, 'Units', 's',...
                'Channels', pTemp.channel, 'Normalize', 'unscaled')';
        else
            data = ioReadXWAV(recID,hdr,startClick,stopClick,1)
            data = io_readRaw(fid, hdr, k, pTemp.channel);
        end
        
    end
    
    fclose(recID);
    

            %%%%%%%%%%%%%%%%%

            %%%%%%%%%%%%%%%%
            % to move to a separate function
            % convert times into matlab date
            
            durRaw = (hdr.raw.dnumEnd - hdr.raw.dnumStart)'*dnum2sec;
            cumDur = cumsum(durRaw) - durRaw(1); % extract first dur to have dur from start of file
            
            % find the correct raw file and extract the duration
            rawIdx = arrayfun(@(x) find(x >= cumDur,1,'last'),startTimes,...
                'UniformOutput',false);
            rawIdx( cellfun(@isempty, rawIdx) ) = {0}; % fill empty cells with 0
            rawIdx = cell2mat(rawIdx);
            
            % extract previous time and add raw file start time
            refRawTime = (hdr.raw.dnumStart(rawIdx)' + Y2K)*dnum2sec;
            posDnum = (startTimes - cumDur(rawIdx) + refRawTime)/dnum2sec;
            %%%%%%%%%%%%%%%%%%%

    
    
    if exist('clickTimes','var') && ~isempty(clickTimes)&& size(specClickTf,2)>1
        % specClickTf = specClickTfHR;
        keepers = find(ppSignal >= ppThresh);
        
        ppSignal = ppSignal(keepers);
        clickTimes = clickTimes(keepers,:);
        
        [~,keepers2] = unique(clickTimes(:,1));
        
        clickTimes = clickTimes(keepers2,:);
        ppSignal = ppSignal(keepers2);
        
        % % % % % % % % %         fileStart = datenum(hdr.start.dvec);
        % % % % % % % % %         posDnum = (clickTimes(:,1)/(60*60*24)) + fileStart +...
        % % % % % % % % %             datenum([2000,0,0,0,0,0]);
        clickTimesVec = [clickTimesVec; posDnum];
        ppSignalVec = [ppSignalVec; ppSignal];
        tsWin = 200;
        tsVec = zeros(length(keepers),tsWin);
        for iTS = 1:length(keepers(keepers2))
            thisClick = yFiltBuff{keepers(keepers2(iTS))};
            [~,maxIdx] = max(thisClick);
            % want to align clicks by max cycle
            % f = fHR;
            if isempty(fSave)
                fSave = f;
            end
            dTs = (tsWin/2) - maxIdx; % which is bigger, the time series or the window?
            dTe =  (tsWin/2)- (length(thisClick)-maxIdx); % is the length after the peak bigger than the window?
            if dTs<=0 % if the signal starts more than N samples ahead of the peak
                % the start position in the TS vector has to be 1
                posStart = 1;
                % the start of the click ts has to be peak - 1/N
                sigStart = maxIdx - (tsWin/2)+1;
            else
                % if it's smaller
                posStart = dTs+1; % the start has to make up the difference
                sigStart = 1; % and use the first index of the signal
            end
            
            if dTe<=0 % if it ends after the cut off of N samples
                posEnd = tsWin; % the end in the TS vector has to be at N
                sigEnd = maxIdx + (tsWin/2); % and last index is N/2 points after the peak.
            else % if it ends before the end of the TS vector
                posEnd = tsWin-dTe; % the end point has to be the
                % difference between the window length and the click length
                sigEnd = length(thisClick);
            end
            
            tsVec(iTS,posStart:posEnd) = thisClick(sigStart:sigEnd);
        end
        tsVecStore = [tsVecStore;tsVec];
        
        if iscell(specClickTf)
            spv = cell2mat(specClickTf');
            specClickTfVec = [specClickTfVec; spv(:,keepers(keepers2))'];
        else
            specClickTfVec = [specClickTfVec; specClickTf(keepers(keepers2),:)];
        end
        clickTimes = [];
        hdr = [];
        specClickTf = [];
        ppSignal = [];
    end
    fprintf('Done with file %d of %d \n',itr1,lfs)
    
    if (size(clickTimesVec,1)>= 1800000 && (lfs-itr1>=10))|| itr1 == lfs
        
        MSN = tsVecStore;
        MTT = clickTimesVec;
        MPP = ppSignalVec;
        MSP = specClickTfVec;
        if itr1 == lfs && letterFlag == 0
            ttppOutName =  [fullfile(outDir,dirSet(itr0).name),'_Delphin_TPWS1','.mat'];
            fprintf('Done with directory %d of %d \n',itr0,length(dirSet))
            subTP = 1;
        else
            
            ttppOutName = [fullfile(outDir,dirSet(itr0).name),char(letterCode(subTP)),'_Delphin_TPWS1','.mat'];
            subTP = subTP+1;
            letterFlag = 1;
        end
        f = fSave;
        save(ttppOutName,'MTT','MPP','MSP','MSN','f','-v7.3')
        
        MTT = [];
        MPP = [];
        MSP = [];
        MSN = [];
        
        clickTimesVec = [];
        ppSignalVec = [];
        specClickTfVec = [];
        tsVecStore = [];
        
    end
end