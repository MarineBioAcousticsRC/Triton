function sh_write_eval_csv_file(handles,start)
% stores evaluation of random detections to a csv file

% csv file contains 5 columns:
% ISO8601 start datetime
% ISO8601 end datetime
% Start datetime
% End datatime
% Label

shipTimes = handles.shipTimesEval;
shipLabels = handles.shipLabelsEval;
% convert times to ISO8601 format
ISOStartTime = datestr(shipTimes(:,1), 'YYYY-mm-ddTHH:MM:SS.FFFZ');
ISOEndTime = datestr(shipTimes(:,2), 'YYYY-mm-ddTHH:MM:SS.FFFZ');

% convert  Matlab serial date to Excel serial date 
StartTime = m2xdate(shipTimes(:,1));
EndTime = m2xdate(shipTimes(:,2));

if start
    evalTable = table();
    evalTable.ISOStartTime = ISOStartTime;
    evalTable.ISOEndTime = ISOEndTime;
    evalTable.StartTime = StartTime;
    evalTable.EndTime = EndTime;
    evalTable.DetectorLabels = shipLabels;
    evalTable.Detector=strcmp(shipLabels,'ship');
    evalTable.UserEval=strcmp(shipLabels,'ship');
    handles.evalTable = evalTable;
end

handles.evalTable.UserEval = strcmp(shipLabels,'ship');


if 1
filename = split(handles.LtsaFile,'.ltsa');
handles.EvalCsvFile = ['Eval_',num2str(size(shipTimes,1)),...
    '_Ship_detections_',filename{1},'.csv'];
savePath = fullfile(handles.DetectionFilePath,handles.EvalCsvFile);
writetable(handles.evalTable,savePath)
end
