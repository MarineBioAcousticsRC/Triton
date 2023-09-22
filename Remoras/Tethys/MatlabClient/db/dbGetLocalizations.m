function localizations = dbGetLocalizations(queryEngine, varargin)
% localizations = dbGetLocalizations(queryEngine, Optional Args)
% Retrieve localizations meeting criteria from database.  
%
% Inputs:
% queryEngine must be a Tethys database query object, see dbDemo() for an
% example of how to create one.  
%
% Optional Args: 
% This is a set of keyword value pairs.  With the exception of the special
% keyword 'return', the keywords are names that describe detections.  A
% complete list of Detections arguments can be found by executing:
%     dbOpenSchemaDescription(queryEngine, 'Localize')
% where query is a query handler created with dbInit.  This will show a
% list of paths indicating how information is organized for each group
% of detections.  A few example paths with their descriptions (descriptions
% of other paths can be found in the schema description.
%
%   Localize/Id - Identification string that is unique to all documents of
%     this type 
%   Localize/Algorithm/Software - Name of software that implements the
%     algorithm or supports human analysts. This might be the name of a 
%     plug-in or extension module that is part of a larger program or
%     system.  
%   Localize/Algorithm/Version - Software version identifier
%   Localize/Description - Text based description of process.  When
%     examining the schema document, note that this argument is optional
%     and may not be present (min occurs column values of 0 indicate that
%     the data are optional).  Specifying selection values for optional
%     parameters excludes all documents where that value is not set.
%   Localize/Effort/LocalizationType - Type of localization effort: 
%     Bearing, Ranging, Point, Track 
%   Localize/Effort/CoordinateSystem/Type - How are positions represented?
%     WGS84: global positioning system lat/long, 
%     cartesian: m relative to a point, 
%     UTM: universal trans Mercatur map-projection, 
%     Bearing: Polar measurements of angle and possibly distance. 
%   
%
% To query for specific types of detections, use any combination of the
% keyword/value pairs below. Example:
%
%   'Localize/Algorithm/Software', "PAMGUARD"
%
%   would return documents where localizations were made by PAMGUARD.  
%
%   To specify relative comparisons, a cell array can be provided 
%   consisting of the value and the comparision operator:
%
%   'Localize/Localizations/Localization/WGS84/Longitude', {">=", 85} 
%   would retrieve point localizations recorded east of 85 degrees.
%   Note that Tethys always stores latitudes in degrees east [0, 360)
%
% When more than one attribute is used, all criteria must be true
% (conjunction of attributes is supported, but not disjunction: and, not or)
% 
% For example, a second constraint could be added to look for point 
% localizations between 85 and 100 degrees east:
%   "Localize/Localizations/Localization/WGS84/Longitude", {">=", 85} 
%   "Localize/Localizations/Localization/WGS84/Longitude", {"<=", 100}
%
% When paths are unambiguous, they may be abbreviated or you can specify
% search patterns (regular expressions). 
%
% Example:  Retrieve localization tracks
%   % Change server to appropriate host if not running locally
%   q = dbInit("Server", "localhost");
%   loc = dbGetLocalizations(q, "LocalizationType", "Track")
%  The raw data are in loc.data.  If the data are homogeneous (e.g.,
%   you are not retrieving positions and bearings at the same time)
%   then a loc.localizations will be present.  loc.localizations(i)
%   contains the same information as in loc.data(i).Localizations
%   but may be easier to use.

% Collecting benchmark statistics?
b_idx = find(strcmp(varargin(1:2:end), 'Benchmark'));
if ~ isempty(b_idx)
    bench_dir = varargin{(b_idx-1)*+2};
    varargin((b_idx-1)*2+[1 2]) = [];
    benchmark_p = true;
else
    bench_dir = [];
    benchmark_p = false;
end

querygen_timer = dbTimer();

% Values to be returned (complete paths)
default_returns = [ ...
    "Localize/Localizations/Localization"
    ];
r_idx = find(strcmp(varargin(1:2:end), 'return'));
if isempty(r_idx)
    % User did not specify a return statement, add one in
    varargin{end+1} = 'return';
    varargin{end+1} = default_returns;
else
    % if return is the i'th keyword, it is at varargin{2(i-1)+1}
    % and has an argument at varargin{2(i-1)+1+1} = varargin{2i}
    retvalues_idx = r_idx*2;
    retvals = varargin(retvalues_idx);
    % Return statements should all be strings/chars, convert to strings
    retvals = cellfun(@convertCharsToStrings, retvals, ...
        'UniformOutput', false);
    for idx = 1:length(retvals)
        varargin{retvalues_idx(idx)} = retvals{idx};
    end

    % Get full paths for any returns that user might have specified
    % and see if we need to add in the default ones.
    tmpmap = containers.Map();
    var_indices = [(r_idx-1)*2+1; r_idx*2];
    err = dbParseOptions(queryEngine, "Localize", ...
        tmpmap, "localizations", varargin{var_indices});
    
    existing_returns = tmpmap('return');
    add = strings(0,1);
    for d_idx = 1:length(default_returns)
        if ~any(strcmp(existing_returns, default_returns(d_idx)))
            add(end+1) = default_returns(d_idx);
        end
    end
    for add_idx = 1:length(add)
        varargin{end+1} = "return";
        varargin{end+1} = add(add_idx);
    end 
end
     
map = containers.Map();
map('enclose') = 1;  % Wrap elements around sets of loop values
map('namespaces') = 0;  % Strip namespaces from results

% Add exists function to ensure we only select localizations documents
% with localizations in them
exists_map = containers.Map();
exists_map("op") = "exists";
exists_map("operands") = "Localize/Localizations/Localization";
exists_map("optype") = "function";
map("select") = {exists_map};

% Set up species TSN translation
species_map = JSONSpeciesFmt(queryEngine, "GetInput", "GetOutput");
if ~ isempty(species_map)
    map('species') = species_map;
    numeric_species = ~species_map.isKey('return');  % Note if we translate to strings
else
    numeric_species = true;
end

err = dbParseOptions(queryEngine, "Localize", ...
    map, "localizations", varargin{:});
dbParseUnrecoverableErrorCheck(err);  % die if unrecoverable error
if ~ isempty(err)
    % User might have Deployments selection criteria.
    err = dbParseOptions(queryEngine, "Deployment", ...
        map, "deployments", err.unmatched{:});
    dbParseUnrecoverableErrorCheck(err);
    dbParseUnmatchedErrors(err);
end

json = jsonencode(map);
querygen_elapsed = querygen_timer.elapsed();

% Execute XQuery
query_timer = dbTimer();
xmlstr = queryEngine.QueryJSON(json, 0);
query_elapsed = query_timer.elapsed();

typemap = {
    'Start', 'datetime'
    'End', 'datetime'
    'Time','datetime'
    'Timestamps', 'datetime'
    'Longitudes', 'double'
    'Latitudes', 'double'
    'Elevations_m', 'double'
    'Depth_m', 'double'
    'Depths_m', 'double'
    'Longitude', 'double'
    'Latitude', 'double'
    'x_m', 'double'
    'y_m', 'double'
    'z_m', 'double'
    'HorizontalAngle', 'double'
    'VerticalAngle', 'double'
    'Index', 'double'
    'MinDepth_m', 'double'
    'MaxDepth_m', 'double'
    'MinElevation_m', 'double'
    'MaxElevation_m', 'double'
    };
if numeric_species
    typemap(end+1) = {'SpeciesID', 'double'};
end

result = tinyxml2_tethys('parse', char(xmlstr), typemap);

if iscell(result) && isempty(result{1})
    localizations = [];  % empty
else
    % Capture raw information
    localizations.data = [result.Record.Localize];
    % Processed
    if isfield(localizations.data, 'Localization')
        % Need to further process to make more usable
        try
            localizations.localization = [localizations.data.Localization];
        catch
            % data were not homogeneous
        end
    end
end

if benchmark_p
    % Generate XQuery (set enclose=1, default)
    query = queryEngine.QueryJSON(json, 2, 1);
    dbWriteBench(bench_dir, query_elapsed, parse_elapsed, query, size(timestamps,1));
end