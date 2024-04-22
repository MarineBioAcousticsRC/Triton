function log_close(end_effort_date)
% log_close(end_effort_date)
% Close off the log with an end effort date.
% In case of catastrophic failure/user abort, may be called without an
% end date in which case none is written.

global handles HANDLES PARAMS

% Locate the end of effort
effortEnd = 'Effort End';
if ismac
    col = 4;
else
    col = find(strcmp(handles.Meta.Headers, effortEnd), 1, 'first');
end
if ~ isempty(end_effort_date)
    if isempty(col)
        errordlg(sprintf('Column %s missing from MetaData sheet', effortEnd));
        return
    else
        if ismac
            handles.Meta.Sheet.EffortEnd = datestr(end_effort_date,31);
        else
        colStr = excelColumn(col - 1);
        set(handles.Meta.Sheet.Range(sprintf('%s2', colStr)), ...
            'Value', datestr(end_effort_date, 31))
        end

    end
end

PARAMS.log.pick = [];  % Turn off time X freq callback
pickxyz(true);  % reset cursor

% Save and close up
if ismac
    writetable(handles.OnEffort.Sheet,handles.logfile,'Sheet','Detections')
    writetable(handles.OffEffort.Sheet,handles.logfile,'Sheet','AdhocDetections')
    writetable(handles.Meta.Sheet,handles.logfile,'Sheet','MetaData')
    writetable(handles.Effort.Sheet,handles.logfile,'Sheet','Effort2')
else
    handles.Workbook.Save();
    handles.Workbook.Close();
    handles.Workbook = [];
    handles.Server.Quit();
    handles.Server = [];
end

% Restore original closing function
for f = {'main', 'ctrl', 'msg'}
    field = f{1};
    set(HANDLES.fig.(field), ...
        'CloseRequestFcn', handles.log.oldclosefn.(field));
end

delete(handles.logcallgui);  % Remove logger gui
clear GLOBAL handles;  % No longer valid
