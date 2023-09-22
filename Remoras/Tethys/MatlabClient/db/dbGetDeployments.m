function deployments = dbGetDeployments(queryEngine, varargin)
% deployments = dbGetDeployments(query_engine, OptArgs)
% Return information about deployments.
%
% OptArgs - Optional Arguments: 
% This is a set of keyword value pairs.  With the exception of the keyword
% 'return' which is rarely needed with dbGetDeployments as the default
% behavior is to return the entire deployment record, the keywords specify
% information used to filter/select deployments and the values are criteria
% related to the selection criteria.  
%
% Keywords
% A complete list of Deployments 
% arguments can be found by executing:
%     dbOpenSchemaDescription(query, 'Deployment')
% where query is a query handler created with dbInit.  This will show a
% list of paths indicating how information is organized for each group
% of deployments.  Example paths:
%     Deployment/Id
%     Deployment/Project
%     Deployment/DeploymentId
%     Deployment/Site
%     Deployment/UserID
%     Deployment/Description/Objectives
%     Deployment/Description/Abstract
%     Deployment/Description/Method
%     Deployment/Algorithm/Method
%     Deployment/Algorithm/Software
%     Deployment/Algorithm/Version
%     ...
% In general, one need only provide the rightmost portion of the path,
% except in cases where the name appears more than once.  An example of
% this is TimeStamp which is used in many contexts.  Two of these denote
% the deployment and recovery dates and times:
% Deployment/DeploymentDetails/TimeStamp
% Deployment/RecoveryDetails/TimeStamp
% In a limited number of cases, we will automatically resolve ambiguities
% when there is a commonly used choice, e.g. specifying Site will
% resolve in favor of Deployment/Site as opposed to
% Deployment/SiteAliases/Site
%
% It is possible to use regular expression search to match paths.
% The special character . matches any character, and when followed
% by a *, it matches the character any number of times.
%     /Deployment.*/Timestamp would match 
%     Deployment/DeploymentDetails/TimeStamp and not
%     Deployment/RecoveryDetails/TimeStamp.  
%     Note:  The leading / was needed in this case or we would have 
%        matched Deployment/RecoveryDetails/TimeStamp as well:
%        Deployment[RecoveryDetails]/TimeStamp
%
% To query attributes, use an @ in front of the attribute name, e.g.
%     Deployment/Data/Track/Points/Point/Bearing_DegN/@north
%
% Values
% Each selection criteria is followed by a value.  It may be a simple
% value such as a number of string:
%   "Deployment/Project", "SOCAL"
%   "Deployment/DeploymentId, 45
%
% Some paths are optional.  To only select documents where an optional path
% is present, use [] (or any value v where isempty(v) is true) as the
% value).  For example QualityAssurance records are optional and not
% all deployments will have them.  Here, we only look for deployments
% that have assessments of their quality:
%  "Deployment/QualityAssurance/Quality/Category", []
% It is possible to specify relative comparisons, a cell array can be 
% provided consisting of the value and the comparision operator:
%
%   'DeploymentId, {'>=', 35}      % Deployment 35, 36, 37, ...
%
% When more than one attribute is used, all criteria must be true
% (conjunction of attributes is supported, but not disjunction: and, not or)
%
% Example:  Retrieve all deployments north of 70 degrees
% dep = dbGetDeployments(q, 'DeploymentDetails/Latitude', {'>', 70})
%
% Note about "return":  Other dbGet... functions will add return values
% to the list of default items that are returned.  As this function's
% default is to return everything, it assumed that when return is used,
% only the specified return fields are desired.

assert(dbVerifyQueryHandler(queryEngine), ...
    "First argument must be a query handler");

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
default_returns = ["Deployment"];

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
    err = dbParseOptions(queryEngine, "Deployment", ...
        tmpmap, "deployments", varargin{var_indices});
end
     
map = containers.Map();
map('enclose') = 1;
map('namespaces') = 0;
map('enclose_join') = 'omit';
err = dbParseOptions(queryEngine, "Deployment", ...
    map, "deployments", varargin{:});
dbParseUnrecoverableErrorCheck(err);  % Make sure nothing ambiguous
if ~ isempty(err)
    % User might have Deployments selection criteria.
    err = dbParseOptions(queryEngine, "Calibration", map, ...
        "calibrations", err.unmatched{:});
    dbParseUnrecoverableErrorCheck(err);
    if ~ isempty(err)
        error(sprintf("Unable to parse the following paths\n%s", ...
            strjoin(err.unmatched(1:2:end), "\n")));
    end
end

json = jsonencode(map);
querygen_elapsed = querygen_timer.elapsed();

% Execute XQuery
query_timer = dbTimer();

xmlstr = queryEngine.QueryJSON(json, 0);
query_elapsed = query_timer.elapsed();
    
typemap={
    'idx','double';...
    'DeploymentId','double';...
    'Start','datetime';...
    'End','datetime';...
    'ChannelNumber','double';...
    'SensorNumber','double';...
    'TimeStamp', 'datetime';...
    'AudioTimeStamp', 'datetime';...
    'Latitude','double';...
    'Longitude','double';...
    'RecordingInterval_m','double';...
    'RecordingDuration_m','double';...
    'DepthInstrument_m','double';...
    'SampleRate_kHz', 'double';...
    'SampleBits', 'double'; ...
    'Number', 'double'; ...
    };

parse_timer = dbTimer();
matstruct = tinyxml2_tethys('parse', char(xmlstr), typemap);
if iscell(matstruct) && isempty(matstruct{1})
    deployments = [];  % nothing found
    return;
end
% Ideally, we would like to take matstruct.Deployment, but
% these structures may have different elements and cannot be concatenated.
deployments = matstruct;
% Remove the unused attribute field
if isfield(deployments, 'Deployment_attr')
    deployments = arrayfun(@(x) rmfield(x, 'Deployment_attr'), deployments);
end

parse_elapsed = parse_timer.elapsed();


if isstruct(deployments)
    % Find the deployment field
    
    % Convert any track data to arrays for easier processing
    for idx = 1:length(deployments)
        if isfield(deployments(idx), 'Data') && ...
                isfield(deployments(idx).Data, 'Track') && ...
                isfield(deployments(idx).Data.Track, 'Points') && ...
                isfield(deployments(idx).Data.Track.Points, 'Point')
            
            fields = fieldnames(deployments(idx).Data.Track.Points.Point(1));
            for fidx = 1:length(fields)
                f = fields{fidx};
                deployments(idx).Data.Track.Points.(f) =  ...
                    arrayfun(@(x) x.(f){1}, deployments(idx).Data.Track.Points.Point);
            end
        end
    end
end

if benchmark_p
    % Generate XQuery (set enclose=1, default)
    query = queryEngine.QueryJSON(json, 2, 1);
    dbWriteBench(bench_dir, query_elapsed, parse_elapsed, query, length(deployments));
end

1;
