% Use this script after running clustering step (with bin min clustering size of 50 clicks)
% and classifying the data with the trained DNN from the North Atlantic.
% This script will read all the detection classification labels, and create
% a FD file to flag all the detections classified as non-beaked whales as
% false detections. It considers only detections classified to a class from 
% clustered bins. Any classification from bins not clustered are ignored. 

clearvars

% specify folder containing TPWS files
inDirTPWS = 'F:\WAT_WC_01_De_TPWS\WAT_WC_01_disk03';
% specify folder containing files created after running the trained DNN (*_labels.mat)
inDirNet = 'F:\WAT_WC_01_NNetclass_2step\Step1\NNetclass_min50clicks\WAT_WC_01_disk03';
% specify site and disk 
wildcard = 'WAT_WC_01_disk03';
% Which labels to remove, not specific of the taxonomic family of beaked
% whales
removeLabels = {'Delphinid';'Echosounder';'Gg';'Kogia';'Pmnoise'};

%%%%%%%%%%%%%%%%%%%%%%%%%%% DO NOT MODIFY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% find list of TPWS files to be read
dirListTPWS = dir(fullfile(inDirTPWS,[wildcard,'*TPWS*.mat']));
nFilesTPWS = length(dirListTPWS);
fprintf('Found %0.0f TWPS files to process\n' ,nFilesTPWS)

% find list of NNet files to be read
dirListNet = dir(fullfile(inDirNet,[wildcard,'*labels.mat']));
nFilesNet = length(dirListNet);

% for each file
zFD = [];
for iFile = 1:nFilesTPWS
    
    load(fullfile(dirListTPWS(iFile).folder,dirListTPWS(iFile).name))
    wildcardNet = strsplit(dirListTPWS(iFile).name,'_Delphin');
    wildcardNet = wildcardNet{1};
    nFile = find(contains({dirListNet.name},wildcardNet));
    
    if isfile(fullfile(dirListNet(nFile).folder,dirListNet(nFile).name))
        % File exist, the load
        load(fullfile(dirListNet(nFile).folder,dirListNet(nFile).name))
        
        % find index of labels to remove
        removeIdx = find(ismember(typeNames,removeLabels));
        
        % Only consider bins that clustered
        mC = arrayfun(@(x) (x.clusteredTF == 1),binData,'UniformOutput',true); % check for multiple clusters
        mCIdx = find(mC ==1);
        
        binData = binData(mCIdx);
        
        clickTimes = [binData(:).clickTimes]';
        predLabel = vertcat(binData(:).predLabels);
        predLabelScore = vertcat(binData(:).predLabelScore);
        
        % Concatenate by row
        zID = [];
        for iRow = 1:size(clickTimes,1)
            repDims = size(clickTimes{iRow});
            if ~isnan(predLabel(iRow))
                zIDnew = [clickTimes{iRow},...
                    repmat(predLabel(iRow),repDims),...
                    repmat(predLabelScore(iRow),repDims)];
                zID = [zID;zIDnew];
            end
        end
    else
        error('Could not find\n file %s\n in folder %s',dirListNet(nFile).name,dirListNet(nFile).folder)
    end
    
    rIdx = find(ismember(zID(:,2), removeIdx));
    
    removeClick = ismember(MTT,zID(rIdx,1));
    zFD = MTT(removeClick);

    % save FD files in the same folder
    FDfile = strrep(dirListTPWS(iFile).name,'TPWS','FD');

    % save FD files in a separate folder (in case to have a separate copy) 
    FDfolder = strrep(dirListTPWS(iFile).folder,'TPWS','Remove');
    
    % create output folder
    if ~isfolder(FDfolder)
        fprintf('Creating output folder %s\n', FDfolder)
        mkdir(FDfolder)
    end

    save(fullfile(dirListTPWS(iFile).folder,FDfile),'zFD','-v7.3')
    save(fullfile(FDfolder,FDfile),'zFD','-v7.3')
    fprintf('Done with file %d of %d\n',iFile,nFilesTPWS)
       
end
