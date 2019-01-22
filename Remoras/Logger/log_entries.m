function entries = log_entries(effort, rows, format)
% log_entries(effort, rows, format)
% Given a structure containing information about on/off effort,
% return detections for the specified rows.  Data starts on row 2 and 
% the function log_lastRow can be used to find the last row used.
% If variable format is true, entry is formatted as a string and 
% entries will contain an array of strings.  When format is false, 
% a matrix of values are returned.
%
% example:  sprintf('%s\n', log_entries(handles.OnEffort, 2:5, true)

global TREE;


commonnames = true;

if isempty(rows)
    entries = {};
end

lastRow = log_lastRow(effort.Sheet);
if rows(end) > lastRow 
    error('Worksheet only has %s rows', lastRow);
end


lastCol = excelColumn(length(effort.Headers)-1);
% Find contiguous groups, e.g. 2:7,


groups = find(diff(rows) > 1)+1;
if isempty(groups)
    groups = [1, length(rows)];
else
    groups = [1; groups(:)];
    groups = [groups, [groups(2:end)-1; length(rows)]];
end
row_groups = rows(groups);

% Values returned
entries = cell(length(rows), length(effort.Headers));

for gidx = 1:size(row_groups, 1)
    range = effort.Sheet.Range(sprintf(...
        'A%d:%s%d', row_groups(gidx, 1), lastCol, row_groups(gidx, 2)));
    entries(groups(gidx,1):groups(gidx,2), :) = range.Value();
end

if commonnames
    namecol = find(~cellfun(@isempty, ...
        strfind(effort.Headers, 'Species Code')));
    for idx=1:size(entries, 1)
       codeidx = ~cellfun(@isempty, ...
           strfind(TREE.textW(:,2), entries{idx, namecol}));
       entries{idx, namecol} = TREE.textR{codeidx,2};
    end
end

1;

           
if format
    UseCols = {
        'Species Code', '%s'
        'Call', '%s'
        'Start time', 'date'
        'End time', 'date'
        };
    formatted = cell(size(entries, 1), 1);
    for lidx=1:size(entries, 1)
        str = '';
        for fidx = 1:size(UseCols, 1)
            cidx = findHeader(UseCols{fidx, 1}, effort);
            switch UseCols{fidx, 2}
                case 'date'
                    if ischar(entries{lidx, cidx})
                        str = sprintf('%s%s ', str, entries{lidx, cidx});
                    elseif ~isempty(entries{lidx, cidx}) ...
                            && ~isnan(entries{lidx, cidx})
                        str = sprintf('%s%s ', str, ...
                            datestr(entries{lidx, cidx} + ...
                            date_epoch('excel'),'YYYY-mm-DD HH:MM:SS'));
                    end
                case '%s'
                    str = sprintf('%s%s ', str, entries{lidx, cidx});
            end
        end
        formatted{lidx} = str;
    end
    entries = formatted;
end

function colI = findHeader(field, effort)
% Return logical array indicating the column the specified header is in
colI = ~cellfun(@isempty, strfind(effort.Headers, field));
