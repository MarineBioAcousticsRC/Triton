function night = dbYearly(query_eng, varargin)
% dbYearly(query_eng, Arguments)
% Produce a long-term plot containing all data for a given site
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

TickEveryNDays = NaN;
diel = [];
PlotDiel = true;

vidx=1;
remove = [];
while vidx < length(varargin)
    switch varargin{vidx}
        case 'TickSpacingDays'
            TickEveryNDays = varargin{vidx+1};
            remove(end+1:end+2) = [vidx;vidx+1];
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
            remove(end+1:end+2) = [vidx;vidx+1];
            vidx = vidx+2;
        otherwise
            vidx = vidx + 2;
    end
end
if ~ isempty(remove)
    varargin(remove) = [];
end

[effort, effort_info] = dbGetEffort(query_eng, varargin{:});
detections = dbGetDetections(query_eng, varargin{:});

if isempty(effort)
    warning('No effort for specified request');
    night = [];
    return
end

EffortSpan = [min(effort(:, 1)), max(effort(:, 2))];
days = EffortSpan(2) - EffortSpan(1);
if isnan(TickEveryNDays)
    % Split into N even pieces for ticks
    TickEveryNDays = floor(days / 15);
end
deploymentIds = [effort_info.deployments.DeploymentId];
sensor = dbGetDeployments(query_eng, 'Id', deploymentIds);
lats = cellfun(@(x) x.DeploymentDetails.Latitude{1}, {sensor.Deployment});
longs = cellfun(@(x) x.DeploymentDetails.Longitude{1}, {sensor.Deployment});
u_lats = mean(lats);
u_longs = mean(longs);

fprintf("Determining diel pattern at center of deployments " + ...
    "lat %.3f (±%.3f) long %.3f (±%.3f)\n", ...
    u_lats, std(lats), u_longs, std(u_longs));

if PlotDiel
    night = dbDiel(query_eng, u_lats, u_longs, EffortSpan(1), EffortSpan(2));
else
    night = [];
end

% Come up with a horrible figure name
if length(varargin) > 0
    name = strjoin(cellfun(@string, varargin), '-');
else
    name = 'All';
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
    
if any(strcmp(effort_info.kinds_table.Granularity, 'binned'))
    % At least one effort was binned, use the maximum bin size
    Resolution_m = max(effort_info.kinds_table.BinSize_m);
else
    Resolution_m = 1; % 1 min bins
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
