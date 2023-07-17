function ct_cc_save_cluster_files(varargin)

global REMORA
spinH = ct_add_spinner(REMORA.fig.ct.cc_saveClust,[0.45,0.45,0.1,0.15]);
spinH.start;drawnow
if (REMORA.ct.CC.output.saveBinLevelDataTF + REMORA.ct.CC.output.saveDetLevelDataTF)==0
    % Nothing was checked. Don't do anything.
    disp('No options checked. Nothing to do.')
    return
elseif isempty(REMORA.ct.CC.output.clustDir)
    error('Please specify an output folder.')
end

% make folders
uNames = unique(REMORA.ct.CC.output.labelStr);
nTypes = length(uNames);
thisName = [];
thisTypeAll = [];

for iF = 1:nTypes
    
    thisName{iF} = uNames{iF};
    newDir{iF} = fullfile(REMORA.ct.CC.output.clustDir,thisName{iF});
    if ~isdir(newDir{iF})
        mkdir(fullfile(REMORA.ct.CC.output.clustDir,thisName{iF}))
    end
    cIdx = find(strcmp(thisName{iF},REMORA.ct.CC.output.labelStr));
    thisTypeAll(iF).clickTimes = REMORA.ct.CC.output.clickTimes(horzcat(REMORA.ct.CC.output.Tfinal{cIdx,8}));
    thisTypeAll(iF).fileNumExpand = REMORA.ct.CC.output.fileNumExpand(horzcat(REMORA.ct.CC.output.Tfinal{cIdx,8}));
    thisTypeAll(iF).Tfinal = vertcat(REMORA.ct.CC.output.Tfinal(cIdx,:)); % This keeps cells apart.
    % Will need to watch out for this later.
    
    thisTypeAll(iF).tIntMat = REMORA.ct.CC.output.tIntMat(horzcat(REMORA.ct.CC.output.Tfinal{cIdx,8}));
end


%fprintf('Saving output for %s...\n',uNames{iF})


if REMORA.ct.CC.output.saveBinLevelDataTF
    for iF = 1:nTypes
        % Find all of the clusters with this name
        % cIdx = find(strcmp(thisName{iF},REMORA.ct.CC.output.labelStr));
        % If bin level, TPWS files are not needed
        % This code just reproduces the individual cluster output files and
        % places them in folders according to the cluster name. If 2 clusters
        % have the same name, they are merged.
        % thisType(iF).clickTimes = REMORA.ct.CC.output.clickTimes(horzcat(REMORA.ct.CC.output.Tfinal{cIdx,8}));

        inFileList = REMORA.ct.CC.output.inFileList;
        
        [~,outputNameRoot,~] = fileparts(REMORA.ct.CC_params.outputName);
        
        binLevelOutputFile = fullfile(newDir,[REMORA.ct.CC_params.outputName,'_', thisName{iF},'_binLevel.mat']);
        
        outputNameRoot = REMORA.ct.CC_params.outputName;
        binLevelOutputFile = fullfile(newDir{iF},[outputNameRoot,'_', thisName{iF},'_binLevel.mat']);
        thisType = thisTypeAll(iF);
        save(binLevelOutputFile,'thisType','inFileList','-v7.3');
        fprintf('Done saving bin-level output for %s...\n',uNames{iF})
    end
end

if REMORA.ct.CC.output.saveDetLevelDataTF
    % if detection level, TPWS files ARE needed
    % iterate over TPWS files. For each cluster type, save one or more files that contain
    % the spectra, waveforms and event times of each detection in that
    % set.
    % uInputFiles = unique(thisType.fileNumExpand);
    thisTPWSList = REMORA.ct.CC.output.TPWSList;%(uInputFiles);
    for iTPWS = 1:length(thisTPWSList)
        if isempty(thisTPWSList{iTPWS}) % JMJ fix added to skip if empty dir entries are in the thisTPWSlist array
            continue
        end
	TPWSname = fullfile(REMORA.ct.CC.output.TPWSDir,thisTPWSList{iTPWS});
        
	load(TPWSname,'MTT');
        MSN = [];
        MSP = [];
        fprintf('Loading data from %s...\n',TPWSname)
        for iF = 1:nTypes
            %cIdx = find(strcmp(thisName{iF},REMORA.ct.CC.output.labelStr));
            
            % thisType.clickTimes = REMORA.ct.CC.output.clickTimes(horzcat(REMORA.ct.CC.output.Tfinal{cIdx,8}));
             
            trainTimes = vertcat(thisTypeAll(iF).clickTimes{(thisTypeAll(iF).fileNumExpand...
                == iTPWS)});
            [~,I] = intersect(MTT,trainTimes);
            if isempty(I)
                % don't bother loading the big matrices if there are no
                % matching times
                continue
            end
            
            if isempty(MSN)
                load(TPWSname,'MSN','MSP');
            end
            trainMSN = MSN(I,:);
            trainMSP = MSP(I,:);
            trainTimes = MTT(I,:);
            [~,outputName,~] = fileparts(TPWSname);
            
            detLevelOutputFile = fullfile(newDir{iF},sprintf('%s_%s_file%0.0f_detLevel.mat',...
                outputName,thisName{iF},iTPWS));
            fprintf('Saving detection-level file %0.0f of %0.0f\n',iF,nTypes)
            save(detLevelOutputFile,'trainTimes','trainMSN','trainMSP','TPWSname','-v7.3')
            
        end
        fprintf('Done saving detection-level output for %s.\n',TPWSname)
        MSN = [];
        MSP = []; 
        trainTimes = [];
    end
end
spinH.stop
close(REMORA.fig.ct.cc_saveClust)
disp(sprintf('Done saving training files to %s.', REMORA.ct.CC.output.clustDir))
disp_msg(sprintf('Done saving training files to %s.', REMORA.ct.CC.output.clustDir))

