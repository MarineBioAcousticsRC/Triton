function ct_cc_extract_dets_from_multiple_dirs(mySpDir)

% for a folder of species-level bin files sorted into sub directories, go
% into each subdir and open bin file, then go find clicks associated and
% save a detection-level version.

% global REMORA
% spinH = ct_add_spinner(REMORA.fig.ct.cc_saveClust,[0.45,0.45,0.1,0.15]);
% spinH.start;drawnow
% if (REMORA.ct.CC.output.saveBinLevelDataTF + REMORA.ct.CC.output.saveDetLevelDataTF)==0
%     % Nothing was checked. Don't do anything.
%     disp('No options checked. Nothing to do.')
%     return
% elseif isempty(REMORA.ct.CC.output.clustDir)
%     error('Please specify an output folder.')
% end

% get subfolders (remove bad ones)
subDirList = dir(mySpDir);
subDirList = subDirList([subDirList.isdir]);
subDirList = subDirList(~ismember({subDirList.name} ,{'.','..'}));

% uNames = unique(REMORA.ct.CC.output.labelStr);
nTypes = length(subDirList);
thisName = [];
thisTypeAll = [];
thisTPWSList = [];
TPWSBaseDirs = {'K:\','N:\','P:\','I:\'};
for iD = 1:length(TPWSBaseDirs)
    thisTPWSList = [thisTPWSList;dir(fullfile(TPWSBaseDirs{iD},'\**\*TPWS*'))];
end
fprintf('Found %0.0f TPWS files in %0.0f base folders.\n',size(thisTPWSList,1),length(TPWSBaseDirs))
fprintf('Beginning extraction of %0.0f signal types.\n',nTypes)
for iDir = 5%1:nTypes
    fList = dir(fullfile(subDirList(iDir).folder,subDirList(iDir).name, '\*.mat'));
    fList = fList(~contains({fList.name} ,'detLevel')); % remove non-target files.
    thisName{iDir} = strrep(subDirList(iDir).name,' ','_'); % get rid of spaces in names

    nFiles = length(fList);
    fprintf('Begin extracting %s from %0.0f files.\n',subDirList(iDir).name,nFiles)
    for iF = 1:nFiles
        % newDir{iF} = fullfile(REMORA.ct.CC.output.clustDir,thisName{iF});
        inFile = fullfile(fList(iF).folder,fList(iF).name);
        load(inFile) % load bin file
        nTPWS = length(TPWSList);
        for iTPWS = 1:nTPWS
            TPWSidx =  find(strcmp({thisTPWSList(:).name},TPWSList(iTPWS)));
            if isempty(TPWSidx)
                fprintf('No TPWS match for file %s, skipping\n',TPWSList{iTPWS})
                continue
            end
            MTT = [];
            TPWSname = fullfile(thisTPWSList(TPWSidx).folder,thisTPWSList(TPWSidx).name);
            load(TPWSname,'MTT') % start with loading times only to see if matches exist.
            
            % For each cluster type, save one or more files that contain
            % the spectra, waveforms and event times of each detection in that
            % set.
            MSN = [];
            MSP = [];
            
            
            [~,I] = intersect(MTT,thisType.clickTimes);
            if isempty(I)
                % don't bother loading the big matrices if there are no
                % matching times
                fprintf('  No matches in file %0.0f of %0.0f, skipping.\n',iTPWS,nTPWS)
                continue
            end
            
            %if isempty(MSN)
            load(TPWSname,'MSN','MSP');
            %end
            trainTimes = MTT(I,:);
            trainMSN = MSN(I,:);
            trainMSP = MSP(I,:);
            if 1
                figure(11);clf;imagesc(trainMSP');set(gca,'yDir','normal');colormap(jet)
            end
            [~,outputName,~] = fileparts(fList(iF).name);
            outDir = fList(iF).folder;
            detLevelOutputFile = fullfile(outDir,sprintf('%s_%s_file_%0.0f_detLevel.mat',...
                outputName,thisName{iDir},iTPWS));
            fprintf('Saving detection-level file %0.0f of %0.0f\n',iTPWS,nTPWS)
            save(detLevelOutputFile,'trainTimes','trainMSN','trainMSP','TPWSname','-v7.3')
        end
    end
    fprintf('Done saving detection-level output for %s.\n',TPWSname)
    MSN = [];
    MSP = [];
end

