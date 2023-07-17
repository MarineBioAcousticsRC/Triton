function [clickParamsOut,fOut] = sp_dt_batch(fullFiles,fullLabels,p,encounterTimes,runMode)


N = size(fullFiles,1);
p.previousFs = 0; % make sure we build filters on first pass
p.plot = 0;
% get file type list
fTypes = sp_io_getFileType(fullFiles);
fOut = [];
clickParamsOut = [];


% check if there is a current parallel pool and apply the number of workers
% specified. If a pool exsists, uptate the specified number of workers
poolobj = gcp('nocreate'); % returns the current pool, if not empty

if isempty(poolobj)
    if isfield(p,'parpool')
        parpool(p.parpool)
    else
        parpool(1);
    end
else
    % if number of workers specified is different from the existing pool,
    % deletes the current one and creates a new one with the specified
    % number of workers
    if poolobj.NumWorkers ~= p.parpool
        disp('Shutting down current pool to update number of workers')
        delete(gcp('nocreate'))
        parpool(p.parpool)
    end
end
    


parfor idx1 = 1:N % for each data file
    f=[];
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
    try
        hdr = sp_io_readXWAVHeader(fullFiles{idx1}, pTemp,'fType', fTypes(idx1));
    catch
        fprintf('Problem reading file %s\n',fullFiles{idx1})
        hdr = [];
    end
   
    
    if isempty(hdr)
        warning('No header info returned for file %s',currentRecFile);
        disp('Moving on to next file')
        continue % skip if you couldn't read a header
        % Read the file header info
    else
        if fTypes(idx1) == 1
            [startsSec,stopsSec,pTemp] = sp_dt_LR_chooseSegments(pTemp,hdr);
        else
            % divide xwav by raw file
            [startsSec,stopsSec] = sp_dt_chooseSegmentsRaw(hdr);
        end
        
    end
    
    if hdr.fs ~= pTemp.previousFs
        % otherwise, if this is the first time through, build your filters,
        % only need to do this once though, so if you already have this
        % info, this step is skipped
        
        [previousFs,pTemp] = sp_fn_buildFilters(pTemp,hdr.fs);
        
         pTemp.previousFs = previousFs;
         pTemp = sp_fn_interp_tf(pTemp);
         % make TF-based filter
         if pTemp.whiten
             %% TO DO: Make version of TF for filtering that starts at 0kHz
             pTemp = sp_fn_build_whitening_filter(pTemp,hdr);
            
             if pTemp.plot
                 hfvt = fvtool(Hd1,'Fs', hdr.fs,'Color','White');
             end
         end
         if ~isfield(pTemp,'countThresh') || isempty(pTemp.countThresh)
            pTemp = sp_dt_set_count_threshold(pTemp);
         end
    end
    
    cParams = sp_dt_init_cParams(pTemp); % set up storage for HR output.
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
        if pTemp.plot
            figure(102);colormap(jet)
            [~,fOut,t,psdFilt] = spectrogram(filtData,hdr.fs/10,50,hdr.fs/10,hdr.fs);
            imagesc(t,fOut/1000,log10(psdFilt))
            set(gca,'ydir','normal')
            colorbar
            set(gca,'clim',[-5,5])
        end
        if pTemp.whiten
            filtData = step(pTemp.Hd1,filtData')';
            if pTemp.plot
                figure(103);colormap(jet)
                [~,fOut,t,psdFilt] = spectrogram(filtData,hdr.fs/10,50,hdr.fs/10,hdr.fs);
                imagesc(t,fOut/1000,log10(psdFilt))
                set(gca,'ydir','normal')
                colorbar
                set(gca,'clim',[-5,5])
            end
        end
        energy = filtData.^2;
        if pTemp.plot
            figure(104);clf
            subplot(1,2,1)
            plot(filtData); ylabel('counts')
            hold on
            plot(ones(size(filtData))*(pTemp.countThresh))
            subplot(1,2,2)
            semilogy(energy); ylabel('energy (counts^2)')
            hold on
            semilogy(ones(size(energy))*(pTemp.countThresh.^2))
            myLim = get(gca,'ylim');
            ylim([1,myLim(2)])
        end
        %%% Run LR detection to identify candidates
        [detectionsSample,detectionsSec] =  sp_dt_LR(energy,hdr,buffSamples,...
            startK,stopK,pTemp);

        %%% start HR detection on candidates
        for iD = 1:size(detectionsSample,1)
            filtSegment = filtData(detectionsSample(iD,1):detectionsSample(iD,2));
            [clicks, noise] = sp_dt_HR(pTemp, hdr, filtSegment);
            
            if ~ isempty(clicks)
                % if we're in here, it's because we detected one or more possible
                % clicks in the kth segment of data
                % Make sure our click candidates aren't clipped
                validClicks = sp_dt_pruneClipping(clicks,pTemp,hdr,filtSegment);
                
                % Look at power spectrum of clicks, and remove those that don't
                % meet peak frequency and bandwidth requirements
                clicks = clicks(validClicks==1,:);
                
                if isempty(clicks)
                    continue % go to next iteration if no clicks remain.
                end
                
                % Compute click parameters to decide if the detection should be kept
                [clickDets,f] = sp_dt_parameters(noise,filtSegment,pTemp,clicks,hdr);
                
                if ~isempty(clickDets.clickInd)
                    % populate cParams
                    [cParams,sIdx] = sp_dt_populate_cParams(clicks,noise,pTemp,...
                        clickDets,detectionsSec(iD,1),hdr,sIdx,cParams);
                end
            end
        end
    end
    fclose(fid);
    
    % fclose all;
    fprintf('done with %s\n', currentRecFile);
    
    cParams = sp_dt_prune_cParams(cParams,sIdx);
    
    % Run post processing to remove rogue loner clicks, prior to writing
    % the remaining output files.
    clickTimes = sortrows(cParams.clickTimes);
    
    keepFlag = sp_dt_postproc(outFileName,clickTimes,pTemp,hdr,encounterTimes);
    keepIdx = find(keepFlag==1);
    cParams = sp_dt_prune_cParams_byIdx(cParams,keepIdx);
    
    if strcmp(runMode,'guiRun')
%         clickParamsOut{1} = cParams;
%         fOut{1} = f;
    end
    sp_fn_saveDets2mat(strrep(outFileName,['.',p.ppExt],'.mat'),cParams,f,hdr,pTemp);
    if pTemp.plot
        figure(105);clf
        hist(cParams.ppSignalVec,100)
        hold on;xlabel('Amplitude (db_P_P)')
        ylabel('Counts')
        myYLim = get(gca,'ylim');
        plot([pTemp.dBppThreshold,pTemp.dBppThreshold],[myYLim(1),myYLim(2)],'r')
        figure(106);clf
        s2 = scatter(cParams.ppSignalVec,cParams.peakFrVec,'.k');
        s2.MarkerEdgeAlpha = 0.2;
        ylabel('Peak Frequency');  xlabel('Amplitude (dB_P_P)')
        hold on; myYLim = get(gca,'ylim');
        plot([pTemp.dBppThreshold,pTemp.dBppThreshold],[myYLim(1),myYLim(2)],'r')
    end
end

