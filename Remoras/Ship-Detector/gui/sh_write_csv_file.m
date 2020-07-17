function sh_write_csv_file(savePath,shipTimes,shipLabels)
% stores detector output to a csv file

% csv file contains 5 columns:
% ISO8601 start datetime
% ISO8601 end datetime
% Start datetime
% End datatime
% Label

% convert times to ISO8601 format

ISOStartTime = datestr(shipTimes(:,1), 'YYYY-mm-ddTHH:MM:SS.FFFZ');
ISOEndTime = datestr(shipTimes(:,2), 'YYYY-mm-ddTHH:MM:SS.FFFZ');

% convert  Matlab serial date to Excel serial date 
StartTime = shipTimes(:,1) - 693960;
EndTime = shipTimes(:,2) - 693960;

T = table();
T.ISOStartTime = ISOStartTime;
T.ISOEndTime = ISOEndTime;
T.StartTime = StartTime;
T.EndTime = EndTime;
T.Labels = shipLabels;

writetable(T,savePath)
