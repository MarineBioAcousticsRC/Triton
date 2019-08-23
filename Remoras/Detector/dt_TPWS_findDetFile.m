function [fullFileNames,filePaths,fileBytes] = dt_TPWS_findDetFile(p)

if isempty(p.siteName)
    fList = fn_subdir(fullfile(p.detDir,['*',p.detFileExt]));
else
    fList = fn_subdir(fullfile(p.detDir,['*',p.siteName,'*',p.detFileExt]));
end

if isempty(fList)
    error('No detection files found. Check folder path and partial string to match')
end

% Exclude empty detection files
bytes = cell2mat({fList(:).bytes}');
emptyFiles = find(bytes == 0);
fList(emptyFiles) = [];

% Pull out files from all folders, combine full paths into one long list
fullFileNames = {fList(:).name}';

% check for duplicate file names and warn user if found
fileNames = cell(size(fullFileNames));
filePaths = cell(size(fullFileNames));
fileBytes = zeros(size(fullFileNames));
for iFN = 1:size(fullFileNames,1)
    [filePathTemp, fileNameTemp,fileExtTemp] = fileparts(fullFileNames{iFN});
    fileNames{iFN} = [fileNameTemp,fileExtTemp];
    filePaths{iFN} = filePathTemp;
    fileBytes(iFN) = fList(iFN).bytes;
end

[uFnames,uI] = unique(fileNames);
if size(uFnames,1)<size(fileNames,1)
    duplicateIdx = setdiff(uI,1:length(size(fileNames,1)));
    warning('Duplicate detection files found')
    disp(fileNames{duplicateIdx})
end