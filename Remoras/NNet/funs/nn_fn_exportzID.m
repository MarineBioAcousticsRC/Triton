function nn_fn_exportzID

global REMORA

% find list of files to be read
dirList = dir(fullfile(REMORA.nn.exportzID.inDir,[REMORA.nn.exportzID.wildcard,'*.mat']));
nFiles = length(dirList);
fprintf('Found %0.0f bin files to process\n' ,nFiles)

% create output folder
if ~isdir(REMORA.nn.exportzID.saveDir)
    fprintf('Creating output folder %s\n', REMORA.nn.exportzID.saveDir)
    mkdir(REMORA.nn.exportzID.saveDir)
end

% for each file
for iFile = 1:nFiles
    load(fullfile(dirList(iFile).folder,dirList(iFile).name))
    % Flatten binData
    if ~exist('binData','var')
        continue
    end
    clickTimes = [binData(:).clickTimes]';
    predLabel = [binData(:).predLabels]';
    predLabelScore = [binData(:).predLabelScore]';
    
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

    % replace TPWS with ID, keeping number the same (eg. TPWS2 -> ID2) in
    % output name
    [~,~,myToken] = regexp(TPWSfilename,'(TPWS.)\.mat');
    if ~isempty(myToken)
        saveFName = [TPWSfilename(1:myToken{1}(1)-1),'ID',TPWSfilename((myToken{1}(2)):end)];
    else
        warning('Could not find TPWS<n>.mat in file name, appending ID1 instead, may cause problems for DetEdit.')
        saveFName = strrep(TPWSfilename,'.mat','_ID1.mat');
    end
    saveFullfile = fullfile(REMORA.nn.exportzID.saveDir,saveFName);
    mySpID = typeNames;
    save(saveFullfile,'zID','mySpID','classificationInfo','-v7.3')
    fprintf('Done saving file %0.0f of %0.0f: %s\n',iFile,nFiles,saveFName)
end
