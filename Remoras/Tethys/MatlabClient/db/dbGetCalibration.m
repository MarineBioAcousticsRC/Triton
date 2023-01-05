function calbiration = dbGetCalibration(queryH, Id, varargin)
% calbiration = dbGetTransferFn(queryH, Id, OptionalArgs)
% Retrieve inverse sensitivity function for a given 
% preamp/hydrophone assemblage.  By default, all calibrations are
%
% Optional args:
%   'LastBefore', datetime - Find last before timestamp
%   'FirstAfter', datetime - Find first calibration after timestamp
%   All other criteria are selection criteria keyword, value pairs.
%   See dbGetDetections, dbGetEffort, dbGetDeployments, etc. for examples
%      of how criteria are set along with 
%      dbOpenSchemaDescription(queryH, 'Calibration')
%      to see the schema description.
% 
% NOTE:  datetime may be:
%   ISO8601 datetime string restricted to:  YYYY-MM-DDTHH:MM:SSZ
%   Matlab datetime object
%   Matlab serial date
%
% See also: datetime, datenum, dbGetDetections, 

vidx = 1;
if isnumeric(Id)
    Id = num2str(Id);
end
where = sprintf('where $cal/Id = %s', char(Id));

% default - pick first one
multiple = 'first';

while vidx < length(varargin)
    switch varargin{vidx}
        case {'LastBefore', 'FirstAfter'};
            multiple = varargin{vidx};
            timestamp = varargin{vidx+1};
            varargin(vidx:vidx+1) = [];  % Remove from vararg list
        otherwise
            % Skip other pairs
            vidx = vidx + 2;
        
    end
end

% Add in Id = Id criteria
varargin{end+1} = 'Id';
varargin{end+1} = Id;

r_idx = find(strcmp(varargin(1:2:end), 'return'));
if isempty(r_idx)
    % User did not specify a return statement, add one in
    varargin{end+1} = 'return';
    varargin{end+1} = 'Calibration';
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
    err = dbParseOptions(queryEngine, "Calibration", ...
        tmpmap, "calibrations", varargin{var_indices});
    
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

% Parse user arguments
map = containers.Map();
err = dbParseOptions(queryH, "Calibration", ...
    map, "Calibrations", varargin{:});
dbParseUnrecoverableErrorCheck(err);  % die if unrecoverable error
 

queryStr = dbGetCannedQuery('GetCalibrations.xq');
query = sprintf(queryStr, where);

% Temporary workaround as there is inconsistency between preamplifier
% ids in harp and calibration database.  Some have leading H, others
% do not.
retry = true;
retrycount = 0;
while retry
    % Get the document object model representation
    dom = queryH.QueryReturnDoc(query);

    if isempty(dom)
        xml = [];
    else
        pref.KeepNS = false;
        xml = xml_read(dom, pref); % Convert to XML
    end
    
    if isempty(xml)
        % May have been a null document
        if retry && retrycount < 1
            % Reformat query, add or strip H.
            if Id(1) == 'H'
                query = strrep(query, Id, Id(2:end));
            else
                query = strrep(query, ['H', Id], Id);
            end
            retrycount = retrycount + 1;
        else
            retry = false;            
        end
    else
        retry = false;
    end
end
if isempty(xml)
    error('Unable to retreive calibration %s', Id);
end
if retrycount > 0
    fprintf('Temporary code: Renamed preamplifier id\n');
end

if firstlast
    if first
        idx = 1;
    else
        idx = length(xml.TransferFunction);
    end
    
    typemap = dbGetSchemaTypes(queryH, 'Calibration');
    calibration = tinyxml2_tethys('parse',xml, typemap);
    %tf = [xml.Calibration(idx).FrequencyResponse.Hz(:), xml.Calibration(idx).FrequencyResponse.dB(:)];
    %date = dbISO8601toSerialDate(xml.Calibration(idx).TimeStamp);
    1;
else
    error('More than one calibration selected')
end
    
