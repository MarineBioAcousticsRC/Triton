function sp_dt_makeTPWS_oneDir(inDir,letterCode,ppThresh,outDir,outName,spName,maxRows,tsWin)

letterFlag = 0; % flag for knowing if a letter should be appended to disk name
% inDir = fullfile(baseDir,dirSet(itr0).name);
fileSet = what(inDir);
lfs = length(fileSet.mat);
subTP = 1;
fSave = [];

if lfs == 0
    disp_msg('no detection files found.')
    return
end

MPP =  zeros(maxRows,1);
MSN = zeros(maxRows,tsWin);
MTT = zeros(maxRows,1);
MSP = [];
matIdxStart = 1;
matIdxEnd = 1;
for itr2 = 1:lfs
    thisFile = fileSet.mat(itr2);
    
    load(char(fullfile(inDir,thisFile)),'-mat','clickTimes','hdr',...
        'ppSignal','specClickTf','yFiltBuff','f','durClick')
    if exist('clickTimes','var') && ~isempty(clickTimes)&& size(specClickTf,2)>1
        % specClickTf = specClickTfHR;
        if size(MSP,1)==0 % if empty, pre-allocate now that width should be known.
            specLength = size(specClickTf,2);
            MSP = zeros(maxRows,specLength);
        end
        
        keepers = find(ppSignal >= ppThresh);
        
        ppSignal = ppSignal(keepers);
        clickTimes = clickTimes(keepers,:);
        
        [~,keepers2] = unique(clickTimes(:,1));
        
        clickTimes = clickTimes(keepers2,:);
        ppSignal = ppSignal(keepers2);
        
        matIdxEnd = matIdxStart+size(clickTimes,1)-1;
        if matIdxEnd> size(MTT,1)
            disp('Have to add more rows')
            % have to add more rows
            MTT = [MTT;zeros(matIdxEnd-size(MTT,1),size(MTT,2))];
            MPP = [MPP;zeros(matIdxEnd-size(MPP,1),size(MPP,2))];
            MSN = [MSN;zeros(matIdxEnd-size(MSN,1),size(MSN,2))];
            MSP = [MSP;zeros(matIdxEnd-size(MSP,1),size(MSP,2))];
            
        end
        fileStart = datenum(hdr.start.dvec);
        if fileStart< datenum([2000,0,0])
            fileStart = fileStart + datenum([2000,0,0,0,0,0]);
        end
        
        posDnum = (clickTimes(:,1)/(60*60*24)) + fileStart ;
        MTT(matIdxStart:matIdxEnd,:) = posDnum;
        MPP(matIdxStart:matIdxEnd,:) = ppSignal;
        
        tsVec = zeros(length(keepers(keepers2)),tsWin);
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
        MSN(matIdxStart:matIdxEnd,:) = tsVec;
        
        if iscell(specClickTf)
            spv = cell2mat(specClickTf');
            MSP(matIdxStart:matIdxEnd,:) = spv(:,keepers(keepers2))';
        else
            MSP(matIdxStart:matIdxEnd,:) = specClickTf(keepers(keepers2),:);
        end
        clickTimes = [];
        hdr = [];
        specClickTf = [];
        ppSignal = [];
        posDnum = [];
        matIdxStart = matIdxEnd+1;
    end
    disp_msg(sprintf('Done with file %d of %d',itr2,lfs))
    drawnow
    
    if (matIdxEnd>= maxRows && (lfs-itr2>=10))|| itr2 == lfs
        
        
        if itr2 == lfs && letterFlag == 0
            ttppOutName =  [fullfile(outDir,outName),'_',spName,'_TPWS1','.mat'];
            subTP = 1;
        else
            
            ttppOutName = [fullfile(outDir,outName),char(letterCode(subTP)),'_',spName,'_TPWS1','.mat'];
            subTP = subTP+1;
            letterFlag = 1;
        end
        
        %remove rows of zeros if applicable
        rmvZeroIdx = MTT ~= 0;
        
        MTT = MTT(rmvZeroIdx);
        MSP = MSP(rmvZeroIdx,:);
        MSN = MSN(rmvZeroIdx,:);
        MPP = MPP(rmvZeroIdx);
        
        f = fSave;
        disp_msg('Saving...');drawnow
        save(ttppOutName,'MTT','MPP','MSP','MSN','f','-v7.3')
        
        matIdxStart = 1;
        MPP = zeros(maxRows,1);
        MSN = zeros(maxRows,tsWin);
        MTT = zeros(maxRows,1);
        MSP = zeros(maxRows,specLength);
        matIdxEnd = 1;

    end
end