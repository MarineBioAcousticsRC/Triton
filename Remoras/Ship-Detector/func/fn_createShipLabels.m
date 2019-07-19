function fn_createShipLabels
% Create .tlab files from ship detections to display labels in triton

% Specify directory where to save reduced mat files
cDir = uigetdir('E', 'Specify directory with ship detections (.s files)');

SearchFileMaskMat = {'*.s'};
SearchPathMaskMat = {cDir};
SearchRecursiv = 1;

[PathFileListMat, FileListMat, PathListMat] = ...
    utFindFiles(SearchFileMaskMat, SearchPathMaskMat, SearchRecursiv);

timsAll = [];
labelsAll  = [];
for idx = 1:length(PathFileListMat)
    [Starts, Stops, Labels] = ioReadLabelFile(PathFileListMat{idx});
    unscr = strsplit(FileListMat{idx},'.');
    filename = unscr{1,1};
    getdate = strsplit(filename,'_');
    d = [getdate{end-1},getdate{end}];
    rawStart = [str2num(['20',d(1:2)]), str2num(d(3:4)), str2num(d(5:6)), str2num(d(7:8)), str2num(d(9:10)), str2num(d(11:12))];
    tims = [Starts, Stops];
    tims = tims/24/60/60 + datenum(rawStart(1,:));
    timsAll = [timsAll;tims]; 
    labelsAll = [labelsAll;Labels];
end

FileName = fullfile([FileListMat{1}(1:10),'s']);
LabelFileName = ([cDir,'\',FileName,'_ship.tlab']);
ioWriteLabel(LabelFileName, timsAll - dateoffset(), labelsAll, 'Binary', true);

disp('Ship detector labels created')