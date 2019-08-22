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

% initialize TPWS variables
detParams = dt_init_detParams(p);

for itr1 = 1:lfs % for each detection file
    
    currentRecFile = recFiles{itr1};
    currentDetFile = detFiles{itr1};
    
% % % %     % read file header info
% % % %     hdr = ioReadXWAVHeader(currentRecFile,'fType', ftype);
% % % %     
% % % %     if isempty(hdr)
% % % %         warning('No header info returned for file %s',currentRecFile);
% % % %         disp('Moving on to next file')
% % % %         continue % skip if you couldn't read a header
% % % %     else
% % % %         if fTypes(idx1) == 1
% % % %             [startsSec,stopsSec,pTemp] = dt_LR_chooseSegments(pTemp,hdr);
% % % %         else
% % % %             % divide xwav by raw file
% % % %             [startsSec,stopsSec] = dt_chooseSegmentsRaw(hdr);
% % % %         end
% % % %         
% % % %     end
    
    if hdr.fs ~= pTemp.previousFs
        % otherwise, if this is the first time through, build your filters,
        % only need to do this once though, so if you already have this
        % info, this step is skipped
        [previousFs,pTemp] = dt_buildFilters(pTemp,hdr.fs);
        pTemp.previousFs = previousFs;
        pTemp = dt_interp_tf(pTemp);
    end
    
    
    detFile = fileSet(itr1).name;
    
    %     load(char(fullfile(detDir,thisFile)),'-mat','clickTimes','hdr',...
    %         'ppSignal','specClickTf','yFiltBuff','f','durClick')
    
    % read text file
    if strcmp(fileExt.det,'.pgdf')
        % add:  [dataSet, fileInfo] = loadPamguardBinaryFile(fileName);
        error('Not available yet')
    else
        pTemp = p;
        % get audio file header
        audioFileName = strrep(detFile,fileExt.det,fileExt.audio);
        if exist(fullfile(folder.audio,audioFileName),'file')
            hdr = ioReadXWAVHeader(fullfile(folder.audio,audioFileName),'ftype',ftype);
            
            % Build filter on first pass, rebuild if file has different
            % sampling rate
            if isempty(hdr)
                continue % skip if you couldn't read a header
            elseif hdr.fs ~= pTemp.previousFs
                % otherwise, if this is the first time through, build your filters,
                % only need to do this once though, so if you already have this
                % info, this step is skipped
                
                [previousFs,pTemp] = dt_buildFilters(pTemp,hdr.fs);
                pTemp.previousFs = previousFs;
                
                pTemp = dt_interp_tf(pTemp);
            end
            

            %%%%%%%%%%%%%%%%%
            % read detection file and get first column with start times of
            % detections
            detID = fopen(fullfile(folder.det,detFile));
            if detID ~=-1
                [detText] = textscan(detID,'%f %f %s'); % load text file
                fclose(detID);
            else
                msg = sprintf('Unable to open detection file %s\n',fullfile(folder.det,detFile));
                error(msg);
            end
            
            startTimes = detText{:,1};
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
        else
            fprintf('No audio file matching %s\n',detFile)
        end
    end
    
    
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