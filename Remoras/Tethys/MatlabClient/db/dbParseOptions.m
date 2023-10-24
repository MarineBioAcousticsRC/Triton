function errors = dbParseOptions(q, root, map, role, varargin)
% errors = dbParseOptions(q, root, map, role, directives)
% Used to build up a hash table (containers.Map) representation of query
% directives that can easily be translated to JSON.  This function is not
% designed to be called directly by end users, but it is used by various
% database retrieval functions.  The documentation on how to specify which
% data are selected and what is returned is thus useful to end users
% even if they will never call this function directly.
%
% Inputs:
%   root - root element name, e.g. Detections, Deployment, Localize
%   map - A containers.Map instance that will be modified through
%         side effects based on the directives given.
%   role - What are we trying to do.  Used to provide strategies for
%         resolving ambiguous path directives.  Expected values:
%         "deployments"
%         "detection_effort"
%         "detections"
%         "localizations"
%   directives - Pairs of keywords and values
%         Most keywords are portions of valid paths to selection data
%         such as what species of animal we are looking for.  For example,
%         the path
%
%         Values are selection critiera.  For example, if we want to
%         select detections where individual calls were detected as opposed
%         to presence within a time interval, we could specify a keyword
%         of 'Granularity' and a value of 'call'.  Advanced options such
%         as including comparisons are discussed below.
%
%         The special directive 'return' which may be repeated, expects
%         an element path as its value and adds information that is to
%         be returned in the query.  Multiple paths may be specified
%         through a cell array of character data (e.g. {'a', 'b'}) 
%         or an array of strings (e.g. ["a", "b"], see Matlab documentation 
%         to understand the difference between char & string data).
%          
% Example:
% map = containers.Map();
% err = dbParseOptions(q, "Detections", map, ...
%    "Kind/SpeciesId", 'Grampus griseus', ...
%    'Id', 'SOCAL38M_hf_logs_demo', ...
%    'Algorithm/Method', 'Analyst detections', ...
%    'Granularity', 'encounter', ...
%    'return', ["OnEffort/Detection/Start", "OnEffort/Detection/End"])
%
% This adds information to the map that will enable us to send a JSON
% query to the Tethys server.
% 
% "Kind/SpeciesId" matches the element path: 
%   Detections/Effort/Kind/SpeciesId
%   Note that using just "SpeciesId" would be ambiguous:
%       Detections/Effort/Kind/SpeciesId
%       Detections/OnEffort/Detection/SpeciesId
%       Detections/OffEffort/Detection/SpeciesId
%   We specify that we are looking for Risso's dolphins, this is assuming
%   that dbSpeciesFmt has not been called to change the representation of
%   species to an alternative format from the default Latin species name.
% "Id" matches Detections/Id, the value indicates that we are looking
%   for a specific detection effort (this is rarely needed).
% 'Alogrithms/Method' matches 'Detections/Algorithm/Method'
%   Indicates what method was used to obtain the detections.  This is
%   frequently an important field to distinguish between multiple
%   sets of detection effort on the same data although additional fields
%   may be needed, such as in the case of the same detection algorithm
%   run with different parameters.
% 'Granularity' matches 'Detections/Effort/Kind/Granularity' and specifies
%   that only the start and end times of groups of detections (encounter)
%   have been recorded.  When detection effort granularity is binned,
%   the the bin duration in minutes (BinSize_m) is recorded as an
%   attribute.  To search for any attribute, write the attribute as the
%   last element of the path, e.g.:
%      '@BinSize_m', 'Granularity/@BinSize_m', ..., or 
%      'Detections/Effort/Kind/Granularity/@BinSize_m'
% 'return' - The list indicates what elements should be returned in the
%   query, here only the Start and End time of OnEffort detections is
%   returned.
%
% If there are errors, return value is astructure containing two fields:
%   unmatched:  A list of key/value directives that were not matched.
%      This list is suitable for calling dbParseOptions with a different
%      root element (e.g. used in dbGetDetections when we want to specify
%      deployment information in addition detection information.
%   ambiguous.  A structure containing subfields:
%      directives:  List of key/value directives that matched more than
%        one path in the schema.
%      candidates:  Cell array of candidates for the paths.  As directives
%         contains two entries (path and a selection criteria) for each
%         directive, the candidate list will be half the size. 
%         candidates{idx} contains a list containing all the matches
%           for directives{(idx-1)*2+1}.
% When isempty(errors) == true, there were no path issues.
% 
% Advanced options
%
% Comparisions other than equality:
% To make relative comparisions (>, <, !=) use a cell array as the value.
% The first element of the cell array should be the comparison operator
% and the second the value to which it is being compared.  For example,
% to retrieve deployment information about instruments that were deployed
% south of 50 degrees south, use:
%   'DeploymentDetails/Latitude', {'<', -50}
%
% Wildcard search:
% Use .* to match any set of characters.  For example, for the deployment 
% schema (root 'Deployment'), there can be different instances of Latitude. 
% Both deployment and recovery latitudes are present, and for moving
% instruments it is possible to include measurements along the instrument's
% motion path. Wildcard search uses Matlab's full regular expression
% capabilities and is not limited to .*.  
% From our comparison example above, we could rewrite:
%
%   'DeploymentDetails/Latitude', {'<', -50}
%   to 
%   'Deployment.*/Latitude', {'<', -50}

persistent elements

narginchk(3, Inf);

if isempty(elements)
    % First invocation, create hashtable cache for valid paths
    elements = containers.Map();
end

% Retrieve paths for specified root from cache or server
if elements.isKey(root)
    tbl = elements(root);
else
    % Try to load values for this collection
    urlbase = q.getURLString();
    url = sprintf('%s/Schema/%s', urlbase, root);
    try
        tbl = webread(url, 'format', 'CSV');
    catch e
        msg = [sprintf("Unable to read %s?format=CSV", url), 
            "Verify that the Tethys server is running and accessible"];
        error(sprintf(strjoin(msg, "\n")));
    end
    % Conver char to string
    tbl.path = string(tbl.path);
    tbl.type = string(tbl.type);
    elements(root) = tbl;
end

% Retrieve paths and types for this element
paths = tbl.path;
types = tbl.type;

% Verify that directives are in pairs
if rem(length(varargin), 2) == 1
    error(['Directives must consist of pairs of arguments. There are ', ...
        sprintf('%d directives', length(varargin))])
end
       
% initialize errors structure
errors = struct('unmatched', {}, 'not_selectable', []);
errors(1).ambiguous.directives = strings(0,1);
errors.ambiguous.candidates = {};

% Make sure map has select and return keys
% Matlab does not allow chained () indices, so we cannot
% just append to these arrays, we get, append, put...
if ~ isKey(map, 'select')
    map('select') = {};
end
if ~ isKey(map, 'return')
    map('return') = strings(0,1);
end

map('enclose') = 1;
map('namespaces') = 0;

% Heuristics for resolving ambiguous paths
switch role
    case "deployments"
        path_heuristics = ["Deployment/Site$"];
    case "detections_effort"
        path_heuristics = ["Detections/Effort.*"];
    case "detections"
        path_heuristics = ["Detections/(On)?Effort.*"];
    case "localizations"
end

for vidx = 1:2:length(varargin)
    directive_value =  cellfun(@convertCharsToStrings,  ...
        varargin(vidx:vidx+1), 'UniformOutput', false);
    directive = directive_value{1};
    value = directive_value{2};
    
    % Check for return keyword, ignoring case
    if strcmpi(directive, 'return')
        for pidx = 1:length(value)
            retval = value(pidx);
            [indices, any_path] = find_paths(tbl, retval);
            matches = paths(indices);
            if isempty(matches)
                errors.unmatched(end+1:end+2) = {"return", retval};
            elseif length(matches) == 1
                % Found something to return
                retvals = map('return');
                if isempty(any_path)
                    retvals(end+1) = matches;
                else
                    retvals(end+1) = any_path;
                end
                map('return') = retvals;
            else
                resolved_paths = resolve_ambiguous(matches, path_heuristics);
                if isempty(resolved_paths)
                    errors.ambiguous.directives(end+1:end+2) = directive_value;
                    errors.ambiguous.candidates{end+1} = matches;
                else
                    % Able to resolve, add to selection criteria
                    entries = map('return');
                    for ridx = 1:length(resolved_paths)
                        entries(end+1) = resolved_paths(ridx);
                    end
                    map('return') = entries;
                end
            end
        end
    else
        % Selection criterion
        % Note, we do not yet handle slection on schema extensions (##any)
        % Find where this path is a substring
        [indices, any_path] = find_paths(tbl, directive);
        if isempty(indices)
            errors.unmatched(end+1:end+2) = varargin(vidx:vidx+1);
        elseif length(indices) == 1
            % Found it, verify that we have a type
            if strlength(types(indices)) > 0
                if isempty(any_path)
                    selpath = paths(indices);
                else
                    selpath = any_path;
                end
                entry = parse_directive(selpath, value);
                entries = map('select');
                entries{end+1} = entry;
                map('select') = entries;
            else
                errors.not_selectable(end+1) = paths(indices);
            end
        else
            % Try to resolve ambiguous paths
            resolved_paths = resolve_ambiguous(paths(indices), path_heuristics);
            if isempty(resolved_paths)
                errors.ambiguous.directives(end+1:end+2) = directive_value;
                errors.ambiguous.candidates(end+1) = {paths(indices)};
            else
                % Able to resolve, add to selection criteria
                entries = map('select');
                for ridx = 1:length(resolved_paths)
                    entry = parse_directive(resolved_paths(ridx), value);
                    entries{end+1} = entry;
                end
                map('select') = entries;
            end
        end
    end
end

if strcmp(role, 'detections')
    % Add in an exists(Detections/OnEffort/Detection)
    % This forces us to loop over the OnEffort Detections, making sure
    % that they are enclosed in Detection elements even when no
    % criteria are specified
    entries = map('select');
    entries{end+1} = parse_directive('Detections/OnEffort/Detection');
    map('select') = entries;
end

if isempty(errors.unmatched) && isempty(errors.ambiguous.directives) && ...
        isempty(errors.not_selectable)
    errors = [];
end

function entry = parse_directive(path, value)
% entry = parse_directive(entry, value)
% Build a hash map specifying the selection opertion

if nargin == 1 || isempty(value)
    operator = 'exists';
    optype = 'function';
    operands  = {path};
else
    % We expect to be using an operator that takes 2 arguments,
    % although one of them may be a list.
    optype = 'binary';  
    
    N = length(value);
    if N > 1
        % User specified something like {'>', 2} or [3, 4, 5]
        % determine if the first item in list is an operator
        is_op = false;
        
        operator = value(1);
        if iscell(operator)
            operator = operator{1};
        end
        if ischar(operator)
            operator = string(operator);
        end
        if isstring(operator)
            if ~ any(isstrprop(operator, 'alphanum'))
                is_op = true;
            end
        end
        
        if is_op
            operands = {path, value(2:end)};
        else
            operator = "=";
            operands = {path, value};
        end
        
        if N > 2 && ~ strcmp(operator, "=")
            error('Non-equality operator, %s, for path:  "%s" contains > 2 entries', operator, path)
        end
    else
        % User just  provided a simple value
        operator = "=";
        operands = {path, value};
    end
end
entry = containers.Map();
entry('op') = operator;
entry('operands') = operands;
entry('optype') = optype;

function [indices, any_path] = find_paths(tbl, pattern)
% indices = find_paths(tbl, pattern)
% tbl - Table describing schema (path, ..., type, ...)
% See if pattern exists in paths via regexp search.
% We prepend / if pattern does not start with a regexp character
% Returns indices of paths in which pattern exists.
% In the special case of paths that are extensions to the schemata,
% we return the indices, but also the complete path in any_path
% which is otherwise empty

any_path = [];

% If the pattern does not start with a regular expression, try it
% first with a / preprended.  This will avoid confusion between elements
% that are substrings of one another (e.g. Id, DeploymentId)

% Anchor the pattern on the right side with a $
if ~ (pattern.startsWith(".") || pattern.startsWith("["))
    % User didn't specify a regexp, let's put a / in front of the
    % element name, it will help reduce ambiguity with elements that
    % contain other element names within in them.
    fallback = sprintf("^%s$", pattern);
    try_pattern = sprintf("/%s$", pattern);
else
    fallback = [];  % no fallback
    try_pattern = sprintf("%s$", pattern);  % No /
end

indices = find(cellfun(@(x) ~isempty(x), regexp(tbl.path, try_pattern)));
if isempty(indices) && ~isempty(fallback)
    % User might have specified a complete path
    indices = find(cellfun(@(x) ~isempty(x), regexp(tbl.path, fallback)));
end

if isempty(indices)
    % Try to handle any xs:any
    any_rows = find(strcmp(tbl.type, 'any'));
    any_paths = strrep(tbl.path(any_rows), '/any', '');
    indices = [];
    while isempty(indices) && ~ (isempty(try_pattern) || try_pattern == '/' || try_pattern == '\')
        [try_pattern, last] = fileparts(try_pattern);  % Strip off last name
        if isempty(try_pattern) || try_pattern == '/' || try_pattern == '\'
            continue
        end
        matches = find(cellfun(@(x) ~isempty(x), regexp(any_paths, try_pattern)));
        if ~ isempty(matches)
            indices = any_rows(matches);
            % Find the prefix string of the first match
            a_match = any_paths{matches(1)};  
            retain = strfind(a_match, try_pattern);
            prefix = a_match(1:retain-1);
            if pattern.startsWith("/")
                sep = "";
            else
                sep = "/";
            end
            any_path = prefix + sep + pattern;
        end
    end
end

function targets = resolve_ambiguous(paths, patterns)
% targets = resolve_ambiguous(paths, patterns)
% It is usually a problem when a selection or return crteria matches 
% multiple paths.  In special cases, we will prefer a specific path
% (or set of paths over others).  Returns a set of paths or empty
% if we are unable to resolve the paths.
%
% paths - A string array of paths that we were unable to resolve
%  to the user's input.  e.g. User specified "SpeciesId"
%  which matched three paths:
%    "Detections/Effort/Kind/SpeciesId"
%    "Detections/OnEffort/Detection/SpeciesId"
%    "Detections/OffEffort/Detection/SpeciesId"
% patterns - A string array of regular expression patterns.  We filter
%    the list by each of the patterns in order.  Once a pattern matches
%    one or more of the strings, we return those.  For example:
%    pattern "Detections/(On)?Effort.*" matches
%    "Detections/Effort/Kind/SpeciesId"
%    "Detections/OnEffort/Detection/SpeciesId"

targets = [];

for pidx = 1:length(patterns)
    % Check if an special case pattern matches the ambiguous paths
    present = cellfun(@(x) ~isempty(x), regexp(paths, patterns(pidx)));
    if any(present)
        targets = paths(present);
        break
    end
end





    
    
    