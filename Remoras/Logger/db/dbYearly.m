function night = dbYearly(query_eng, varargin)
% dbYearly(query_eng, Arguments)
% Produce a long-term plot containing all data for a given sight
% Arguments are keywords value pairs:
%
% Project, Site, Detector, Species, Call, Subtype
% Each of these allows selections of detections.  See dbGetDetections
% for details.
%
% 'Diel', true|false|night
% Add a diel plot with sunrise/sunset information.  Returns the time spans
% of darkness hours over the queried time period.  If called again for
% the same area, passing in the night time as the argument to Diel
% will result in a faster plot and avoid taxing the ephemeris server.
%
% 'TickSpacingDays, N 
% Default:  Ticks every 30 days

error(nargchk(1, inf, nargin));

% defaults
constraints = cell(0,1);
deployment = cell(0,1);
effortspec = cell(0,1);
TickEveryNDays = 30;
diel = [];
PlotDiel = true;

vidx=1;
while vidx < length(varargin)
    switch varargin{vidx}
        case {'Project', 'Site', 'Region', 'Deployment'}
            constraints(end+1:end+2) = varargin(vidx:vidx+1);
            effortspec(end+1:end+2) = varargin(vidx:vidx+1);
            deployment(end+1:end+2) = varargin(vidx:vidx+1);
            vidx = vidx + 2;
        case {'Method', 'Software', 'Version', ...
              'SpeciesID', 'Call', 'Subtype', 'Group'}
            constraints(end+1:end+2) = varargin(vidx:vidx+1);
            effortspec(end+1:end+2) = varargin(vidx:vidx+1);
            vidx = vidx + 2;
        case {'Granularity', 'BinSize_m'}
            effortspec(end+1:end+2) = varargin(vidx:vidx+1);    
            vidx = vidx + 2;
        case 'TickSpacingDays'
            TickEveryNDays = varargin{vidx+1};
            vidx = vidx+2;
        case 'Diel'
            if isscalar(varargin{vidx+1})
                PlotDiel = varargin{vidx+1};
            elseif isnumeric(varargin{vidx+1})
                    PlotDiel = true;
                    diel = varargin{vidx+1};
            else
                error('Bad Diel argument');
            end
            vidx = vidx+2;
        otherwise
            error('Unrecognized optional argument', char(varargin{vidx}));
    end
end
        

[effort, details] = dbGetEffort(query_eng, effortspec{:});
[detections, endP] = dbGetDetections(query_eng, constraints{:});

if isempty(effort)
    warning('No effort for specified request');
    night = [];
    return
end

EffortSpan = [min(effort(:, 1)), max(effort(:, 2))];
sensor = dbDeploymentInfo(query_eng, deployment(:));

latitude = sensor(1).DeploymentDetails.Latitude;
longitude = sensor(1).DeploymentDetails.Longitude;

fprintf('Using first deployment''s latitude:  %f and longitude %f\n', ...
    latitude, longitude);

if PlotDiel
    night = dbDiel(query_eng, latitude, longitude, EffortSpan(1), EffortSpan(2));
else
    night = [];
end

% Generate a 
if ~ isempty(constraints)
    % Create a name from the effort constraints
    name = sprintf('%s-', ...
        constraints{find(~cellfun(@iscell, constraints(2:2:end)))*2});
    name(end) = [];  % remove trailing -
else
    name = 'all';
end

figure('Name', name);

if ~ isempty(night)
    visPresence(night, 'Color', 'black', ...
        'LineStyle', 'none', 'Transparency', .15, ...
        'Resolution_m', 1/60, 'DateRange', EffortSpan);
end

% Plot any known events
[etimes, enames] = dbGetEvents(query_eng, ...
    'Start', EffortSpan(1), 'End', EffortSpan(2));
if ~isempty(etimes)
    % Format event names
    enames_fmt = cell(size(enames));
    for idx=1:numel(enames)
        enames_fmt{idx} = sprintf('%s %s %s', ...
            datestr(etimes(idx,1), 'mmm dd - '), ...
            datestr(etimes(idx,2), 'mmm dd: '), enames{idx});
    end
    
    eventH = visPresence(etimes, 'DateRange', EffortSpan, ...
        'DateTickInterval', TickEveryNDays, ...
        'Resolution_m', 60, 'Transparency', .2, 'Color', 'green', ...
        'LabeledData', enames_fmt);
end
    
if strcmp(details(1).Kind(1).Granularity, 'binned')
    Resolution_m = details(1).Kind(1).Granularity_attr.BinSize_m;
else
    Resolution_m = 1; % 1 m bins
end

h = visPresence(detections, 'Effort', effort, ...
    'DateTickInterval', TickEveryNDays, ...
    'LineStyle', 'none', 'Label', name, 'Resolution_m', Resolution_m);

% went back to using transparency for no effort to prevent 
% drawing attention to missing data.  
% As a consequence, didn't put the lack of effort in the legend
% as transparency does not show up.
set(gca, 'YGrid', 'off');
% legend(h(1), Species);

1;
