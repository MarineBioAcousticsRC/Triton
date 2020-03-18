function ct_cc_savebouts(hObject,eventdata)

global REMORA
close(REMORA.fig.ct.cc_saveBouts)

timeStepDNum = REMORA.ct.CC.output.p.timeStep./(60*24);
fNameCells = {REMORA.ct.CC.output.inFileList(:).name};
dataAll = [];
labelsAll = [];
binFileNamesAll = [];
for iT = 1:size(REMORA.ct.CC.output.Tfinal)
    % For each cluster:
    % Get times of all bins and associated file.
    % [startTime,endTime,ID,fileName]
    dataMat = [REMORA.ct.CC.output.Tfinal{iT,7},...
        REMORA.ct.CC.output.Tfinal{iT,7}+timeStepDNum,...
        repmat(iT,size(REMORA.ct.CC.output.Tfinal{iT,7},1),1)];
    binFileNamesMat = fNameCells(REMORA.ct.CC.output.Tfinal{iT,6})';
    labelMat = cellstr(repmat(REMORA.ct.CC.output.labelStr{iT},...
        size(REMORA.ct.CC.output.Tfinal{iT,7},1),1));
    dataAll = [dataAll;dataMat];
    labelsAll = [labelsAll;labelMat];
    binFileNamesAll = [binFileNamesAll;binFileNamesMat];
end

outputTable = table(datestr(dataAll(:,1)),datestr(dataAll(:,2)),dataAll(:,3),...
    labelsAll,binFileNamesAll,'VariableNames',...
    {'StartTime','EndTime','ClusterIDNumber','IDName','BinFileName'});
[~,sortedOrder] = sort(dataAll(:,1));
outputTable = outputTable(sortedOrder,:);
fName = fullfile(REMORA.ct.CC.output.boutDir,...
    REMORA.ct.CC.output.boutFName);
if ~isdir(REMORA.ct.CC.output.boutDir)
    mkdir(REMORA.ct.CC.output.boutDir)
end
writetable(outputTable,fName)

fprintf('Bout file saved to %s\n',fName)