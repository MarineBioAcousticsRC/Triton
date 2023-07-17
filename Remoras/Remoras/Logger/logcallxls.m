function logcallxls(action)
% logcallxls(action)
% Store an action to the log file

global handles PARAMS TREE


badhandles = [];
entry.src_file = [];

% Verify dates and try to obtain source audio
for f = {'pickstartdisplay', 'pickenddisplay'}
    f = f{1};
    value = get(handles.(f), 'String');
    try
        if ~ handles.log.pickend_mandatory  && strcmp(f, 'pickenddisplay')
            % Allowed to skip end dates?
            if isempty(value)
                continue;
            end
        end
        entry.(f) = datenum(value);
        if isempty(entry.(f))
                badhandles(end+1) = handles.(f);
        else
            entry.(f) = entry.(f);
        end
    catch
        badhandles(end+1) = handles.(f);
    end
   
    if isempty(entry.src_file)
        % time, freq, and filename are stored when a user picks a time x freq node.
        % However, they could have entered the start date by hand (or modified it
        % after a pick) in which case we won't know what file they took it from.
        % If its present, use it from either the start or end pick
        tf = get(handles.(f), 'UserData');
        if ~isempty(tf)
            entry.src_file = tf.src_file;
        end
    end

end


if isfield(entry, 'pickenddisplay') && (entry.pickenddisplay < entry.pickstartdisplay)
    badfield(handles.pickenddisplay, 'Before start', .5);
    return
end
Svalue = get(handles.species.pulldown, 'Value');
entry.species = TREE.speciesW{Svalue};

% Retrieve attributes of calls (if any)
entry.callAttrib = get(handles.species.pulldown, 'UserData');

% Retrieve active call types
% Not necessarily in same order as call attributes
callH = get(handles.speciesbuttons, 'children');
callV = get(callH, 'Value');
if iscell(callV)  % when multiple calls are active, callV is a cell array
    callV = logical(cell2mat(callV));
else
    callV = logical(callV);
end
if sum(callV) == 0
    % Must have at least one call type selected
    badhandles(end+1:end+length(callH)) = callH;
else
    entry.calls = get(callH(callV), 'String');
    if ischar(entry.calls)
        entry.calls = {entry.calls};  %ensure cell array
    end
end

if ~isempty(badhandles)
    badfield(badhandles, [], .6);
    return;
end

% Generate event id
time = clock;
entry.event = datestr(time, 'yyyy/mm/dd HH:MM:SS');

% Generate the basename for image and audio files
entry.fname_time = sprintf('%s-%s-%s', ...
    TREE.speciesR{Svalue}, handles.Meta.file_tag, ...
    datestr(entry.pickstartdisplay, 'yyyymmddTHHMMSS'));

entry.comment = get(handles.comments, 'String');

% find out if audio or image files were created 
set(handles.savexwavbutton, 'String', 'Save Audio')
if ~ isempty(handles.log.audio);
    [dir, fname, ext] = fileparts(handles.log.audio);
    if regexp(handles.log.audio, '.*\.x\.wav$')
        ext = '.x.wav';
    end
    entry.audio = [entry.fname_time, ext];
    success = movefile(handles.log.audio, fullfile(dir, entry.audio));
    if ~ success
        errordlg(sprintf('Unable to rename %s to %s.  Permission problem?', ...
            handles.log.audio, fullfile(dir, entry.audio)));
        handles.log.audio = [];
        return
    end
else
    entry.audio = [];
end
handles.log.audio = [];

set(handles.savejpegbutton, 'String', 'Save Image')
if ~ isempty(handles.log.image)
    [dir, fname, ext] = fileparts(handles.log.image);
    entry.image = [entry.fname_time, ext];
    success = movefile(handles.log.image, fullfile(dir, entry.image));
    if ~ success
        handles.log.image = [];
        errordlg(sprintf('Unable to rename %s to %s.  Permission problem?', ...
            handles.log.image, fullfile(dir, entry.image)));
        return
    end
else
    entry.image = [];
end
handles.log.image = [];

% Data for detection entry has been gathered, determine where it
% will be stored.
detection = handles.(PARAMS.log.mode);

% Add one row for each call that is being logged
currentRow = log_lastRow(detection.Sheet);
for callIdx = 1:length(entry.calls)
    currentRow = currentRow+1;
    
    % adjust event number to make unique
    if callIdx > 1
        entry.event = datestr(clock, 'mm/dd/yyyy HH:MM:SS.FFF');
    end
    
    for hidx = 1:length(detection.Headers)
        if findstr(detection.Headers{hidx}, 'Parameter') == 1
            continue  % parameters are a special case
        end
        column = excelColumn(hidx - 1);
        Range = detection.Sheet.Range(sprintf('%s%d', column, currentRow));
        
        % Some fields are only populated for the first call
        firstonly = false; 
        
        switch lower(detection.Headers{hidx})
            case 'input file'
                set(Range, 'Value', entry.src_file);
            case 'start time'
                set(Range, 'Value', entry.pickstartdisplay - date_epoch('excel'));
            case 'end time'
                if isfield(entry, 'pickenddisplay')
                    set(Range, 'Value', entry.pickenddisplay - date_epoch('excel'));
                end
            case 'event number'
                set(Range, 'Value', entry.event);
            case 'species code'
                set(Range, 'Value', entry.species);
            case 'call'
                set(Range, 'Value', entry.calls{callIdx})
            otherwise 
                firstonly = true;
        end
        
        if callIdx == 1 && firstonly
            switch lower(detection.Headers{hidx})
                case 'audio'
                    if ~ isempty(entry.audio)
                        set(Range, 'Value', entry.audio);
                    end
                case 'image'
                    if ~ isempty(entry.image)
                        set(Range, 'Value', entry.image);
                    end
                case 'comments'
                    if ~ isempty(entry.comment)
                        set(Range, 'Value', entry.comment);
                    end
            end
        end
        
        % Note that we do not process parameter headers here
    end
    
    % Handle parameters associated with the call
    % Find the parameters associated with the call:
    attrIdx = find(strcmp({entry.callAttrib.call}, entry.calls{callIdx}) == 1);
    % Set parameters
    for pidx = 1:length(entry.callAttrib(attrIdx).values)
        if ~ isnan(entry.callAttrib(attrIdx).values(pidx))
            % Populate cell associated with parameter pidx
            Range = detection.Sheet.Range(...
                sprintf('%s%d', detection.ParamCols{pidx}, currentRow));
            set(Range, 'Value', entry.callAttrib(attrIdx).values(pidx));
        end
    end
end

control_log('display_lastentry');  % Update last logged entry

% Reset parameters, but preserve checkmarks on calls
checked = get(handles.calltype, 'Value');
if iscell(checked)
    checked = cell2mat(checked);
end
control_log(handles.species.pulldown, [], 'species');
for idx=1:length(checked)
    if checked(idx) > 0
        set(handles.calltype(idx), 'Value', checked(idx));
        
    end
end

% Find last checked box and invoke the callback
if sum(checked) > 0
    % At leat one call type was checked, call the selection callback
    % for any one of them to update the parameters
    paramfn = get(handles.calltype(1), 'Callback');
    paramfn{1}([], [], []);
end

for f = {'pickstartdisplay', 'pickenddisplay', 'comments'}
    f = f{1};
    set(handles.(f), 'String', '');
end

% Save every Nth log entry
if mod(currentRow, 5) == 0
    handles.Workbook.Save();
end

1;
