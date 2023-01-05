function [timestamps, info] = dbXmlDetParse(xml, numeric_species, returnvals)
% [timestamps, info] = dbXmlDetParse(xml, species_type)
% parse an xml document retrieved via dbGetDetections.
% tsnP is true if SpeciesID is numeric

if xml.length() == 0
    % Nothing retrieved
    timestamps = zeros(0,2);
    if nargout > 1
        info = [];
    end
    return
end

xml_result = char(xml);  % Java string to Matlab char array

% A map of types to send to the wrapper, in Key/Value pairs
% Each key represents an element name, and the value reps their return type.
typemap={
    'idx','double';...
    'DeploymentId','double';...
    'Start','datetime';...
    'End','datetime';...
    'BinSize_m','double';...
    'Longitude','double';...
    'Latitude','double';...
    'TimeStamp','datetime';...
    'AudioTimeStamp','datetime';...
    'DepthInstroument_m', 'double'; ...
    'dbReferenceIntensity_uPa', 'double'; ...
    'Channel', 'double'; ...
    'UnitID', 'double'; ...
    'Count', 'double'; ...
    'Score', 'double'; ...
    'Confidence', 'double'; ...
    'ReceivedLevel_dB', 'double'; ...
    'FrequencyMeasurements_dB', 'double'; ...
    'FrequencyMeasurements_Hz', 'double'; ...
    'SNR_dB', 'double'; ...
    'MinFreq_Hz', 'double'; ...
    'MaxFreq_Hz', 'double'; ...
    'PeakFreq_Hz', 'double'; ...
    'Peaks_Hz', 'double'; ...
    'Duration_s', 'double'; ...
    'Sideband_Hz', 'double'; ...
    'Offset_s', 'double'; ...
    'Hz', 'double'; ...
    'dB', 'double'
    };
if nargin > 1 && numeric_species
    typemap(end+1,:) = {'SpeciesID', 'double'};
end

result=tinyxml2_tethys('parse',xml_result,typemap);

timestamps = [];
info = [];

if iscell(result) && isempty(result{1})
    return;  % no results
end

if isstruct(result.Return)
    % Remove any returned documents without detections
    no_detections = arrayfun(@(x) ~ isfield(x.Detections, 'Detection'), result.Return);
    result.Return(no_detections) = [];
    
    % Assemble the Detections into an easier to use structure
    detections = dbMergeStructures(result.Return, 'Detections');

    det_per_group = arrayfun(@(x) length(x.Detection), detections);
    detN = sum(det_per_group);  % total
    
    % preallocate table, we will fill in start times
    tabular = table('Size', [detN,0]);

    if nargout > 1
        % deployments will contain information about the deployments 
        % the detections were associated with (DeploymentId or
        % EnsembleName).  
        info.deployments=[detections.DataSource];
        
        % deploymentIdx tells us which deployment each
        % detection is associated with:
        % info.deployments(info.deploymentIdx(5)) tells us the identifier
        % for the fifth detection.
        dep_idx = zeros(detN, 1);
        dep_offset = zeros(detN, 1);
        cum = cumsum(det_per_group);
        start = 1;
        for idx = 1:length(cum)
            dep_idx(start:cum(idx)) = idx;
            dep_offset(start:cum(idx)) = 1:det_per_group(idx);
            start = start + det_per_group(idx);
        end
        tabular.DetGrp = dep_idx;
        tabular.DetGrpOffset = dep_offset;
        
        % Process other fields
        
        % Find names related to detections
        m = regexp(returnvals, "/Detection/(?<path>.*)", 'names');
        det_returns = [m{~cellfun(@isempty, m)}];
        det_returns = [det_returns.path];
        
        warned = false;
        for idx = 1:length(det_returns)
            if det_returns(idx).contains("/") && ~warned
                warning("Nested parameters are not added to detection table but are available in the data field");
                warned = true;
            end
            tabular = fill_table(tabular, detections, det_returns(idx), det_per_group);
        end
        
    else
        % Fill in Start and any possible Ends
        for f = ["Start", "End"]
            tabular = fill_table(tabular, detections, f, det_per_group);
        end
    end

    % Sort data table if needed
    if ~ issorted(tabular.Start)
        [~, perm] = sort(tabular.Start);
        tabular = tabular(perm, :);
    end
    
    % populate timestamps
    if ismember('End', tabular.Properties.VariableNames)
        timestamps = table2array(tabular(:, ["Start", "End"]));
    else
        timestamps = tabular.Start;
    end
    
    if nargout > 1
        % Return data from XML after processing to Matlab struct
        % contains everything
        info.data = result.Return;
        % Retain table with datetimes instead of serial dates
        tabular.Start = datetime(tabular.Start, 'ConvertFrom', 'datenum');
        if ismember('End', tabular.Properties.VariableNames)
            tabular.End = datetime(tabular.End, 'ConvertFrom', 'datenum');
        end
        
        % Fill in some other fields
        det = detections.Detection;
        fields = fieldnames(det);
        for fidx = 1:length(fields)
            if sum(contains(fields{fidx}, ["Start", "End"])) == 0
                tabular = fill_table(tabular, detections, ...
                    fields{fidx}, det_per_group);
            end
        end
        info.detection_table = tabular;
        
        % Preserve the Id associated with each detection group
        info.Id = string(arrayfun(@(x) x.Detections.Id, info.data));
    end
end

function tabular = fill_table(tabular, detections, field, det_per_group)
% fill_table(tabular, field, detections, det_per_group)
% tabular - table to fill
% detections - detections array, N groups where each group
%    detections(i).Detection(j) represents the j'th detection
%    in the i'th detection group.  
% field - field to populate in tabular.  We do not assume that the
%    field is populated for all detections.
% det_per_group - Count of Detections in each detections(i).Detection

% determine which detection groups have this field
presence = arrayfun(@(x) isfield(x.Detection, field), detections);
if any(presence)
    start = 1;
    first = true; % allows us to preallocate when we find something
    for idx  = 1:length(det_per_group)
        if presence(idx)
            % At least one item in group
            % map this group onto indices for all detections
            out_rng = start:start+det_per_group(idx) - 1;

            % Get field values
            values = [detections(idx).Detection.(field)]';
            % May need to massage the format to make it easier to use
            if iscell(values) 
                if ischar(values{1})
                    % convert cell arrays of chars to strings
                    values = string(values);
                elseif max(cellfun(@length, values)) <= 1
                    % cell arrays of singleton values to matrices
                    values = cell2mat(values);
                end
            end
            
            if first
                % This column does not exist.  Now that we know the
                % data type, pre-allocate the column in our table.
                if iscell(values)
                    tabular.(field) = cell(height(tabular), 1);
                elseif isstring(values)
                    tabular.(field) = strings(height(tabular), 1);
                elseif isnumeric(values)
                    tabular.(field) = nan(height(tabular), 1);
                else
                    error('Encountered a data type that is not yet implmented')
                end
                first = false;
            end
            
            if length(values) ~= det_per_group(idx)
                % Some values were missing, only copy those present
                present = find(arrayfun(@(x) ~isempty(x.(field)), ...
                    detections(idx).Detection));
                if ~isempty(present)
                    tabular.(field)(start+present-1) = values;
                end
            else
                % hey, hey, the gang's all here... (easy case)
                tabular.(field)(out_rng) = values;
            end
        end
        start = start + det_per_group(idx);
    end
end