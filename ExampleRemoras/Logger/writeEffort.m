function writeEffort(rootNode, spreadsheet)
% writeEffort(rootNode, spreadsheet)
% Based on the current effort tree rooted at rootNode,
% write the Effort to a spreadhseet.  Spreadsheet may be
% either a string indicating a filename to be used or 
% a handle to an active X (OLE) spreadsheet.

debug = true;
if debug
    global handles
    handles.Server.visible = true;
end

global TREE
currNode = rootNode.getFirstChild();
tLength = rootNode.getDepth();
if nargout > rootNode.getDepth()
    tLength = nargout-1;
end
struct = cell(1,tLength);
if strcmp(TREE.gran, 'binned')
    granOffset = 2;
    granCell = cell(1,2);%creat a  cell array, will only have two values and set
    granCell{1} = TREE.gran;%to appropiate values. 
    granCell{2} = TREE.binTime;
    binnedTime = true;
else
    granOffset = 1;
    granCell = cell(1,1);
    granCell{1} = TREE.gran;
    binnedTime = false;
end
list = cell(0,tLength);
flag1 = 0;
level = currNode.getLevel();
first = true;

% params will be built into a matrix with default
% parameters, one row for each species.  We double
% the number of columns to accomadate users that
% need to store time with selections.
params = cell(0, 2*size(TREE.frequency,2));

while ~isempty(currNode) || level > 1
    
    previous = currNode;
    level = currNode.getLevel();
    gpValue = currNode.getValue();
    %disp(char(gpValue(2)));
    selected = strcmp(gpValue(1), 'selected');
    if selected
        level = currNode.getLevel();
        % We need to store two values for the second level of the tree
        % Common name and abbreviation
        offset = level >= 2;
        if level == 2
            values{level} = char(currNode.getName());
        end
        values{currNode.getLevel()+offset} = char(gpValue(2));
        traverseChildren = currNode.getAllowsChildren();
        
        if traverseChildren
            % Traverse children
            currNode = currNode.getFirstChild();
        else
            % At a leaf node.  values{1:level} contain the tree info
            list(end+1,1:level+offset) = values(1:level+offset);
            if first
                values{1} = '';  % effort template does not repeat group
            end
        end
    else
        traverseChildren = false;
    end
    
    %disp([num2str(isempty(currNode.getNextSibling())), ' ', num2str(~isempty(currNode.getParent()))]);
    if ~ traverseChildren
        % Don't go further down the chain
        % We are either at a leaf or we are not interested in this chain
        
        if ~isempty(currNode.getNextSibling())
            % process siblings of the current node
            currNode = currNode.getNextSibling();
        elseif ~isempty(currNode.getParent().getNextSibling())
            % no more siblings, process parent's siblings
            currNode = currNode.getParent().getNextSibling();
        elseif level ~= 1
            % process grandparent's sibling
            % Todo:  Make the whole process more general, perhaps
            %        use a stack and push/pop
            level = currNode.getParent().getParent().getLevel();
            currNode = currNode.getParent().getParent().getNextSibling();
        end
    end
    
    if previous == currNode
        break
    end
end

if ischar(spreadsheet)
    % filename, try to open it
    try
        Excel = actxserver('Excel.Application');
    catch err
        errordlg('Unable to access spreadsheet interface')
        return
    end
    %Excel.Visible = 1;  % for debugging

    try
        Workbook = Excel.workbooks.Open(spreadsheet);  % Open workbook
    catch err
        errordlg(sprintf('Unable to open spreadsheet %s', spreadsheet));
        return
    end
else
    Workbook = spreadsheet;  % Already open, copy handle
end

try
    EffortSheet = Workbook.Sheets.Item('Effort'); % Access the Effort sheet
catch
    errordlg('Master template missing Effort sheet');
end

% erase and rewrite headers with granularity and bintime as columns
colsN = EffortSheet.UsedRange.Columns.Count;
cellRange = sprintf('A1:%s1', excelColumn(colsN));%need proper range format
headerRange = get(EffortSheet, 'Range', cellRange);%get the range of the headers
headerRangeCell = headerRange.value;%convert from range object to cell array




% Traverse rows, removing unselected ones and setting the granularity
% where needed.  We move in reverse order as rows are deleted and this
% prevents problems with rows shifting.  Our list variable must be
% in the same order as the effort sheet or things will break.  As the
% list was generated from the effort sheet, this should not be problematic.

% Replace NaN with '' so regexp doesn't faile
charI = cellfun(@ischar, headerRangeCell);
for idx = find(~charI)
    headerRangeCell{idx} = '';
end
speciesCol= find(strcmp(headerRangeCell, 'Species Code'));
callCol = find(strcmp(headerRangeCell, 'Call'));
granCol = excelColumn(find(strcmp(headerRangeCell, 'Granularity'))-1);
groupCol = excelColumn(find(strcmp(headerRangeCell, 'Group'))-1);

if length(granCell) > 1
    % BinSize required
    granLastCol = excelColumn(find(strcmp(headerRangeCell, 'BinSize_m'))-1);
else
    granLastCol = granCol;
end

selectedidx = size(list, 1);

RowsN = EffortSheet.UsedRange.Rows.Count;  % #rows in sheet
effortidx = RowsN;

whitespace = false;  % for retaining spacing between entries 
while effortidx > 1 && selectedidx >= 1
    % Is the current row equivalent to the last row in list?
    Range = EffortSheet.Range(sprintf('%d:%d', effortidx, effortidx));
    values = Range.value;
    
    if ischar(values{callCol}) && ischar(values{speciesCol}) && ...
            strcmp(values{callCol}, list{selectedidx, callCol}) && ...  
            strcmp(values{speciesCol}, list{selectedidx, speciesCol})
            % Matches, add granularity
            GranRange = EffortSheet.Range(...
                sprintf('%s%d:%s%d', granCol, effortidx, granLastCol, effortidx));
            set(GranRange, 'Value', granCell);
        
            if ~isempty(list{selectedidx, 1})
                % first item in group, set group name
                GrpRange = EffortSheet.Range(...
                    sprintf('%s%d:%s%d', groupCol, effortidx, groupCol, effortidx));
                set(GrpRange, 'Value', list{selectedidx, 1});
            end
            selectedidx = selectedidx - 1;        
            whitespace = false;
    else
        % The first empty row after retaining an entry is retained.
        % All others are removed.
        has_data = sum(cellfun(@ischar, values));        
        if has_data || whitespace
            Range.Delete();
        end
        if ~ has_data
            whitespace = true;
        end
    end
    effortidx = effortidx - 1;
end

% Remove any remaining rows
while effortidx > 1
    Range = EffortSheet.Range(sprintf('%d:%d', effortidx, effortidx));
    Range.Delete();
    effortidx = effortidx - 1;
end

if ischar(spreadsheet)
    % save and close, user wanted file operation
    Workbook.Save();  % Save changes
    Workbook.Close(false);  % Close program
    Excel.Quit;  % Exit server
end


