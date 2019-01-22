function [tree, RootName, DOMnode] = xml_read(xmlfile, Pref)
%XML_READ reads xml files and converts them into Matlab's struct tree.
%
% DESCRIPTION
% tree = xml_read(xmlfile) reads 'xmlfile' into data structure 'tree'
%
% tree = xml_read(xmlfile, Pref) reads 'xmlfile' into data structure 'tree'
% according to your preferences
%
% [tree, RootName, DOMnode] = xml_read(xmlfile) get additional information
% about XML file
%
% INPUT:
%  xmlfile	URL or filename of xml file to read
%  Pref     Preferences:
%    Pref.ItemName - default 'item' - name of a special tag used to itemize
%                    cell arrays
%    Pref.ReadAttr - default true - allow reading attributes
%    Pref.ReadSpec - default true - allow reading special nodes
%    Pref.Str2Num  - default 'smart' - convert strings that look like numbers
%                   to numbers. Options: "always", "never", and "smart"
%    Pref.KeepNS   - default true - keep or strip namespace info
%    Pref.NoCells  - default true - force output to have no cell arrays
%    Pref.Debug    - default false - show mode specific error messages
%    Pref.NumLevels- default infinity - how many recursive levels are
%      allowed. Can be used to speed up the function by prunning the tree.
%    Pref.RootOnly - default true - output variable 'tree' corresponds to
%      xml file root element, otherwise it correspond to the whole file.
%    Pref.SeparateAttr - default 'false' - Rather than creating a field
%               with the attribute name and subfields CONTENT and
%               ATTRIBUTE, two fields are created.  The first is the
%               element name, the second is the element name followed
%               by _attr.  This permits uniform treatment of nodes with
%               and without attributes as the default will create
%               substrctures only when an attribute is present.
%    Pref.CellItem - default 'true' - leave 'item' nodes in cell notation.
% OUTPUT:
%  tree         tree of structs and/or cell arrays corresponding to xml file
%  RootName     XML tag name used for root (top level) node.
%               Optionally it can be a string cell array storing: Name of
%               root node, document "Processing Instructions" data and
%               document "comment" string
%  DOMnode      output of xmlread
%
% DETAILS:
% Function xml_read first calls MATLAB's xmlread function and than
% converts its output ('Document Object Model' tree of Java objects)
% to tree of MATLAB struct's. The output is in format of nested structs
% and cells. In the output data structure field names are based on
% XML tags, except in cases when tags produce illegal variable names.
%
% Several special xml node types result in special tags for fields of
% 'tree' nodes:
%  - node.CONTENT - stores data section of the node if other fields are
%    present. Usually data section is stored directly in 'node'.
%  - node.ATTRIBUTE.name - stores node's attribute called 'name'.
%  - node.COMMENT - stores node's comment section (string). For global
%    comments see "RootName" output variable.
%  - node.CDATA_SECTION - stores node's CDATA section (string).
%  - node.PROCESSING_INSTRUCTIONS - stores "processing instruction" child
%    node. For global "processing instructions" see "RootName" output variable.
%  - other special node types like: document fragment nodes, document type
%   nodes, entity nodes, notation nodes and processing instruction nodes
%   will be treated like regular nodes
%
% EXAMPLES:
%   MyTree=[];
%   MyTree.MyNumber = 13;
%   MyTree.MyString = 'Hello World';
%   xml_write('test.xml', MyTree);
%   [tree treeName] = xml_read ('test.xml');
%   disp(treeName)
%   gen_object_display()
%   % See also xml_examples.m
%
% See also:
%   xml_write, xmlread, xmlwrite
%
% Written by Jarek Tuszynski, SAIC, jaroslaw.w.tuszynski_at_saic.com
% References:
%  - Function inspired by Example 3 found in xmlread function.
%  - Output data structures inspired by xml_toolbox structures.

%% default preferences
DPref.ItemName  = 'item'; % name of a special tag used to itemize cell arrays
DPref.CellItem  = false;  % leave 'item' nodes in cell notation
DPref.ReadAttr  = true;   % allow reading attributes
DPref.ReadSpec  = true;   % allow reading special nodes: comments, CData, etc.
DPref.KeepNS    = true;   % Keep or strip namespace info
DPref.Str2Num   = 'smart';% convert strings that look like numbers to numbers
DPref.NoCells   = true;   % force output to have no cell arrays
DPref.NumLevels = 1e10;   % number of recurence levels
DPref.PreserveSpace = false; % Preserve or delete spaces at the beginning and the end of stings?
DPref.SeparateAttr = false;  % Separate field for attributes?
RootOnly        = true;   % return root node  with no top level special nodes
Debug           = false;  % show specific errors (true) or general (false)?
tree            = [];
RootName        = [];

%% Check Matlab Version
v = ver('MATLAB');
version = str2double(regexp(v.Version, '\d.\d','match','once'));
if (version<7.1)
  error('Your MATLAB version is too old. You need version 7.1 or newer.');
end

%% read user preferences
if (nargin>1)
  if (isfield(Pref, 'ItemName' )), DPref.ItemName  = Pref.ItemName;  end
  if (isfield(Pref, 'CellItem' )), DPref.CellItem  = Pref.CellItem;  end
  if (isfield(Pref, 'Str2Num'  )), DPref.Str2Num   = Pref.Str2Num ;  end
  if (isfield(Pref, 'NoCells'  )), DPref.NoCells   = Pref.NoCells ;  end
  if (isfield(Pref, 'NumLevels')), DPref.NumLevels = Pref.NumLevels; end
  if (isfield(Pref, 'ReadAttr' )), DPref.ReadAttr  = Pref.ReadAttr;  end
  if (isfield(Pref, 'ReadSpec' )), DPref.ReadSpec  = Pref.ReadSpec;  end
  if (isfield(Pref, 'KeepNS'   )), DPref.KeepNS    = Pref.KeepNS;    end
  if (isfield(Pref, 'RootOnly' )), RootOnly        = Pref.RootOnly;  end
  if (isfield(Pref, 'Debug'    )), Debug           = Pref.Debug   ;  end
  if (isfield(Pref, 'PreserveSpace')), DPref.PreserveSpace = Pref.PreserveSpace; end
  if (isfield(Pref, 'SeparateAttr')), DPref.SeparateAttr = Pref.SeparateAttr; end
end
if ischar(DPref.Str2Num), % convert from character description to numbers
  DPref.Str2Num = find(strcmpi(DPref.Str2Num, {'never', 'smart', 'always'}))-1;
  if isempty(DPref.Str2Num), DPref.Str2Num=1; end % 1-smart by default
end

%% read xml file using Matlab function
if isa(xmlfile, 'org.apache.xerces.dom.DeferredDocumentImpl') || ...
   isa(xmlfile, 'org.apache.xerces.dom.DeferredElementImpl')
  % if xmlfile is a DOMnode than skip the call to xmlread
  try
    try
      DOMnode = xmlfile;
    catch ME
      error('Invalid DOM node: \n%s.', getReport(ME));
    end
  catch %#ok<CTCH> catch for mablab versions prior to 7.5
    error('Invalid DOM node. \n');
  end
else         % we assume xmlfile is a filename
  if (Debug) % in debuging mode crashes are allowed
    DOMnode = xmlread(xmlfile);
  else       % in normal mode crashes are not allowed
    try
      try
        DOMnode = xmlread(xmlfile);
      catch ME
        error('Failed to read XML file %s: \n%s',xmlfile, getReport(ME));
      end
    catch %#ok<CTCH> catch for mablab versions prior to 7.5
      error('Failed to read XML file %s\n',xmlfile);
    end
  end
end
Node = DOMnode.getFirstChild;

%% Find the Root node. Also store data from Global Comment and Processing
%  Instruction nodes, if any.
GlobalTextNodes = cell(1,3);
GlobalProcInst  = [];
GlobalComment   = [];
GlobalDocType   = [];
while (~isempty(Node))
  if (Node.getNodeType==Node.ELEMENT_NODE)
    RootNode=Node;
  elseif (Node.getNodeType==Node.PROCESSING_INSTRUCTION_NODE)
    data   = strtrim(char(Node.getData));
    target = strtrim(char(Node.getTarget));
    GlobalProcInst = [target, ' ', data];
    GlobalTextNodes{2} = GlobalProcInst;
  elseif (Node.getNodeType==Node.COMMENT_NODE)
    GlobalComment = strtrim(char(Node.getData));
    GlobalTextNodes{3} = GlobalComment;
    %   elseif (Node.getNodeType==Node.DOCUMENT_TYPE_NODE)
    %     GlobalTextNodes{4} = GlobalDocType;
  end
  Node = Node.getNextSibling;
end

%% parse xml file through calls to recursive DOMnode2struct function
if (Debug)   % in debuging mode crashes are allowed
  [tree RootName] = DOMnode2struct(RootNode, DPref, 1);
else         % in normal mode crashes are not allowed
  try
    try
      [tree RootName] = DOMnode2struct(RootNode, DPref, 1);
    catch ME
      error('Unable to parse XML file %s: \n %s.',xmlfile, getReport(ME));
    end
  catch %#ok<CTCH> catch for mablab versions prior to 7.5
    error('Unable to parse XML file %s.',xmlfile);
  end
end

%% If there were any Global Text nodes than return them
if (~RootOnly)
  if (~isempty(GlobalProcInst) && DPref.ReadSpec)
    t.PROCESSING_INSTRUCTION = GlobalProcInst;
  end
  if (~isempty(GlobalComment) && DPref.ReadSpec)
    t.COMMENT = GlobalComment;
  end
  if (~isempty(GlobalDocType) && DPref.ReadSpec)
    t.DOCUMENT_TYPE = GlobalDocType;
  end
  t.(RootName) = tree;
  tree=t;
end
if (~isempty(GlobalTextNodes))
  GlobalTextNodes{1} = RootName;
  RootName = GlobalTextNodes;
end


%% =======================================================================
%  === DOMnode2struct Function ===========================================
%  =======================================================================
function [s TagName LeafNode] = DOMnode2struct(node, Pref, level)

%% === Step 1: Get node name and check if it is a leaf node ==============
[TagName LeafNode] = NodeName(node, Pref.KeepNS);
s = []; % initialize output structure

%% === Step 2: Process Leaf Nodes (nodes with no children) ===============
if (LeafNode)
  if (LeafNode>1 && ~Pref.ReadSpec), LeafNode=-1; end % tags only so ignore special nodes
  if (LeafNode>0) % supported leaf node types
    try
      try         % use try-catch: errors here are often due to VERY large fields (like images) that overflow java memory
        s = char(node.getData);
        if (isempty(s)), s = ' '; end                              % make it a string
        % for some reason current xmlread 'creates' a lot of empty text
        % fields with first chatacter=10 - those will be deleted.
        if (~Pref.PreserveSpace || s(1)==10) 
          if (isspace(s(1)) || isspace(s(end))), s = strtrim(s); end % trim spaces if any
        end
        if (LeafNode==1), s=str2var(s, Pref.Str2Num, 0); end       % convert to number(s) if needed
      catch ME    % catch for mablab versions 7.5 and higher
        warning('xml_io_tools:read:LeafRead', ...
          'This leaf node could not be read and was ignored. ');
        getReport(ME)
      end
    catch         %#ok<CTCH> catch for mablab versions prior to 7.5
      warning('xml_io_tools:read:LeafRead', ...
        'This leaf node could not be read and was ignored. ');
    end
  end
  if (LeafNode==3) % ProcessingInstructions need special treatment
    target = strtrim(char(node.getTarget));
    s = [target, ' ', s];
  end
  return % We are done the rest of the function deals with nodes with children
end
if (level>Pref.NumLevels+1), return; end % if Pref.NumLevels is reached than we are done

%% === Step 3: Process nodes with children ===============================
if (node.hasChildNodes)        % children present
  Child  = node.getChildNodes; % create array of children nodes
  nChild = Child.getLength;    % number of children
  
  % --- pass 1: how many children with each name -----------------------
  f = [];
  for iChild = 1:nChild        % read in each child
    [cname cLeaf] = NodeName(Child.item(iChild-1), Pref.KeepNS);
    if (cLeaf<0), continue; end % unsupported leaf node types
    if (~isfield(f,cname)),
      f.(cname)=0;           % initialize first time I see this name
    end
    f.(cname) = f.(cname)+1; % add to the counter
  end                        % end for iChild
  % text_nodes become CONTENT & for some reason current xmlread 'creates' a
  % lot of empty text fields so f.CONTENT value should not be trusted
  if (isfield(f,'CONTENT') && f.CONTENT>2), f.CONTENT=2; end
  
  % --- pass 2: store all the children as struct of cell arrays ----------
  for iChild = 1:nChild        % read in each child
    [c cname cLeaf] = DOMnode2struct(Child.item(iChild-1), Pref, level+1);
    if (cLeaf && isempty(c))   % if empty leaf node than skip
      continue;                % usually empty text node or one of unhandled node types
    elseif (nChild==1 && cLeaf==1)
      s=c;                     % shortcut for a common case
    else                       % if normal node
      if (level>Pref.NumLevels), continue; end
      n = f.(cname);           % how many of them in the array so far?
      if (Pref.SeparateAttr)
          cattr = sprintf('%s_attr', cname);
          if isfield(c, 'CONTENT')
              content = c.CONTENT;
              attribute = c.ATTRIBUTE;
          else
              content = c;
              attribute = [];
          end
          if (~isfield(s,cname))   % encountered this name for the first time
            if (n==1)              % if there will be only one of them ...
              s.(cname) = content;       % than save it in format it came in
              s.(cattr) = attribute;
            else                   % if there will be many of them ...
              s.(cname) = cell(1,n);
              s.(cname){1} = content;    % than save as cell array
              s.(cattr){1} = attribute;
            end
            f.(cname) = 1;         % initialize the counter
          else                     % already have seen this name
            s.(cname){n+1} = content;    % add to the array
            s.(cattr){n+1} = attribute;
            f.(cname) = n+1;       % add to the array counter
          end
      else
          if (~isfield(s,cname))   % encountered this name for the first time
            if (n==1)              % if there will be only one of them ...
              s.(cname) = c;       % than save it in format it came in
            else                   % if there will be many of them ...
              s.(cname) = cell(1,n);
              s.(cname){1} = c;    % than save as cell array
            end
            f.(cname) = 1;         % initialize the counter
          else                     % already have seen this name
            s.(cname){n+1} = c;    % add to the array
            f.(cname) = n+1;       % add to the array counter
          end
      end
    end
  end   % for iChild
end % end if (node.hasChildNodes)

%% === Step 4: Post-process struct's created for nodes with children =====
if (isstruct(s))
  fields = fieldnames(s);
  % Ignore any fieldnames with _attr in them
  if Pref.SeparateAttr
      vfields = fields(cellfun(@isempty, strfind(fieldnames(s), '_attr')));
  else
      vfields = fields;
  end
  nField = length(vfields);

  % --- Post-processing: convert 'struct of cell-arrays' to 'array of structs'
  % Example: let say s has 3 fields s.a, s.b & s.c  and each field is an
  % cell-array with more than one cell-element and all 3 have the same length.
  % Then change it to array of structs, each with single cell.
  % This way element s.a{1} will be now accessed through s(1).a
  vec = zeros(nField, 1);
  for i=1:nField, vec(i) = f.(vfields{i}); end
  if (numel(vec)>1 && vec(1)>1 && var(vec)==0)  % convert from struct of
    s = cell2struct(struct2cell(s), fields, 1); % arrays to array of struct
  end % if anyone knows better way to do above conversion please let me know.

end

%% === Step 5: Process nodes with attributes =============================
if (node.hasAttributes && Pref.ReadAttr)
  if (~isstruct(s)),              % make into struct if is not already
    ss.CONTENT=s;
    s=ss;
  end
  Attr  = node.getAttributes;     % list of all attributes
  for iAttr = 1:Attr.getLength    % for each attribute
    name  = char(Attr.item(iAttr-1).getName);  % attribute name
    name  = str2varName(name, Pref.KeepNS);    % fix name if needed
    value = char(Attr.item(iAttr-1).getValue); % attribute value
    value = str2var(value, Pref.Str2Num, 1);   % convert to number if possible
    s.ATTRIBUTE.(name) = value;   % save again
  end                             % end iAttr loop
end % done with attributes
if (~isstruct(s)), return; end %The rest of the code deals with struct's

%% === Post-processing: fields of "s"
% convert  'cell-array of structs' to 'arrays of structs'
fields = fieldnames(s);     % get field names
nField = length(fields);
for iItem=1:length(s)       % for each struct in the array - usually one
  for iField=1:length(fields)
    field = fields{iField}; % get field name
    % if this is an 'item' field and user want to leave those as cells
    % than skip this one
    if (strcmpi(field, Pref.ItemName) && Pref.CellItem), continue; end
    x = s(iItem).(field);
    if (iscell(x) && all(cellfun(@isstruct,x)) && numel(x)>1) % it's cell-array of structs
      % numel(x)>1 check is to keep 1 cell-arrays created when Pref.CellItem=1
      try                           % this operation fails sometimes
        % example: change s(1).a{1}.b='jack'; s(1).a{2}.b='john'; to
        % more convinient s(1).a(1).b='jack'; s(1).a(2).b='john';
        s(iItem).(field) = [x{:}]';  %#ok<AGROW> % converted to arrays of structs
      catch %#ok<CTCH>
        % above operation will fail if s(1).a{1} and s(1).a{2} have
        % different fields. If desired, function forceCell2Struct can force
        % them to the same field structure by adding empty fields.
        if (Pref.NoCells)
          s(iItem).(field) = forceCell2Struct(x); %#ok<AGROW>
        end
      end % end catch
    end
  end
end

%% === Step 4: Post-process struct's created for nodes with children =====

% --- Post-processing: remove special 'item' tags ---------------------
% many xml writes (including xml_write) use a special keyword to mark
% arrays of nodes (see xml_write for examples). The code below converts
% s.item to s.CONTENT
ItemContent = false;
if (isfield(s,Pref.ItemName))
  s.CONTENT = s.(Pref.ItemName);
  s = rmfield(s,Pref.ItemName);
  ItemContent = Pref.CellItem; % if CellItem than keep s.CONTENT as cells
end

% --- Post-processing: clean up CONTENT tags ---------------------
% if s.CONTENT is a cell-array with empty elements at the end than trim
% the length of this cell-array. Also if s.CONTENT is the only field than
% remove .CONTENT part and store it as s.
if (isfield(s,'CONTENT'))
  if (iscell(s.CONTENT))
    x = s.CONTENT;
    for i=length(x):-1:1, if ~isempty(x{i}), break; end; end
    if (i==1 && ~ItemContent)
      s.CONTENT = x{1};   % delete cell structure
    else
      s.CONTENT = x(1:i); % delete empty cells
    end
  end
  if (nField==1)
    if (ItemContent)
      ss = s.CONTENT;       % only child: remove a level but ensure output is a cell-array
      s=[]; s{1}=ss;
    else
      s = s.CONTENT;        % only child: remove a level
    end
  end
end



%% =======================================================================
%  === forceCell2Struct Function =========================================
%  =======================================================================
function s = forceCell2Struct(x)
% Convert cell-array of structs, where not all of structs have the same
% fields, to a single array of structs

%% Convert 1D cell array of structs to 2D cell array, where each row
% represents item in original array and each column corresponds to a unique
% field name. Array "AllFields" store fieldnames for each column
AllFields = fieldnames(x{1});     % get field names of the first struct
CellMat = cell(length(x), length(AllFields));
for iItem=1:length(x)
  fields = fieldnames(x{iItem});  % get field names of the next struct
  for iField=1:length(fields)     % inspect all fieldnames and find those
    field = fields{iField};       % get field name
    col = find(strcmp(field,AllFields),1);
    if isempty(col)               % no column for such fieldname yet
      AllFields = [AllFields; field];
      col = length(AllFields);    % create a new column for it
    end
    CellMat{iItem,col} = x{iItem}.(field); % store rearanged data
  end
end
%% Convert 2D cell array to array of structs
s = cell2struct(CellMat, AllFields, 2);

%% =======================================================================
%  === str2var Function ==================================================
%  =======================================================================
function val=str2var(str, option, attribute)
% Can this string 'str' be converted to a number? if so then do it.
val = str;
len = numel(str);
if (len==0    || option==0), return; end % Str2Num="never" of empty string -> do not do enything
%if (len>10000 && option==1), return; end % Str2Num="smart" and string is very long -> probably base64 encoded binary
if option == 1 && len > 100
    option = 2;  % probably not a date if that long...
end
if option == 1
    % smart conversion
    
    % Check if this is likely to be a date, not foolproof, but
    % if there are patterns separated by / - or : it could very well be.
    % We also assume that dates do not have spaces or square brackets
    date_re = '(.+[/-].+[/-])|(.+:.+)|';
    date_elements = regexp(str, date_re, 'once');
    % Look for things that we think should reject this as a date
    if isempty(date_elements)
        % might be a date, check for things that we should reject
        % square brackets [ ], spaces (note that this assumes
        % July 21, 1969 is an invalid date)
        date_reject_re = '[\[\] ]';
        date_reject_elements = regexp(str, date_reject_re, 'once');
        if isempty(date_reject_elements)
            try
                datenum(str); % leave it as a string if conversion works
            catch
                option = 2;  % Try to convert to a number
            end

        else
            option = 2;
        end
    else
        option = 2;
    end
end
if option == 2
    converted = true;  % assume converted to number until otherwise

    % Try the cheap conversion first
    num = str2double(str);
    
    if isnan(num) && attribute == 0
        % Conversion failed or it really was a NaN
        % Try to scan for numbers after pulling out:  [ ] , ;
        [num, count, errmsg] = sscanf(regexprep(str, '\[|\[|,|;', ' '), '%g');
        if isempty(errmsg)
            % Converted, do we need to format the matrix?
            if count > 1
                rows = length(regexp(str, '.$|;', 'lineanchors'));
                % Does the number of rows divide evenly into the number
                % of elements?  We check both rows and rows - 1 as the
                % user may or may not have put line feeds or ; to separate
                % the rows
                if rows
                    rowcount = 1;
                    if ~ rem(count, rows)
                        rowcount = rows;
                    end
                    if rowcount > 1 % format as matrix
                        cols = count / rowcount;
                        num = reshape(num, rowcount, cols)';                        
                    end
                end
            end
        else
            converted = false;
        end
        % OLD CODE
        % Stopped using str2num as it calls eval which is:
        %   1) slow
        %   2) dangerous, text with function names is evaluated
        %
        % Let's see if it was likely to be a number
        % Strip out everything that would be a valid number and see what's
        % left.
        %digits = '(Inf)|(NaN)|(pi)|[\t\n\d\+\-\*\.ei EI\[\]\;\,]';
        %s = regexprep(str, digits, ''); % remove all the digits and other allowed characters
        %if ~all(~isempty(s))
        %    % Convert linefeeds to ; for 2D arrays
        %    str(strfind(str, '\n')) = ';';
        %end
        %num = str2num(str);
    elseif isnan(num) && ~strcmp(str, 'NaN') && attribute == 1
                [num, count, errmsg] = sscanf(regexprep(str, '\[|\[|,|;', ' '), '%g');
        if isempty(errmsg)
            % Converted, do we need to format the matrix?
            if count > 1
                rows = length(regexp(str, '.$|;', 'lineanchors'));
                % Does the number of rows divide evenly into the number
                % of elements?  We check both rows and rows - 1 as the
                % user may or may not have put line feeds or ; to separate
                % the rows
                if rows
                    rowcount = 1;
                    if ~ rem(count, rows)
                        rowcount = rows;
                    end
                    if rowcount > 1 % format as matrix
                        cols = count / rowcount;
                        num = reshape(num, rowcount, cols)';                        
                    end
                end
            end
        else
            converted = false;
        end        
    end
    if converted 
        val=num;   % able to convert to a number, save
    end 
end

%% =======================================================================
%  === str2varName Function ==============================================
%  =======================================================================
function str = str2varName(str, KeepNS)
% convert a sting to a valid matlab variable name
if(KeepNS)
  str = regexprep(str,':','_COLON_', 'once', 'ignorecase');
else
  k = strfind(str,':');
  if (~isempty(k))
    str = str(k+1:end);
  end
end
str = regexprep(str,'-','_DASH_'  ,'once', 'ignorecase');
if (~isvarname(str)) && (~iskeyword(str))
  str = genvarname(str);
end

%% =======================================================================
%  === NodeName Function =================================================
%  =======================================================================
function [Name LeafNode] = NodeName(node, KeepNS)
% get node name and make sure it is a valid variable name in Matlab.
% also get node type:
%   LeafNode=0 - normal element node,
%   LeafNode=1 - text node
%   LeafNode=2 - supported non-text leaf node,
%   LeafNode=3 - supported processing instructions leaf node,
%   LeafNode=-1 - unsupported non-text leaf node
switch (node.getNodeType())
  case node.ELEMENT_NODE
    Name = char(node.getNodeName());% capture name of the node
    Name = str2varName(Name, KeepNS);     % if Name is not a good variable name - fix it
    LeafNode = 0;
  case node.TEXT_NODE
    Name = 'CONTENT';
    LeafNode = 1;
  case node.COMMENT_NODE
    Name = 'COMMENT';
    LeafNode = 2;
  case node.CDATA_SECTION_NODE
    Name = 'CDATA_SECTION';
    LeafNode = 2;
  case node.DOCUMENT_TYPE_NODE
    Name = 'DOCUMENT_TYPE';
    LeafNode = 2;
  case node.PROCESSING_INSTRUCTION_NODE
    Name = 'PROCESSING_INSTRUCTION';
    LeafNode = 3;
  otherwise
    NodeType = {'ELEMENT','ATTRIBUTE','TEXT','CDATA_SECTION', ...
      'ENTITY_REFERENCE', 'ENTITY', 'PROCESSING_INSTRUCTION', 'COMMENT',...
      'DOCUMENT', 'DOCUMENT_TYPE', 'DOCUMENT_FRAGMENT', 'NOTATION'};
    Name = char(node.getNodeName());% capture name of the node
    warning('xml_io_tools:read:unkNode', ...
      'Unknown node type encountered: %s_NODE (%s)', NodeType{node.getNodeType()}, Name);
    LeafNode = -1;
end


