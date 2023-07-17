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
StartTime = shipTimes(:,1) - 693960;
EndTime = shipTimes(:,2) - 693960;

evalTable = table();
evalTable.ISOStartTime = ISOStartTime;
evalTable.ISOEndTime = ISOEndTime;
evalTable.StartTime = StartTime;
evalTable.EndTime = EndTime;
evalTable.DetectorLabels = handles.shipLabels(handles.idxRandSamples);
evalTable.Detector=strcmp(evalTable.DetectorLabels,'ship');
if start
    evalTable.UserEval = evalTable.Detector;   
else
    evalTable.UserEval = strcmp(shipLabels,'ship'); 
end
evalTable.TP = evalTable.Detector == 1 & evalTable.UserEval == 1;
evalTable.FP = evalTable.Detector == 1 & evalTable.UserEval == 0;
evalTable.FN = evalTable.Detector == 0 & evalTable.UserEval == 1;
evalTable.TN = evalTable.Detector == 0 & evalTable.UserEval == 0;
evalTable.Precision = nan(height(evalTable),1);
evalTable.Recall = nan(height(evalTable),1);
evalTable.Comments = cell(height(evalTable),1);
evalTable.Precision(1) = sum(evalTable.TP) / (sum(evalTable.TP) + sum(evalTable.FP));
evalTable.Recall(1) = sum(evalTable.TP) / (sum(evalTable.TP) + sum(evalTable.FN));
evalTable.Comments(1) = {'Caveat! False Negative does not include the missed detections by the thresholds of the detector. Mannually review the missed detections using the Visualize Detections interface and add them to the total number of False Negative'};

% save table to csv file
filename = split(handles.LtsaFile,'.ltsa');
handles.EvalCsvFile = ['Eval_',num2str(size(shipTimes,1)),...
    '_Ship_detections_',filename{1},'.csv'];
savePath = fullfile(handles.DetectionFilePath,handles.EvalCsvFile);
writetable(evalTable,savePath)

