function [timestamps, info] = dbGetEffort(queryEngine, varargin)
% [Timestamps, Data] = dbGetEffort(queryEngine, Arguments)
% Retrieve effort information from Tethys detection effort records.
% Timestamps is a matrix of Matlab serial dates containing the start and
% end times of effort in each row.  Info is a structure 
% that describes the effort.  Info.Detections contains
% information relating to each row of timestamps matrix (e.g. Kind 
% indicates lists of species the effort corresponded to and the granularity
% of the detection effort).
%
% queryEng must be a Tethys database query object, see dbDemo() for an
% example of how to create one.
%
% Arguments are used to specify selection criteria for the effort as well
% as to return additional information such as deployment locations, sample
% rate, etc.  These are processed in the same manner as dbGetDetections.
%
% Returns:
%   timestamps - Rows of Matlab serial dates for start and end effort
%   
%   info - if specified, returns a structure with fields
%     > deployments - stucture array noting the EnsembleId or DeploymentId
%        (separate fields) to which the effort corresponds.
%     > data - structure representing the data returned from the database
%     > effort_table - Matlab table of effort datetimes with start and end
%        as datetimes (easier to read/manipulate), and a RecordIndex.
%        The RecordIndex can be used to index the data and deployments
%        fields
%   
% See also:  dbGetDetections

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
if nargout > 1
    default_returns = [...
        "Detections/Id", ...
        "Detections/Effort/Start", ...
        "Detections/Effort/End", ...
        "Detections/DataSource", ...
        "Detections/Effort/Kind"];
else
    default_returns = [
        "Detections/Id", ...
        "Detections/Effort/Start", ...
        "Detections/Effort/End"];
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
        tmpmap, "detections_effort", varargin{var_indices});
    
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

% Determine formats for species names in input/output
species_map = JSONSpeciesFmt(queryEngine, 'GetInput', 'GetOutput');
if ~ isempty(species_map)
    map("species") = species_map;
    tsnP = species_map.isKey('return');  % Note if we translate to strings
end
% Parse user arguments
err = dbParseOptions(queryEngine, "Detections", ...
    map, "detections_effort", varargin{:});
dbParseUnrecoverableErrorCheck(err);  % die if unrecoverable error
if ~ isempty(err)
    % User might have Deployments selection criteria.
    err = dbParseOptions(queryEngine, "Deployment", map, ...
        "deployments", err.unmatched{:});
    dbParseUnrecoverableErrorCheck(err);
    dbParseUnmatchedErrors(err);
end

json = jsonencode(map);
querygen_elapsed = querygen_timer.elapsed();

% Execute XQuery
query_timer = dbTimer();
xml_result = queryEngine.QueryJSON(json, 0);
query_elapsed = query_timer.elapsed();
    
parse_timer = dbTimer();

typemap={
    'idx','double';...
    'Deployment','double';...
    'Start','datetime';...
    'End','datetime';...
    'Score','double';...
    'BinSize_m','double';
    'Longitude', 'double';
    'Latitude', 'double';
    'Timestamp', 'datetime';
    'AudioTimestamp', 'datetime';
    'FrequencyMeasurements_Hz', 'double';
    };
if ~ tsnP
    typemap(end+1,:) = {'SpeciesId','double'};
end


xml_result = char(xml_result);
result=tinyxml2_tethys('parse',xml_result,typemap);

if iscell(result) && isempty(result{1})
    timestamps = zeros(0,2);  % empty
    info = [];
else
    % Start/End under Return.Detections as Effort cannot appear more than once
    efforts = dbMergeStructures(result.Return, 'Detections');
    %timestamps = cell2mat([[efforts.Start]', [efforts.End]']);
    tabular = table(...
        cell2mat([efforts.Start]'), cell2mat([efforts.End]'), ...
        [efforts.Id]', [1:length(efforts)]', ...
        'VariableNames', {'Start', 'End', 'Id', 'RecordIdx'});

    % Sort data table if needed
    if ~ issorted(tabular.Start)
        [~, perm] = sort(tabular.Start);
        tabular = tabular(perm, :);
    end
    
    timestamps = [tabular.Start, tabular.End];
    
    % Reorder information associated with detections to be in same order
    if nargout > 1
        % deployments will contain information about the deployments
        % the detections were associated with (DeploymentId or
        % EnsembleName).  deploymentIdx tells us which deployment each
        % detection is associated with:
        % info.deployments(info.deploymentIdx(5)) tells us the identifier
        % for the fifth detection.
        detections = [result.Return.Detections];
        % Convert start/end to datetime
        tabular.Start = datetime(tabular.Start, 'ConvertFrom', 'datenum');
        tabular.End = datetime(tabular.End, 'ConvertFrom', 'datenum');
        info.effort_table = tabular;
        info.deployments=[detections.DataSource];
        info.Id = string(arrayfun(@(x) x.Detections.Id, result.Return));
        info.data = result.Return;
        
        % Build a table showing effort for each kind
        % This code is a bit ugly as Matlab does not handle heterogeneous
        % substructures very well.
        
        % Populate the mandatory kind fields first, this will allow us 
        % to preallocation the optional ones
        species = arrayfun(@(x) [x.Kind.SpeciesId], detections, 'UniformOutput', false);
        species = horzcat(species{:})';
        granularity = arrayfun(@(x) [x.Kind.Granularity], detections, 'UniformOutput', false);
        granularity = horzcat(granularity{:})';
        
        % Add the RecordIdx and handle optional types
        % todo: make this data driven from schema
        binsize_m = nan(length(granularity), 1);
        subtypes = cell(length(granularity), 1);
        calls = cell(length(granularity), 1);
        record_idx = zeros(length(granularity), 1);
        group = cell(length(granularity), 1);
        freq_Hz = cell(length(granularity), 1);
        count = 1;
        for idx = 1:length(detections)
            for k=1:length(detections(idx).Kind)
                record_idx(count) = idx;  % track the effort group
                if isfield(detections(idx).Kind(k), 'Call')
                    calls{count} = detections(idx).Kind(k).Call{1};
                end
                if isfield(detections(idx).Kind(k), 'Parameters')
                    if isfield(detections(idx).Kind(k).Parameters, 'Subtype')
                        subtypes{count} = detections(idx).Kind(k).Parameters.Subtype{1};
                    end
                    if isfield(detections(idx).Kind(k).Parameters, 'FrequencyMeasurements_Hz')
                        freq_Hz{count} = detections(idx).Kind(k).Parameters.FrequencyMeasurements_Hz{1};
                    end
                end
                if isfield(detections(idx).Kind(k), 'SpeciesId_attr') && ...
                        isfield(detections(idx).Kind(k).SpeciesId_attr, 'Group')
                    group{count} = detections(idx).Kind(k).SpeciesId_attr.Group{1};
                end
                if strcmp(detections(idx).Kind(k).Granularity, 'binned')
                    binsize_m(count) = detections(idx).Kind(k).Granularity_attr.BinSize_m;
                end
                count = count + 1;
            end
        end
        
        % Build a table
        info.kinds_table = table(...
            record_idx, species, group, calls, ...
            granularity, binsize_m, ...
            'VariableNames', ...
               {'RecordIdx', 'SpeciesId', 'Group', ...
                'Call', 'Granularity', 'BinSize_m'});
        % Add in things we only want if they are present.
        if ~ all(cellfun(@isempty, subtypes))
            info.kinds_table.Subtype = subtypes;
        end
        if ~ all(cellfun(@isempty, freq_Hz))
            info.kinds_table.FrequencyMeasurements_Hz = freq_Hz;
        end

            
    end
    parse_elapsed = parse_timer.elapsed();
end

if benchmark_p
    % Generate XQuery (set enclose=1, default)
    query = queryEngine.QueryJSON(json, 2, 1);
    dbWriteBench(bench_dir, query_elapsed, parse_elapsed, query, size(timestamps,1));
end

