function ag_airgun_detector(varargin)

parm = varargin{1}; %parm = REMORA.ag.detect_params

SearchFileMask = {'*.wav'};
SearchPathMask = parm.baseDir;
SearchRecursiv = parm.recursSearch;

currentPath = mfilename('fullpath');
templateFilePath = fileparts(currentPath);
templateFile = fullfile(templateFilePath,'air_template_df100.mat');

if ~isdir(parm.outDir)
    mkdir(parm.outDir)
end

[PathFileList, FileList, PathList] = ...
    ag_utFindFiles(SearchFileMask, SearchPathMask, SearchRecursiv);

templateStruct = load(templateFile);
template = templateStruct.DATA;
pre_env_temp=hilbert(template');
env_temp=sqrt((real(pre_env_temp)).^2+(imag(pre_env_temp)).^2); % Au 1993, S.178, equation 9-4.
%% find start times from each file for Sound Trap data
RegDate = '(?<yr>\d\d)(?<mon>\d\d)(?<day>\d\d)(?<hr>\d\d)(?<min>\d\d)(?<s>\d\d)';
fileDates = dateregexp(FileList,RegDate);
%%

for fidx = 1:size(FileList,1) % Make sure to change the start of the file list so that it begins with the first file.
    file = FileList{fidx};
    path = PathList{fidx};
    filepath = fullfile(path,file);
    
    display(['calculating ',file,'; file ',num2str(fidx),'/',num2str(size(FileList),1)])
    rawStart = fileDates(fidx);
    I = audioinfo(filepath);
    rawDur = I.Duration;
    block = 75; % s - same as HARP file size to keep things even
        
    step = block*I.SampleRate;
    inc = ceil(rawDur/block);
    t = 0:rawDur/(step-1):rawDur;
    
    % Lowpass filter y:
    % Fc1 = 1;   % First Cutoff Frequency
    Fc2 = 150;  % Second Cutoff Frequency
    
    N = 10;     % Order
    [B,A] = butter(N/2, Fc2/(I.SampleRate/2),'low');
    
    allSmpPts = [];
    allExp = [];
    allCorrVal = [];
    allDur = [];
    allRmsNBefore = [];
    allRmsNAfter = [];
    allRmsDet = [];
    allPpNBefore = [];
    allPpNAfter = [];
    allPpDet = [];
    
    allX = [];
    
    fileAudioInfo = audioinfo(filepath); % Added when the sample size is too small.
    fileSampleNum = fileAudioInfo.TotalSamples;
    
    for idx = 1:inc
        display(['start of segment ',num2str(idx),'/',num2str(inc)])
        segStart = datenum(rawStart(fidx,:))+ datenum([0 0 0 0 0 ((idx-1)*75)]);
        start = (idx-1)*step + 1;
        stop = idx*step;
        
        if start>=fileSampleNum ||stop>fileSampleNum
            warning('File has fewer than expected samples. Continuing to next xwav.');
            continue
        end % Added when the sample size is too small.
        
        [y, ~] = audioread(filepath,[start stop]);
        % Filter between 200 and 2000 Hz:
        yFilt = filtfilt(B,A,y); % Filter click.
        fprintf('max = %0.3f\n',max(yFilt))
        % If max(yFilt)>= 0.005:
        pre_env_y=hilbert(yFilt.');
        env_y=sqrt((real(pre_env_y)).^2+(imag(pre_env_y)).^2);
        
        % Calculate cross correlation with template explosion:
        c = xcorr(env_y,env_temp);
        c(1:step-1) = [];
        
        c2 = c.*c;
        
        % Calculate floating threshold:
        medianC2 = prctile(c2,50);
        threshold_c2 = medianC2 + (medianC2*parm.c2_offset);
        thr2 = ones(length(y),1)*threshold_c2;
        if parm.plotOn
            
            figure(1)
            subplot(2,1,1)
            plot(yFilt)
            subplot(2,1,2)
            plot(c2), hold on
            plot(thr2,'r'), hold off
            drawnow
        end
        
        % Find correlation coefficient above threshold:
        above = [];
        breakP = [];
        dateExp = [];
        above = find(abs(c2)>threshold_c2); % Returns all indices above threshold.
        
        durExp = [];
        expConv = [];
        expTimes = [];
        yNBefore = [];
        yNAfter = [];
        yDet = [];
        dateConv = [];
        dateExp = [];
        corrVal = [];
        
        if ~isempty(above)
            % Determine breaks between explosions:
            diffAbove = diff(above);
            breakP = find(diffAbove > parm.diff_s*I.SampleRate); % Separates explosions by 0.5 seconds.
            % Determine start and end index for each explosion.
            for eidx = 1:length(breakP)+1
                if eidx == 1
                    expstart = above(1);
                else
                    expstart = above(breakP(eidx-1)+1);
                end
                if eidx == length(breakP)+1
                    expstop = above(end);
                else
                    expstop = above(breakP(eidx));
                end
                % Find maximum within correlation:
                expConv(eidx,1) = expstart;
                expConv(eidx,2) = expstop;
                corrVal(eidx,1) = max(c2(expstart:expstop));
                corrVal(eidx,2) = medianC2;
            end
            
            if ~isempty(expConv)
                smpPts = [];
                dateExp = [];
                durExp = [];
                rmsNBefore = [];
                rmsNAfter = [];
                rmsDet = [];
                ppNBefore = [];
                ppNAfter = [];
                ppDet = [];
                for eidx = 1:size(expConv,1)
                    % Pull out signal of the length of template, relative
                    % to when convolusion starts being above threshold.
                    s = expConv(eidx,1); % +1+round(length(template)*0.5);
                    e = expConv(eidx,2);% +round(length(template)*0.5);%-length(template)/2.
                        hold on; plot(s,c2(s),'ro');plot(e,c2(e),'ko');hold off
                end
                    % Check if s is before segment starts.
                    if (e-s) < (I.SampleRate*parm.durShort_s)
                        continue
                    elseif s<1
                        % Get signal and pad before
                        % pad = ones(abs(s)+1,1)*eps;
                        s = 1;
                    elseif e>length(yFilt)
                        % Get signal and pad after
                        % pad = ones(e-length(yFilt),1)*eps;
                        e = length(yFilt);
                    end
                    yDet = yFilt(s:e);
                    
                    % Get noise after signal.
                    eAfter = e + parm.nSamples;
                    
                    if eAfter>length(yFilt)
                        eAfter = length(yFilt);
                    end
                    
                    yNAfter = yFilt((e+1):eAfter);
                    
                    % Get noise before signal.
                    sBefore = s - (parm.nSamples);
                    if sBefore<1
                        sBefore = 1;
                    end

                    yNBefore = yFilt(sBefore:(s-1));
                                        
                    if isempty(yNBefore)
                        yNBefore = eps;
                    end
                    
                    % Extract envelope for this detection.
                    env = env_y(s:e);
                    
                    avg_env = zeros(length(env),1);
                    win = 300;
                    for a = 1:length(env)-win
                        avg_env(a) = mean(env(a:a+win));
                    end
                    avg_env_dB = 10*log10(avg_env);
                    med_avg_env = prctile(avg_env,50);
                    med_avg_env_dB = 10*log10(med_avg_env);
                    durThr_dB = 2;
                    thr_avg_env_dB = med_avg_env_dB + durThr_dB;
                    maedb = ones(length(avg_env_dB),1)*med_avg_env_dB;
                    thraedb = ones(length(avg_env_dB),1)*thr_avg_env_dB;
                    aboveEnvAll = find(avg_env_dB >= thr_avg_env_dB);
                    
                    
                    if ~isempty(aboveEnvAll)
                        diffAboveEnv = diff(aboveEnvAll);
                        dist = 600;
                        stopDiff = find(diffAboveEnv>=dist,1,'first');
                        
                        if ~isempty(stopDiff)
                            above_env = aboveEnvAll(1);
                            below_env = aboveEnvAll(stopDiff);
                        else
                            above_env = aboveEnvAll(1);
                            below_env = aboveEnvAll(end);
                        end
                        
                        startIdx = above_env + round(win/2);
                        endIdx = below_env + round(win/2);
                    else
                        startIdx = 1;
                        above_env = 1;
                        endIdx = length(env);
                        below_env = length(env);
                    end
                    
                    expTimes = [];
                    expTimes(1) = s;% s-1+startIdx.
                    expTimes(2) = e;% s-1+endIdx.
                    
                    
                    % Calculate parameters to delete.
                    % Calculate pp amplitude.
                    
                    highDet=max(yDet.');
                    lowDet=min(yDet.');
                    ppDetSeg=highDet+abs(lowDet);
                    ppDetSeg=20*log10(ppDetSeg);
                    
                    highNAfter=max(yNAfter.');
                    lowNAfter=min(yNAfter.');
                    ppNAfterSeg=highNAfter+abs(lowNAfter);
                    ppNAfterSeg=20*log10(ppNAfterSeg);
                    
                    highNBefore=max(yNBefore.');
                    lowNBefore=min(yNBefore.');
                    ppNBeforeSeg=highNBefore+abs(lowNBefore);
                    ppNBeforeSeg=20*log10(ppNBeforeSeg);
                    
                    % Calculate rms amplitude.
                    
                    n = length(yDet);
                    yrmsDet = sqrt(sum(yDet.*yDet)/n);
                    rmsDetSeg = 20*log10(yrmsDet);
                    
                    n = length(yNAfter);
                    yrmsNAfter = sqrt(sum(yNAfter.*yNAfter)/n);
                    rmsNAfterSeg = 20*log10(yrmsNAfter);
                    
                    n = length(yNBefore);
                    yrmsNBefore = sqrt(sum(yNBefore.*yNBefore)/n);
                    rmsNBeforeSeg = 20*log10(yrmsNBefore);
                    
                    % Calculate duration.
                    
                    durSeg = (expTimes(2) - expTimes(1))/I.SampleRate;
                    
                    % Calculate delta / signal to noise in rms and pp.
                   
                    drmsAS = abs(rmsDetSeg - rmsNAfterSeg);
                    dppAS = abs(ppDetSeg - ppNAfterSeg);
                    drmsBS = rmsDetSeg - rmsNBeforeSeg;
                    dppBS = ppDetSeg - ppNBeforeSeg;
                    
                    % Eliminate for signal vs. noise after signal and
                    % duration.
                    delRmsAS = find(drmsAS<parm.rmsAS);
                    delPpAS = find(dppAS<parm.ppAS);
                    delRmsBS = find(drmsBS<parm.rmsBS);
                    delPpBS = find(dppBS<parm.ppBS);
                    delDur = find(durSeg>=parm.durLong_s | durSeg<=parm.durShort_s);
                    
                    delUnion = unique([delRmsAS;delPpAS;delRmsBS;delPpBS;delDur]);
                    
                    % Delete false detections.
                    
                    expTimes(delUnion,:) = [];
                    corrVal(delUnion,:) = [];
                    durSeg(delUnion) = [];
                    rmsNBeforeSeg(delUnion) = [];
                    rmsNAfterSeg(delUnion) = [];
                    rmsDetSeg(delUnion) = [];
                    ppNBeforeSeg(delUnion) = [];
                    ppNAfterSeg(delUnion) = [];
                    ppDetSeg(delUnion) = [];
                    if parm.plotOn && ~isempty(expTimes)
                        hold on; plot(expTimes(1),c2(expTimes(1)),'rx');...
                            plot(expTimes(2),c2(expTimes(2)),'kx');hold off
                    end
                    if ~isempty(expTimes)
                        % Convert samples of segment into samples of file:
                        smpPtsSeg = expTimes + start - 1;
                        % Return explosion times:
                        secExp = (expTimes/I.SampleRate)/(60*60*24);
                        dTimes = secExp + segStart;
                        % Add to save:
                        smpPts = [smpPts;smpPtsSeg];
                        dateExp = [dateExp; dTimes];
                        durExp = [durExp; durSeg];
                        rmsNBefore = [rmsNBefore; rmsNBeforeSeg];
                        rmsNAfter = [rmsNAfter; rmsNAfterSeg];
                        rmsDet = [rmsDet; rmsDetSeg];
                        ppNBefore = [ppNBefore; ppNBeforeSeg];
                        ppNAfter = [ppNAfter; ppNAfterSeg];
                        ppDet = [ppDet; ppDetSeg];
                    end
                end
                
                allSmpPts = [allSmpPts; smpPts];
                allExp = [allExp; dateExp];
                allCorrVal = [allCorrVal; corrVal];
                allDur = [allDur; durExp];
                allRmsNBefore = [allRmsNBefore; rmsNBefore];
                allRmsNAfter = [allRmsNAfter; rmsNAfter];
                allRmsDet = [allRmsDet; rmsDet];
                allPpNBefore = [allPpNBefore; ppNBefore];
                allPpNAfter = [allPpNAfter; ppNAfter];
                allPpDet = [allPpDet; ppDet];
                1;
        end
    end

    
    if ~isempty(allExp)
        bt = [];
        bt(:,1) = allSmpPts(:,1)-5000;
        bt(:,2) = allSmpPts(:,2)+5000;
        bt(:,3) = zeros(size(allSmpPts,1),1);
        bt(:,4) = allExp(:,1);
        bt(:,5) = allExp(:,2);
        
        fend = strfind(file,'.df100');
        if isempty(fend)
            fend = strfind(file,'.wav');
        end
        newFile = fullfile(parm.outDir,[file(1:fend-1),'.mat']);
        save(newFile,'allSmpPts','allExp','allCorrVal','allDur',...
            'allRmsNBefore','allRmsNAfter','allRmsDet','allPpNBefore',...
            'allPpNAfter','allPpDet','rawStart','rawDur','parm','bt','-v7.3');
    else
        bt = [];
        fend = strfind(file,'.df100');
        if isempty(fend)
            fend = strfind(file,'.x.wav');
        end
        newFile = fullfile(parm.outDir,[file(1:fend-1),'.mat']);
        save(newFile,'allSmpPts','allExp','allCorrVal','allDur',...
            'allRmsNBefore','allRmsNAfter','allRmsDet','allPpNBefore',...
            'allPpNAfter','allPpDet','rawStart','rawDur','parm','bt','-v7.3');
    end
end
end