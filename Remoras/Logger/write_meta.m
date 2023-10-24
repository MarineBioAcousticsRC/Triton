function write_meta()

global handles PARAMS
effortstart = handles.effortstart;

%TODO - When continuing a log, we need to check if any of the new
% detections are past the previous end time and if so offer
% to adjust the end time or take the last time used.
% If continuing, the log time in the spreadsheet should already be
% set (we can't check PARAMS.log.end as this might have been set by
% the callback.

if isempty(PARAMS.log.end)
    % TODO - Find last pick time and put in dialog.
    method = questdlg('Effort end must be specified before ending:', ...
        'End log', 'Use last pick','Select by pick', 'Cancel', ...
        'Select');
    switch method
        case 'Use last pick'
            % Use end time of latest pick,
            fprintf('todo\n');
            keyboard
        case 'Select by pick'
            % Set pickxyz callback so that end of effort will be set
            % The log_pick callback will set end of effort and call
            % this function causing us to skip the dialog and write
            % the metadata
            PARAMS.log.pick = 'effort_end';
            set(HANDLES.fig.main, 'Pointer', 'fullcross');
            return;
            
        case 'Cancel'
            % User aborts, do nothing
            return
    end
end
         
 
deploy = strtrim(get(handles.deploy.disp, 'string'));
userID = strtrim(get(handles.user.disp, 'string'));
% region = strtrim(get(handles.region.disp, 'string'));

proj = get(handles.project.pulldown, 'string');


project = proj{get(handles.project.pulldown, 'value')};

try
    Meta = handles.Workbook.Sheets.Item('MetaData'); % Access metadata
catch
    errordlg(sprintf('%s missing MetaData sheet', handles.logfile));
end

% Read headers
Range = EffortSheet.Range(sprintf('1', RowsN));
Header = get(Range, 'Value');
1;

    [xlnum, xltext, xlcell]=xlsread(filename, 'MetaData');
    lastrow=size(xlcell,1);
    M_rowstartnum=lastrow+1;
    
    M = [{userID} {deploy} {effortstart} {effortend}];
    
    xlswrite([handles.logfilepath filesep handles.logfilename],...
    M, 'MetaData', sprintf('A%d', M_rowstartnum));
    handles = [];