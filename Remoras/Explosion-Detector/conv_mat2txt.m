function conv_mat2txt

%pull in all xwavs of a folder and subfolder to run matched filter detector
%for explosions

BaseDir = uigetdir('G:\','Please select folder with explosion .mat files');

SearchFileMask = {'*.mat'};
SearchPathMask = {BaseDir};
SearchRecursiv = 0;

[PathFileList, FileList, PathList] = ...
    utFindFiles(SearchFileMask, SearchPathMask, SearchRecursiv);


for fidx = 1:size(FileList,1)
    file = FileList{fidx};
    path = PathList{fidx};
    filepath = PathFileList{fidx};
    
    display(['calculating ',file,'; file ',num2str(fidx),'/',num2str(size(FileList),1)])
    load(filepath)

    
    %make txt file with all variables
    fend = strfind(file,'.mat');
    newFile = fullfile(BaseDir,[file(1:fend-1),'.txt']);
    
%     excelStart = allExp(:,1) - ones(size(allExp(:,1))).*datenum('30-Dec-1899');
%     excelEnd =  allExp(:,2) - ones(size(allExp(:,2))).*datenum('30-Dec-1899');

    col = 'start end duration corrVal medianC2 ppDet ppNAfter ppNBefore rmsDet rmsNAfter rmsNBefore';
    printExpl = [];
    printExpl(1,:) = allExp(:,1);
    printExpl(2,:) = allExp(:,2);
    printExpl(3,:) = allDur;
    printExpl(4,:) = allCorrVal(:,1);
    printExpl(5,:) = allCorrVal(:,2);
    printExpl(6,:) = allPpDet;
    printExpl(7,:) = allPpNAfter;
    printExpl(8,:) = allPpNBefore;
    printExpl(9,:) = allRmsDet;
    printExpl(10,:) = allRmsNAfter;
    printExpl(11,:) = allRmsNBefore;

    fid = fopen(newFile,'w');
    fprintf(fid,'%s\n',col);
    fprintf(fid,'%f %f %f %f %f %f %f %f %f %f %f\n',printExpl);
    fclose(fid);
    1;
end
