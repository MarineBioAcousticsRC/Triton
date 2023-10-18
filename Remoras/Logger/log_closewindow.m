function log_closewindow(src,evnt)
% src is the figure number
global handles PARAMS

if (src >= 1 && src <= 3) || src == 7 || src == 9 %from 5 (old logger) to 7 (remora version)
    % sf added in 9 because bug wasn't able to close at all 2022 Aug 2
    % User attempted to close one of Triton's main windows
    % or the logger window
    
    % Kludge - to prevent user from closing the window
    % while setting effort.
    if strcmp(get(handles.effortPane(1), 'Visible'), 'on')
        r = questdlg(...
            ['Closing the log at this point will result in an ', ...
            'inconsistent log.  We strongly recommend setting Effort, ', ...
            'then closing.'], 'Really close?', ...
            'Do not close', 'Close anyway', 'Do not close');
        
        switch r
            case 'Close anyway'
                log_close([]);
            case 'Do not close'
                % do nothing.
        end
        return
    end
    options = {};
    
    %  Find last detection
    colStart = excelColumn(find(~cellfun(@isempty, ...
        strfind(handles.OnEffort.Headers, 'Start time'))) -1);
    colEnd =  excelColumn(find(~cellfun(@isempty, ...
        strfind(handles.OnEffort.Headers, 'End time')))-1);
    lastRow = log_lastRow(handles.OnEffort.Sheet);
    if lastRow < 2
        handles.log.lastDate = [];  % no detections recorded
        lastDateStr = 'none';
        last = [];
    else
        lastDateRange = handles.OnEffort.Sheet.Range(...
            sprintf('%s2:%s%d,%s2:%s%d', ...
            colStart, colStart, lastRow, ...
            colEnd, colEnd, lastRow));
        handles.log.lastDate = ...
            handles.Server.WorksheetFunction.Max(lastDateRange) + ...
            date_epoch('excel');
        
        lastDateStr = datestr(handles.log.lastDate, ...
            'yyyy/mm/dd HH:MM:SS');
        set(handles.end_pick.disp, 'String', lastDateStr);
        last = sprintf('Latest pick: %s', lastDateStr);
        options{end+1} = last;
    end

    % Is there a current end date from a previous session?
    previousEnd = [];  % Assume not until we learn otherwise
    endCol = find(strcmp(handles.Meta.Headers, 'Effort End'), 1, 'first');
    endDate = get(handles.Meta.Sheet.Range(...
                    sprintf('%s2', excelColumn(endCol-1))), 'Value');
    if ~ isnan(endDate)
        if ischar(endDate)
            endDate = datenum(endDate);
        else
            endDate = endDate + date_epoch('excel');
        end
        
        % Make the last recorded end of effort be an option if we have not
        % detected anything past the end.
        if isempty(last) || endDate >= handles.log.lastDate
            endDateStr = datestr(endDate, 'yyyy/mm/dd HH:MM:SS');
            set(handles.end_previous.disp, 'String', endDateStr);
            previousEnd = sprintf('Existing:  %s', endDateStr);
            handles.log.endDate = endDate;
            options{end+1} = previousEnd;
        end
    end    
    
    terminate = questdlg(...
        'End logging session.  Close to cancel or denote end of effort by:', ...
        'End logging session', ...
        options{:}, 'Let me specify', 'Let me specify');

    
    switch terminate
        case ''  % User closed the dialog box
            return
        
        case last
            log_close(handles.log.lastDate);
            return
            
        case previousEnd
            log_close(handles.log.endDate)
            return
            
        case 'Let me specify'
            set(handles.log.control, 'Visible', 'off');
            set(handles.log.close, 'Visible', 'on');
            PARAMS.log.pick = 'effort_end';
            set(handles.done, 'String', 'Close log', ...
                'Callback', {@control_log, 'set_meta_end'});
            return
    end
end
