function [timestamps, info] = dbGetDetections(queryEngine, varargin)
% [timestamps, info] = dbGetDetections(queryEngine, Optional Args)
% Retrieve detections meeting criteria from database.  
% 
% A series of optional arguments described below specifies which detections
% should be retrieved.
%
% The output consists of 1 to 3 items.
%
% timestamps - 1 or 2 columns of Matlab serial dates (see
%    datenum).  Each row of timestamps indicates the start time of the
%    call, encounter, or bin.  Note that binned intervals require users
%    to compute the start time and some people may choose to provide a time
%    during the bin.  When present, the second column denotes the end of
%    the call, encounter, or bin. For some queries, there may be some
%    detections with end times and some without.  In these cases, missing
%    end times are filled with NaN (use isnan(timestamps(:,2) to identify)
% info - structure variable.  It contains the following fields:
%   data - Matlab representation of the data returned by Tethys.
%       There is one entry in the data structure array 
%       for each set of detections.  For example, if Site information
%       was requested for the deployments: 
%           "return", "Deployment/Site"
%       any available site inforamation can be accessed as follows:
%           info.data(idx).Deployment.Site
%       where idx is an integer that is between [1, length(deployments)]
%
%   The remaining fields contain processed representations of the
%   information contained in data:
%
%   detection_table - All detections in a tabular format (table type) and
%       sorted by Start time.  Contains the detection times (like 
%       timestamps) with any additional information that was requested 
%       about the detections such as Call type or SpeciesId.  
%
%       Two additional columns allow accessing into the original data
%       DetGrp indicates which group of detections a detection
%       came from and serves as an index to deployments.  In addition,
%       it serves as an index into info.data.  info.data(idx) will 
%       identify the data associated with the idx'th group of detections
%       info.data(idx).  The column DetGrpOffset indicates a
%       specific detection within that group:
%          info.data(idx).Detections.Detection(offset_idx)
%       In most cases, there should be no need to access the info.data
%       field.
%   Id - The Detections/Id of each of the detections documents that
%       are contained in this set.
%   deployments - For each set of detections that met the user's criteria,
%       there will be an array of structures that can be used to identify
%       the deployments associated with the retrieved detections.
%       Each deployment will have either a DeploymentId that references
%       to a deployment, or an EnsembleName that tells us which grouping
%       of deployments were used.%
% Inputs:
% queryEngine must be a Tethys database query object, see dbDemo() for an
% example of how to create one.  
%
% Optional Args: 
% This is a set of keyword value pairs.  With the exception of the special
% keyword 'return', the keywords are names that describe detections.  A
% complete list of Detections arguments can be found by executing:
%     dbOpenSchemaDescription(query, 'Detections')
% where query is a query handler created with dbInit.  This will show a
% list of paths indicating how information is organized for each group
% of detections.  The first few paths are:
%     Detections/Id
%     Detections/UserID
%     Detections/Description/Objectives
%     Detections/Description/Abstract
%     Detections/Description/Method
%     Detections/Algorithm/Method
%     Detections/Algorithm/Software
%     Detections/Algorithm/Version
%     ...
% In general, one need only provide the rightmost portion of the path,
% e.g. Software as opposed to Detections/Aglorithm/Software.
%
% Some elements occur in multiple places such as Start.  The detections
% schema uses Start to denote multiple types of Start times:
% Deployments/Effort/Start - The starting time of systematic effort to
%   find acoustic signals.
% Detections/OnEffort/Start - The start time of a call, encounter, or
%   presence/absence bin that we were looking for in a systematic manner
% Detections/OffEffort/Start - The start time of a call, encounter, or
%   presence/absence bin that we found but were not looking for
%   systematically.
%
% It is possible to use regular expression search to match paths.
% The special character . matches any character, and when followed
% by a *, it matches the character any number of times.
%     OnEffort/.*/Start 
% would match Detections/OnEffort/Detection/Start.
%
% To query attributes, use an @ in front of the attribute name, e.g.
%     Effort/Kind/SpeciesId/@Group
%
% When there is ambiguity between OnEffort and OffEffort detection
% criteria, we automatically resolve in favor of the OnEffort detections.
% 
% Once all detection criteria have been matched, any unmatched criteria
% are checked again to see if they match deployment paths.  If so, we
% search for detections that meet both the detection and deployment
% critiera, which lets us restrict detections to geographic regions,
% recording depth, etc.
%
% The second item in each pair is the value that must be matched.  To limit
% detections to those produced by Risso's dolphins, we could do the
% following (assuming dbSpeciesFmt is set to use Latin species names in
% queries): 
%
% 'OnEffort/SpeciesId', 'Grampus griseus' 
%
% Note when someone adds OnEffort/SpeciesId, we automatically add a
% matching constraint for the effort
%
% It is possible to specify relative comparisons, a cell array can be 
% provided consisting of the value and the comparision operator:
%
%   'Deployment, {'>=', 35}      % Deployment 35, 36, 37, ...
%
% When more than one attribute is used, all criteria must be true
% (conjunction of attributes is supported, but not disjunction: and, not or)
%
% Examples:
% Retrieve Pacific white-sided dolphin detections on the SOCAL  project:
%
% det = dbGetDetections(q, "Project", "SOCAL", 'SpeciesId', 'Lagenorhynchus obliquidens');
%
% A similar example that returns information about Call type and location where
% the instrument was deployed
% [det, info] = dbGetDetections(q, "Project", "SOCAL", ...
%     'SpeciesId', 'Lagenorhynchus obliquidens', ...
%     'return', ["OnEffort/Detection/Call", "DeploymentDetails"]);
% info.data(m).Detections.Detection(n).Call contains the call type
%   of the n'th detection in the m'th detection effort.
% info.data(m).Deployment.DeploymentDetails contains information about
%   the deployment associated with the m'th set of detection effort (e.g.
%   lat/long, deployment time)

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
default_returns = [...
    "Detections/OnEffort/Detection/Start", ...
    "Detections/OnEffort/Detection/End", ...
    "Detections/DataSource"];
if nargout > 1
    default_returns(end+1) = "Detections/OnEffort/Detection/SpeciesId";
    default_returns(end+1) = "Detections/Id";
end

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
    err = dbParseOptions(queryEngine, "Detections", ...
        tmpmap, "detections", varargin{var_indices});
    
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

% Set up species TSN translation
species_map = JSONSpeciesFmt(queryEngine, "GetInput", "GetOutput");
if ~ isempty(species_map)
    map('species') = species_map;
    numeric_species = ~species_map.isKey('return');  % Note if we translate to strings
else
    numeric_species = true;
end

err = dbParseOptions(queryEngine, "Detections", ...
    map, "detections", varargin{:});
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
    
parse_timer = dbTimer();
if nargout > 1
    [timestamps,info] = dbXmlDetParse(xmlstr, numeric_species, map('return'));
else
    timestamps = dbXmlDetParse(xmlstr);
end

parse_elapsed = parse_timer.elapsed();

if benchmark_p
    % Generate XQuery (set enclose=1, default)
    query = queryEngine.QueryJSON(json, 2, 1);
    dbWriteBench(bench_dir, query_elapsed, parse_elapsed, query, size(timestamps,1));
end
