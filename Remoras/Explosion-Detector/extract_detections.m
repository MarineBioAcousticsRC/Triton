function extract_detections

BaseDir = uigetdir('G:\','Please select main folder with xwavs');
SearchFileMask = {'*.mat'};
SearchPathMask = {BaseDir};
SearchRecursiv = 1;

[PathFileList, FileList, PathList] = ...
    utFindFiles(SearchFileMask, SearchPathMask, SearchRecursiv);

fileAll = [];
posAll = [];
smpAll = [];
durAll = [];
ppAll = [];
for k = 1:length(FileList)
    load(PathFileList{k})
    falseIdx = find(bt(:,3) == 0);
    bt(falseIdx,:) = [];
    allPpDet(falseIdx) = [];
    allDur(falseIdx) = [];
    
    files = [];
    if ~isempty(bt)
        for a = 1:length(allPpDet)
            files{a,1} = FileList{k};
        end
    end
    
    fileAll = [fileAll;files];
    posAll = [posAll;bt(:,4:5)];
    smpAll = [smpAll;bt(:,1:2)];
    durAll = [durAll;allDur];
    ppAll = [ppAll;allPpDet];
end

stridx = strfind(FileList{1},'_');
site = FileList{1}(1:stridx(1)-1);
stridx = strfind(PathList{1},'\');
path = PathList{1}(1:stridx(end-1));
newMat = fullfile(path,[site,'_allexplosions.mat']);
newXls = fullfile(path,[site,'_allexplosions.xls']);

save(newMat,'fileAll','posAll','smpAll','durAll','ppAll','rmsAS','ppAS',...
    'durLong_s','durShort_s','threshold')
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Convert matlab times to excel times
excelStart = posAll(:,1)-ones(size(posAll(:,1))).*datenum('30-Dec-1899');
excelEnd = posAll(:,2)-ones(size(posAll(:,2))).*datenum('30-Dec-1899');

% Exports the bt_combined array data into excel file
lengt = length(excelStart)+1;
shor = length(excelEnd);
cellmat = cell(lengt,7);
cellmat{1,1} = 'File';
cellmat{1,2} = 'Sample Points Start';
cellmat{1,3} = 'Sample Points End';
cellmat{1,4} = 'Start Time';
cellmat{1,5} = 'End Time';
cellmat{1,6} = 'Duration';
cellmat{1,7} = 'p-p Amplitude';

for idx = 1:length(excelStart)
    cellmat{idx+1,1} = fileAll{idx};
    cellmat{idx+1,2} = smpAll(idx,1);
    cellmat{idx+1,3} = smpAll(idx,2);
    cellmat{idx+1,4} = excelStart(idx,1);
    cellmat{idx+1,5} = excelEnd(idx,1);
    cellmat{idx+1,6} = durAll(idx);
    cellmat{idx+1,7} = ppAll(idx);
end

xlswrite(newXls, cellmat);
disp('Finished writing data to excel file');

1;