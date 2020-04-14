BaseDir = uigetdir('G:\','Please select main folder with mat');
mkdir(BaseDir,'explosions')
DetDir = fullfile(BaseDir,'explosions');

SearchFileMask = {'*.mat'};
SearchPathMask = {BaseDir};
SearchRecursiv = 1;

[PathFileList, FileList, PathList] = ...
    utFindFiles(SearchFileMask, SearchPathMask, SearchRecursiv);

for fidx = 2:size(FileList,1)
    load(PathFileList{fidx})
    bt(:,1) = allSmpPts(:,1)-5000;
    bt(:,2) = allSmpPts(:,2)+5000;
        
    save(PathFileList{fidx},'bt','-append');
end