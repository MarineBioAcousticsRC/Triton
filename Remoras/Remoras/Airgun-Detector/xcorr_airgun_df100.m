function  xcorr_airgun_df100

%pull in all xwavs of a folder and subfolder to run matched filter detector
%for explosions

%parm stores parameters, to be used in TethysXML output
parm.threshold = 0.003; %threshold for correlation coefficient
parm.c2_offset = 0.1; %threshold offset above median square of correlation coefficient
parm.diff_s = 2; %minimum time distance between consecutive explosions (was .05)
parm.nSamples = 2000; %number of noise samples to be pulled out
parm.rmsAS = .5; %rms noise after signal <rmsAS (dB) difference will be eliminated
parm.rmsBS = .5; %rms noise before signal
parm.ppAS = .5; %pp noise after signal <ppAS (dB) difference will be eliminated
parm.ppBS = .5; %pp noise before signal
parm.durLong_s = 10; %duration >= durAfter_s (s) will be eliminated
parm.durShort_s = .5; %duration >= dur_s (s) will be eliminated


BaseDir = 'G:\TempData\WAT_BS_01_df100';
outputDir = 'G:\Western Atlantic\WAT_2018_Airguns\WAT_BS_01_Airguns';
mkdir(outputDir)
templateFile = 'D:\Code\Airgun Detector\air_template_df100.mat';
plotOn = 0; % turn to 0 to suppress plots; 1 for plots
DetDir = outputDir;

SearchFileMask = {'*df100.x.wav'};
SearchPathMask = {BaseDir};
SearchRecursiv = 1; % Setting to 1 searches through all subfolders in the selected folder, setting to 0 only searches the selected folder.

[PathFileList, FileList, PathList] = ...
    utFindFiles(SearchFileMask, SearchPathMask, SearchRecursiv);

templateStruct = load(templateFile);
template = templateStruct.DATA;
pre_env_temp=hilbert(template');
env_temp=sqrt((real(pre_env_temp)).^2+(imag(pre_env_temp)).^2); %Au 1993, S.178, equation 9-4

for fidx = 1:size(FileList,1) % Make sure to change the start of the file list so that it begins with the first file
    % and not the file indicated!
    %     cd(BaseDir)
    file = FileList{fidx};
    path = PathList{fidx};
    filepath = fullfile(path,file);
    
    display(['calculating ',file,'; file ',num2str(fidx),'/',num2str(size(FileList),1)])
    rawStart=[];
    rawDur=[];
    [rawStart,rawDur,fs] = readxwavhd(filepath);
    
    %%%%%%%%%%%%%%%%%%%!!!!!!!!!!!!!!!!!!! Problematic when timing errors
    %%%%%%%%%%%%%%%%%%%or higher sampling size and shorter rawDur!!!!!!!!
    %     siz = wavread(filepath,'size');   suggested by Bruce
    %Implemented change "that allows for any sampling rate instead of
    %a fixed 10kHz sampling rate that it was originally written for"
    step = rawDur(1)*fs;
    inc = size(rawStart,1);
    t = 0:rawDur(1)/(step-1):rawDur(1);
    
    % lowpass filter y
    % Fc1 = 1;   % First Cutoff Frequency
    Fc2 = 150;  % Second Cutoff Frequency
    
    N = 10;     % Order
    [B,A] = butter(N/2, Fc2/(fs/2),'low');
    
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
    %     filterstate = zeros(length(template)-1,1);
    
    fileAudioInfo = audioinfo(filepath); % Added from explosion code when the sample size is too small (Macey - 2/13/2018).
    fileSampleNum = fileAudioInfo.TotalSamples;
    
    for idx = 1:inc
        display(['start of segment ',num2str(idx),'/',num2str(inc)])
        segStart = datenum(rawStart(idx,:));
        start = (idx-1)*step + 1;
        stop = idx*step;
        
        if start>=fileSampleNum ||stop>fileSampleNum
            warning('File has fewer than expected samples. Continuing to next xwav.');
            continue
        end % Added from explosion code when the sample size is too small (Macey - 2/13/2018).
        
        y = wavread(filepath,[start stop]);
        %filter between 200 and 2000 Hz
        yFilt = filtfilt(B,A,y); %filter click
        fprintf('max = %0.3f\n',max(yFilt))
        % if max(yFilt)>= 0.005
        pre_env_y=hilbert(yFilt.');
        env_y=sqrt((real(pre_env_y)).^2+(imag(pre_env_y)).^2); %Au 1993, S.178, equation 9-4
        
        %calculate cross correlation with template explosion
        %         [c, filterstate] = filter(env_temp,1,env_y,filterstate);
        c = xcorr(env_y,env_temp);
        c(1:step-1) = [];
        
        c2 = c.*c;
        
        %calculate floating threshold
        medianC2 = prctile(c2,50);
        threshold_c2 = medianC2 + (medianC2*parm.c2_offset);
        %         thr = ones(length(y),1)*threshold;
        thr2 = ones(length(y),1)*threshold_c2;
        if plotOn
            
            figure(1)
            subplot(2,1,1)
            plot(yFilt)
            subplot(2,1,2)
            plot(c2), hold on
            plot(thr2,'r'), hold off
        end
        
        % find correlation coefficient above threshold
        above = [];
        breakP = [];
        dateExp = [];
        above = find(abs(c2)>threshold_c2); %returns all indices above threshold
        
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
            %determine breaks between explosions
            diffAbove = diff(above);
            breakP = find(diffAbove > parm.diff_s*fs); %separates explosions by 0.5s
            %determine start and end index for each explosion
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
                %find maximum within correlation
                expConv(eidx,1) = expstart;
                expConv(eidx,2) = expstop;
                %                 corrVal(eidx,1) = max(c(expstart:expstop));
                corrVal(eidx,1) = max(c2(expstart:expstop));
                corrVal(eidx,2) = medianC2;
            end
            
            %             %eliminate detections of disk write between 5000-7000,
            %             %38500-40500, 111000-123000
            %             dw{1} = 5001:1:7000;
            %             dw{2} = 38501:1:40500;
            %             dw{3} = 111001:1:135000;
            %
            %             nDW = find(expConv(:,1)<150000);
            %             delAll = [];
            %             for l = 1:length(nDW)
            %                 dwDet = expConv(nDW(l),1):1:expConv(nDW(l),2);
            %                 for a = 1:3
            %                     del = intersect(dwDet,dw{a});
            %                     if ~isempty(del)
            %                         delAll = [delAll nDW(l)];
            %                     end
            %                 end
            %             end
            %
            %             expConv(delAll,:) = [];
            %             corrVal(delAll,:) = [];
            
            %pull out noise before and after signal,
            %define start and end of signals
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
                    %pull out signal of the length of template, relative to
                    %when convolusion starts being above threshold
                    s = expConv(eidx,1);%+1+round(length(template)*0.5);
                    e = expConv(eidx,2);%+round(length(template)*0.5);%-length(template)/2;  %AJD changed 1.2 to 1.5 7/13/2016
                    if plotOn
                        hold on; plot(s,c2(s),'ro');plot(e,c2(e),'ko');hold off
                    end
                    %check if s is before segment starts
                    if (e-s) < (fs*parm.durShort_s)
                        continue
                    elseif s<1
                        % get signal and pad before
                        % pad = ones(abs(s)+1,1)*eps;
                        s = 1;
                    elseif e>length(yFilt)
                        %get signal and pad after
                        % pad = ones(e-length(yFilt),1)*eps;
                        e = length(yFilt);
                    end
                    yDet = yFilt(s:e);
                    
                    %get noise after signal
                    eAfter = e + parm.nSamples;
                    
                    if eAfter>length(yFilt)
                        eAfter = length(yFilt);
                    end
                    
                    yNAfter = yFilt((e+1):eAfter);
                    
                    %get noise before signal
                    sBefore = s - (parm.nSamples);
                    if sBefore<1
                        sBefore = 1;
                    end

                    yNBefore = yFilt(sBefore:(s-1));
                                        
                    if isempty(yNBefore)
                        yNBefore = eps;
                    end
                    
                    %extract envelope for this detection
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
                    
                    % aboveEnvAll = find(avg_env_dB(round(length(template)*0.2)-100:...
                    %   end) >= thr_avg_env_dB)+round(length(template)*0.2)-101;
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
                    expTimes(1) = s;%s-1+startIdx;
                    expTimes(2) = e;%s-1+endIdx;
                    
                    
                    %calculate parameters to delete
                    %calculate pp amplitude
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
                    
                    %caclulate rms amplitude
                    n = length(yDet);
                    yrmsDet = sqrt(sum(yDet.*yDet)/n);
                    rmsDetSeg = 20*log10(yrmsDet);
                    
                    n = length(yNAfter);
                    yrmsNAfter = sqrt(sum(yNAfter.*yNAfter)/n);
                    rmsNAfterSeg = 20*log10(yrmsNAfter);
                    
                    n = length(yNBefore);
                    yrmsNBefore = sqrt(sum(yNBefore.*yNBefore)/n);
                    rmsNBeforeSeg = 20*log10(yrmsNBefore);
                    
                    %calculate duration
                    durSeg = (expTimes(2) - expTimes(1))/fs;
                    
                    %calculate delta / signal to noise in rms and pp
                   
                    drmsAS = abs(rmsDetSeg - rmsNAfterSeg);
                    dppAS = abs(ppDetSeg - ppNAfterSeg);
                    drmsBS = rmsDetSeg - rmsNBeforeSeg;
                    dppBS = ppDetSeg - ppNBeforeSeg;
                    
                    %eliminate for signal vs. noise after signal and duration
                    delRmsAS = find(drmsAS<parm.rmsAS); %239,028
                    delPpAS = find(dppAS<parm.ppAS); %249,166
                    delRmsBS = find(drmsBS<parm.rmsBS); %214,914
                    delPpBS = find(dppBS<parm.ppBS); %230,409
                    delDur = find(durSeg>=parm.durLong_s | durSeg<=parm.durShort_s); %230,729
                    
                    delUnion = unique([delRmsAS;delPpAS;delRmsBS;delPpBS;delDur]); %276,145
                    
                    %delete false detections
                    expTimes(delUnion,:) = [];
                    corrVal(delUnion,:) = [];
                    durSeg(delUnion) = [];
                    rmsNBeforeSeg(delUnion) = [];
                    rmsNAfterSeg(delUnion) = [];
                    rmsDetSeg(delUnion) = [];
                    ppNBeforeSeg(delUnion) = [];
                    ppNAfterSeg(delUnion) = [];
                    ppDetSeg(delUnion) = [];
                    if plotOn && ~isempty(expTimes)
                        hold on; plot(expTimes(1),c2(expTimes(1)),'rx');...
                            plot(expTimes(2),c2(expTimes(2)),'kx');hold off
                    end
                    if ~isempty(expTimes)
                        %convert samples of segment into samples of file
                        smpPtsSeg = expTimes + start - 1;
                        %return explosion times
                        secExp = (expTimes/fs)/(60*60*24);
                        dTimes = secExp + segStart;
                        %add to save
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
                    
                    
                    %                     figure(2)
                    %                     subplot(3,1,1)
                    %                     plot(yDet), hold on
                    %                     plot(startIdx,0,'r*')
                    %                     plot(endIdx,0,'r*'), hold off
                    %                     title(['segment ',num2str(idx),', detection ',...
                    %                         num2str(eidx),'/', num2str(size(expConv,1)),', ',...
                    %                         datestr(dTimes(1))])
                    
                    %                     subplot(3,1,2)
                    %                     plot(env),hold on
                    %                     plot(startIdx,env(startIdx),'r*')
                    %                     plot(endIdx,env(endIdx),'r*'), hold off
                    %
                    %                     subplot(3,1,3)
                    %                     plot(avg_env_dB), hold on
                    %                     plot(maedb,'r')
                    %                     plot(thraedb,'r')
                    %                     plot(above_env,thr_avg_env_dB,'r*')
                    %                     plot(below_env,thr_avg_env_dB,'r*'), hold off
                    %
                    %
                    %                     1;
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
            % end
        end
        %         thrTimes = zeros(size(expTimes)) * threshold;
        
        %         if ~isempty(expTimes)
        %             subplot(2,1,1)
        %             plot(yFilt,'k'), hold on
        %             plot(expTimes,thrTimes,'*r'), hold off
        %             title([file,', segment ',num2str(idx),', ', datestr(rawStart(idx,:))])
        %             ylabel('relative amplitude','fontsize',10,'fontweight','b')
        %             xlabel('points','fontsize',10,'fontweight','b')
        %             subplot(2,1,2)
        %             plot(c,'k'), hold on
        %
        %             plot(expConv,thrTimes,'*r'), hold off
        %             title([file,', segment ',num2str(idx),', ', datestr(rawStart(idx,:))])
        %             ylabel('convolution output','fontsize',10,'fontweight','b')
        %             xlabel('points','fontsize',10,'fontweight','b')
        %             ylim([-0.001 0.001])
        %             pause
        % %             close
        %         else
        %             display([' segment ',num2str(idx),', no detections'])
        %         end
        
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
            fend = strfind(file,'.x.wav');
        end
        newFile = fullfile(DetDir,[file(1:fend-1),'.mat']);
        save(newFile,'allSmpPts','allExp','allCorrVal','allDur',...
            'allRmsNBefore','allRmsNAfter','allRmsDet','allPpNBefore',...
            'allPpNAfter','allPpDet','rawStart','rawDur','parm','bt','-v7.3');
    else
        bt = [];
        fend = strfind(file,'.df100');
        if isempty(fend)
            fend = strfind(file,'.x.wav');
        end
        newFile = fullfile(DetDir,[file(1:fend-1),'.mat']);
        save(newFile,'allSmpPts','allExp','allCorrVal','allDur',...
            'allRmsNBefore','allRmsNAfter','allRmsDet','allPpNBefore',...
            'allPpNAfter','allPpDet','rawStart','rawDur','parm','bt','-v7.3');
    end
    
end
