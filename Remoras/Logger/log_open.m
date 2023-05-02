function log_open(MetadataNames, MetadataValues)
% log_open(MetadataNames, MetadataValues)
% Open spreadsheet and set specified metavalues.  
% 
% MetadataNames and MetadataValues contain an optional pair of cell arrays
% with a set of field names and their corresponding values for the Metadata
% shee in the active log file
% Valid names and values depend upon the spreadsheet template that is used
% for the logger, but the following example indicates things some of the
% fields for which this was developed:
%
% log_start({'User ID', 'Project', 'Site'}, {'ritter', 'SOCAL', 'A'});
% If this is a continued log sheeet, use
% log_start(); 

global handles HANDLES

ShowSpreadsheet = false;  % set to true for debugging

% Enable going off-effort (ad-hoc)
%set(handles.adhoc, 'Visible', 'on');
% Set up an active X server to access this spreadsheet
try
     handles.Server = actxserver('Excel.Application');
catch err
     errordlg('Unable to access spreadsheet interface')
     return
end

try
    handles.Workbook = handles.Server.workbooks.Open(handles.logfile);  % Open workbook
catch err
    errordlg(sprintf('Unable to open spreadsheet %s', handles.logfile));
    return
end
if handles.Workbook.ReadOnly ~= 0
    handles.Workbook.Close();
    handles.Workbook = [];
    handles.Server.Quit();
    handles.Server = [];
    
    delete(handles.logcallgui);  % Remove logger gui
    errordlg(sprintf('Workbook %s is not writable', handles.logfile));
    clear GLOBAL handles;  % No longer valid
    return;
end

handles.Server.Visible = ShowSpreadsheet;  % for debugging

try
    meta = handles.Workbook.Sheets.Item('MetaData');
catch
    errordlg('No MetaData sheet in workbook');
    handles.Workbook.Close();
    handles.Workbook = [];
    handles.Server.Quit();
    handles.Server = [];
    clear GLOBAL handles; % No longer valid
    return
end

set(handles.logcallgui, 'CloseRequestFcn', @log_closewindow)

for f = {'main', 'ctrl', 'msg'}
    field = f{1};
    handles.log.oldclosefn.(field) = get(HANDLES.fig.(field), 'CloseRequestFcn');
    set(HANDLES.fig.(field), 'CloseRequestFcn', @log_closewindow);
end

handles.Meta.Sheet = meta;  % Save worksheet handle
colsN = meta.UsedRange.Columns.Count;
lastCol = excelColumn(colsN);
headers = meta.Range(sprintf('A1:%s1', lastCol));
handles.Meta.Headers = get(headers, 'Value');

if nargin == 2
    if length(MetadataNames) ~= length(MetadataValues)
        error('Mismatched name/value pairs');
    end

    for idx=1:length(MetadataNames);
        rowcol = headers.Find(MetadataNames{idx});
        if isempty(rowcol)
            errordlg(sprintf('Missing column %s from MetaData sheet', ...
                MetadataNames{idx}));
        else
            col = rowcol.Column - 1;  % col in 0 to N-1 format
            meta.Range(sprintf('%s2', excelColumn(col))).Value = ...
                MetadataValues{idx};
        end
    end
end

% Save and store log and ad-hoc column labels
try
    handles.OnEffort.Sheet = handles.Workbook.Sheets.Item('Detections');
catch
    errordlg('No Detections sheet in workbook');
end
colsN = handles.OnEffort.Sheet.UsedRange.Columns.Count;
headerCols = handles.OnEffort.Sheet.Range(sprintf('A1:%s1', ...
    excelColumn(colsN-1)));
handles.OnEffort.Headers = headerCols.value();
handles.OnEffort.ParamCols = parameter_columns(handles.OnEffort.Headers);

handles.OffEffort.Sheet = handles.Workbook.Sheets.Item('AdhocDetections');
if isempty(handles.OffEffort.Sheet)
    warndlg('The AdhocDetections sheet is missing.  No adhoc detections will be permitted');
    set(handles.adhoc, 'Visible', 'off');    % Disable off-effort button
else
    colsN = handles.OnEffort.Sheet.UsedRange.Columns.Count;
    headerCols = handles.OffEffort.Sheet.Range(sprintf('A1:%s1', ...
        excelColumn(colsN-1)));
    handles.OffEffort.Headers = headerCols.value();
    handles.OffEffort.ParamCols = parameter_columns(handles.OffEffort.Headers);
end


% Create directories for images and audio if they do not already exist
for fname = {'imagedir', 'audiodir'}
    field = fname{1};
    if ~exist(handles.log.(field), 'dir')
        [retval, msg] = mkdir(handles.log.(field));
        if ~ retval
            errordlg('Unable to create %s\n%s', handles.log.(field), msg);
        end
    end
end

% fetch metadata that we expect to be static
fields = {'User ID',  'DeploymentId'};
for fidx = 1:length(fields);
    tmp = strrep(fields{fidx}, ' ', '_');  % no spaces
    col = find(strcmp(handles.Meta.Headers, fields{fidx}));
    if ~ isempty(col)
        rng = handles.Meta.Sheet.Range(sprintf('%s2', excelColumn(col-1)));
        handles.Meta.(tmp) = get(rng, 'Value');
    end
end

% This name is used as part of the image and audio filenames 
% when the user takes a snapshot.
handles.Meta.file_tag = handles.Meta.DeploymentId;

% Disable crosshair pointers when window loses focus
% This relies on undocumented Matlab functionality.
%
% Creates more problems than its worth due to the fulllcrosshair pointer
% bug workaround in set_pointer shifting focus to the window.  
% jframe = get(HANDLES.fig.main, 'JavaFrame');
% jaxis = jframe.getAxisComponent();
% set(jaxis, 'FocusGainedCallback', {@pickxyz, true});
% set(jaxis, 'FocusLostCallback', {@set_pointer, HANDLES.fig.main, 'arrow'});

function cols = parameter_columns(headers)
% cols = parameter_columns(headers)
% Parse headers for parameters and return a cell array such that
% cols(N) contains the column label for the Nth parameter.

% Find headers with parameters
global handles

params = regexp(handles.OnEffort.Headers, 'Parameter\s(?<n>\d+)', ...
    'ignorecase', 'names');
paramI = ~cellfun(@isempty, params);
for idx=find(paramI)
    column = excelColumn(idx - 1);
    cols{str2double(params{idx}.n)} = column;
end



