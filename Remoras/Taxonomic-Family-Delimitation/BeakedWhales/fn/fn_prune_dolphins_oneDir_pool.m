function fn_prune_dolphins_oneDir_pool(inDir,letterCode,outDir,outName,thr,p)

letterFlag = 0; % flag for knowing if a letter should be appended to disk name
fileSet = what(inDir);
lfs = length(fileSet.mat);
subTP = 1;
fSave = [];

if lfs == 0
    disp_msg('no detection files found.')
    return
end

% preallocate
MPP =  zeros(p.maxRows,1);
MTT = zeros(p.maxRows,1);
MSN = []; % preallocate later when knowing sample frequency
MSP = []; % preallocate later when knowing length of spectra
matIdxStart = 1;
matIdxEnd = 1;

% Read all mat files from the same disk
for itr2 = 1:lfs
    thisFile = fileSet.mat(itr2);    
    try
        load(char(fullfile(inDir,thisFile)),'-mat','clickTimes','hdr',...
            'ppSignal','specClickTf','yFiltBuff','f')
        
        bwClicks = [];
        if exist('clickTimes','var') && ~isempty(clickTimes)&& size(specClickTf,2)>1
            % preallocate
            seg75s = zeros(hdr.xhd.NumOfRawFiles,3);
            validClicksSeg = cell(hdr.xhd.NumOfRawFiles,1);
            if size(MSP,1)==0 % if empty, pre-allocate now that width is known.
                specLength = size(specClickTf,2);
                MSP = zeros(p.maxRows,specLength);
            end
            if size(MSN,1)==0 % if empty, pre-allocate now that sample frequency is known.
                tsWin = p.tsWin/1000*hdr.fs; % window in samples
                MSN = zeros(p.maxRows,tsWin);
            end
            
            % Calculate parameters for discrimination: peakFr, F0, dur, slope, nSamples
            % calculate duration click in ms
            durClick = (clickTimes(:,2) - clickTimes(:,1))*1000;
            
            % preallocate variables
            idxGoodClicks = nan(size(clickTimes,1),5);

            % Calculate variables that don't change between clicks
            % limit lower frequency at 10 kHz to calculate peak frequency
            f10 = find(f == 10); % 10kHz-index in the frequency vector
            endF = length(f);
            narrowf = f(f10:endF);
            specClickTfCut = specClickTf(:,f10:endF);
            
            %fix parameters to compute slope
            winlength = 0.3; %based on HARP fs 200k, 60 DFT
            olPerc = 59/60; %based on 60 DFT, 98% overlap
            df = round(winlength/1000*hdr.fs);
            ol = round(df*olPerc);
            halfL = 2*df; %half length is 120 samples
            
            parfor c = 1:size(clickTimes,1)
                %%%%%%%%%%%%%%%%%%%%%%%%%%
                % Calculate peak frequency in kHz (first half samples of the
                % spectogram limiting lower frequency at 10 kHz)
                
                [~, posMx] = max(specClickTfCut(c,:));
                peakFr = narrowf(posMx);
                
                % Calculate center frequency in kHz (Au 1993, equation 10-3)
                linearSpec=10.^(specClickTfCut(c,:)/20);
                F0=sum(narrowf.*linearSpec.^2)/sum(linearSpec.^2);
                
                %%%%%%%%%%%%%%%%%%%%%%%%%
                % Calculate slope
                %buffer = hdr.fs * p.HRbuffer;
                NyFiltBuff = length(yFiltBuff{c});
                currDurClick = durClick(c);
                durSamples = floor(currDurClick/1000*hdr.fs);
                if durSamples <= NyFiltBuff
                    buffer = floor((NyFiltBuff - durSamples)/2);
                else % weird cases where NyFiltBuff is shorter than durSamples
                    buffer = 0;
                    durSamples = NyFiltBuff;
                end
                
                %min length in Simone's slope is 240 samples
                if NyFiltBuff> halfL*2
                    % weird cases where durSamples doesn't correspond to
                    % yFiltBuff length
                    if durSamples > (NyFiltBuff-buffer*2)
                        durSamples = NyFiltBuff-(buffer*2)-1;
                    end
                    diffMiddle = floor(halfL-(durSamples/2));
                    pruneLen = buffer-diffMiddle+1:buffer-diffMiddle+halfL*2;
                    
                    % weird cases where selection goes beyond start of
                    % yFilBuff
                    if any(pruneLen < 1)
                        pruneLen(pruneLen < 1) = [];
                    end
                else
                    pruneLen = 1:NyFiltBuff;
                end
                
                click = yFiltBuff{c}(pruneLen);
                [~,F,T,P] = spectrogram(click,df,ol,df,hdr.fs);
                T = T*1000;
                F = F/1000;
                endP = size(P,1); % N rows in P
                
                % Find maximum values of each colum and convert into dB
                [x,y] = max(P(3:endP,:));
                xLog = 10*log10(x);
                
                %-8dB bandwidth
                low=max(xLog)-8;
                [~,yMax] = max(xLog);
                slopeup=fliplr(xLog(1:yMax));
                slopedown=xLog(yMax:end);
                for start=1:length(slopeup)
                    if slopeup(start)<low %stop at value < -8dB
                        break
                    end
                end
                for stop=1:length(slopedown)
                    if slopedown(stop)<low %stop at value < -8dB
                        break
                    end
                end
                
                % fit line to get slope and number of samples
                y8dB = y(yMax-start+1:yMax+stop-1);
                t = T(1:length(y8dB));
                yFit = y8dB*F(2);
                nSamples = length(yFit); %number of samples within -8dB
                slope = polyfit(t,yFit,1);
                
                % Prune out detections that do not meet the requirements
                idxGoodClicks(c,:) = [peakFr >= thr.peakFreq,...
                    F0 >= thr.centerFreq,...
                    currDurClick >= thr.durClick,...
                    slope(:,1) >= thr.slope/1000,...
                    nSamples >= thr.nSamples];
                
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            validClicks = find(all(idxGoodClicks,2));
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Count the number of clicks per 75s segment. Later finds the areas where
            % 10% of clicks per minute remained after discrimination
            
            % raw file duration in sec
            rawDur = (hdr.raw.dnumEnd-hdr.raw.dnumStart)*24*60*60;
            
            % count how many clicks per 75s before and after discrimination
            for iraw = 1:size(rawDur,2)
                segStart=(iraw-1)*rawDur(iraw);
                segEnd=iraw*rawDur(iraw); %i*rawDur(i)-1*10^-20;
                
                % total number of detections: column 1
                posSeg=find(clickTimes(:,1)>segStart & clickTimes(:,1)<segEnd);
                seg75s(iraw,1) = length(posSeg);
                
                % total number of detections after discrimination: column 2
                posSegValid=find(clickTimes(validClicks,1)>segStart & clickTimes(validClicks,1)<segEnd);
                seg75s(iraw,2) = length(posSegValid);
                
                % track index of valid clicks per each 75s-segment
                validClicksSeg{iraw} = validClicks(posSegValid)';
            end
            % proportion of valid clicks per segment
            seg75s(:,3) = seg75s(:,2)./seg75s(:,1);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Prune out segments that do not meet the requirements
            idxGoodSeg = [seg75s(:,1) > thr.minClickSeg,...
                seg75s(:,3) >= thr.percValidSeg];
            
            validSeg = find(all(idxGoodSeg,2));
            
            if ~isempty(validSeg)
                % combine valid index of clicks from valid segments
                keepClicks = horzcat(validClicksSeg{validSeg})';
            else
                keepClicks = [];
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Apply extra discrimination to the remaining valid clicks
            if thr.extraPrune && ~isempty(keepClicks)
                % preallocate
                nDurEnv = zeros(length(keepClicks),1);
                deltaEnv = zeros(length(keepClicks),1);
                idxGoodRemain = nan(length(keepClicks),3);
                parfor k = 1:length(keepClicks)
                    NyFiltBuff = length(yFiltBuff{keepClicks(k)});
                    durSamples = floor(durClick(keepClicks(k))/1000*hdr.fs);
                    if durSamples <= NyFiltBuff
                        buffer = floor((NyFiltBuff - durSamples)/2);
                    elseif durSamples == NyFiltBuff
                        buffer = 1;
                    else % weird cases where NyFiltBuff is shorter than durSamples
                        buffer = 1;
                        durSamples = NyFiltBuff;
                    end
                    yFilt = yFiltBuff{keepClicks(k)}(buffer:buffer+durSamples-1); % remove buffer time
                    
                    % calculate click envelope (Au 1993, S.178, equation 9-4)
                    % and normalize it
                    env = abs(hilbert(yFilt));
                    env = env - min(env);
                    env = env/max(env);
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Determine if the slope of the envelope is positive or negative
                    % above x% energy
                    aboveThr = find(env>=thr.energyThr);
                    direction = nan(1,length(aboveThr));
                    for a = 1:length(aboveThr)
                        if aboveThr(a)>1 && aboveThr(a)<length(env)
                            % if it's not the first or last element fo the envelope, then
                            % -1 is for negative slope, +1 is for + slope
                            delta = env(aboveThr(a)+1)-env(aboveThr(a));
                            if delta>=0
                                direction(a) = 1;
                            else
                                direction(a) = -1;
                            end
                        elseif aboveThr(a) == 1
                            % if you're looking at the first element of the envelope
                            % above the energy threshold, consider slope to be negative
                            direction(a) = -1;
                        else  % if you're looking at the last element of the envelope
                            % above the energy threshold, consider slope to be positive
                            direction(a) = 1;
                        end
                    end
                    
                    % find the first value above threshold with positive slope and find
                    % the last above with negative slope
                    lowIdx = aboveThr(find(direction,1,'first'));
                    negative = find(direction==-1);
                    if isempty(negative)
                        highIdx = aboveThr(length(aboveThr));
                    else
                        highIdx = aboveThr(negative(length(negative)));
                    end
                    nDurEnv = highIdx - lowIdx + 1;
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Compare maximum of first 20 points with maximum of 30-40
                    % points
                    if length(env) < 26
                        deltaEnv = -1;
                    else
                        env1max = max(env(1:20));
                        maxPoint = 70;% used to be 25:70
                        if length(env)< maxPoint
                            maxPoint = length(env);
                        end
                        env2max = max(env(25:maxPoint));
                        deltaEnv = env2max-env1max;
                    end
                    
                    % Prune out remaining valid clicks that do not meet the requirements
                    idxGoodRemain(k,:) = [deltaEnv >= thr.deltaEnv,...
                        nDurEnv > (thr.shortDurEnv/1000*hdr.fs),...
                        nDurEnv <= (thr.longDurEnv/1000*hdr.fs)];
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                validKeep = all(idxGoodRemain,2);
                
                % Possible beaked whale clicks
                bwClicks = keepClicks(validKeep);
            else
                %Possible beaked whale clicks
                bwClicks = keepClicks;
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%% SAVE TO TPWS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Take valid beaked whale clicks and save them into a format for use in
        % detEdit
        
        if ~isempty(bwClicks)
            % Prune out clicks below RLpp threshold
            keepers = ppSignal(bwClicks) >= p.ppThresh;
            goodBwClicks = bwClicks(keepers);
            
            % remove repeated clicks
            [~,unicClicks] = unique(clickTimes(goodBwClicks,1));
            goodBwClicks = goodBwClicks(unicClicks);
            
            % find end of array to save in TPWS file
            matIdxEnd = matIdxStart+size(clickTimes(goodBwClicks),1)-1;
            
            % Populate DetEdit files: detection times are formated to datenum,
            % click timeseries are aligned by maximum cycle
            % MTT - start time of clicks: convert times to datenum format
            fileStart = datenum(hdr.start.dvec);
            if fileStart< datenum([2000,0,0])
                fileStart = fileStart + datenum([2000,0,0,0,0,0]);
            end
            MTT = (clickTimes(goodBwClicks,1)/(60*60*24)) + fileStart;
            
            % MPP - peak-to-peak received levels of clicks
            MPP = ppSignal(goodBwClicks);
            
            % MSP - spectra of clicks
            if iscell(specClickTf)
                spv = cell2mat(specClickTf');
                MSP = spv(:,goodBwClicks)';
            else
                MSP = specClickTf(goodBwClicks,:);
            end
            
            % MSN - timeseries of clicks: align click to maximum cycle
            tsVec = zeros(length(goodBwClicks),tsWin);
            for iTS = 1:length(goodBwClicks)
                thisClick = yFiltBuff{goodBwClicks(iTS)};
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
            MSN = tsVec;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Save TPWS file
            % If it reaches maximum rows per file, data is stored in multiple files
            if matIdxStart == 1 % first click in TPWS, then create file
                ttppOutName =  [fullfile(outDir,outName),'_BeakedWhale_TPWS1','.mat'];
                f = fSave;
                fprintf('Saving file: %s\n',ttppOutName)
                save(ttppOutName,'MTT','MPP','MSP','MSN','f','-v7.3')
                subTP = 1; % make sure first TPWS file is with no letter
            elseif matIdxEnd >= p.maxRows
                ttppOutName = [fullfile(outDir,outName),char(letterCode(subTP)),'_BeakedWhale_TPWS1','.mat'];
                f = fSave;
                fprintf('Saving file: %s\n',ttppOutName)
                save(ttppOutName,'MTT','MPP','MSP','MSN','f','-v7.3')
                subTP = subTP+1;
                %letterFlag = 1;
                matIdxEnd = length(MTT); % reassign number of clicks in new TPWS file
            else
                % append data to TPWS file if less than maximum rows per file
                TPWS = matfile(ttppOutName,'Writable',true); % enable write access to file
                fprintf('Appending data to file: %s\n',ttppOutName)
                TPWS.MTT(matIdxStart:matIdxEnd,1) = MTT;
                TPWS.MPP(matIdxStart:matIdxEnd,1) = MPP;
                TPWS.MSP(matIdxStart:matIdxEnd,:) = MSP;
                TPWS.MSN(matIdxStart:matIdxEnd,:) = MSN;
            end
            
            matIdxStart = matIdxEnd+1;
            MTT = [];
            MPP = [];
            MSN = [];
            MSP = [];
        end
        varList = {'hdr';'clickTimes';'specClickTf';'ppSignal';'yFiltBuff'};
        clear(varList{:});
        fprintf('Done with file %d of %d\n',itr2,lfs)
        
    catch
        fprintf('Cannot read file:%s \n',char(fullfile(inDir,thisFile)))
    end
end