function fig_h = visDiel(queryEng, varargin)
% plots = visDiel(queryEng, arguments)
% Convenience function for querying detections and plotting them 
% in a diel plot.
%
% arguments takes any keyword/value pair set of arguments that can
% be passed to dbGetDetections, type "doc dbGetDetections" for details.
%
% In addition the following arguments may be used (defaults given in
% parentheses if appropriate):
% 'Lunar', true | (false) - plot lunar illumination
% 'Resolution_min', integer - bar plot size in minutes, per detection.
%   Only applicable to detections with granularity encounter or call,
%   detections with granularity binned are always plotted with the 
%   resolution of the bin size.
%   For granularity call and encounter, defaults to 5 min
% 'UTC', (true )| false - If false, determine the local nautical time
%    zone based on the center of the lat/longs associated with the data.


% Defaults
options = containers.Map();
options("Lunar") = false;
options("Resolution_min") = 5;
options("UTC") = true;

days_per_y = 365.25;  % days per year
min_per_h = 60;  % minutes per hour

% Process plotting keywords unrelated to data retrieval and remove
% them so that they will not appear in data retrieval queries
for kw = ["Lunar", "Resolution_min", "UTC"]
    idx = find(strcmp(kw, varargin));
    if ~ isempty(idx)
        options(kw) = varargin{idx+1};
    end
    varargin(idx:idx+1) = [];
end

% Retrieve effort and detections
[~, effort] = dbGetEffort(queryEng, varargin{:}, ...
    'return', ["DeploymentDetails/Latitude", "DeploymentDetails/Longitude"]);
[~, detections] = dbGetDetections(queryEng, varargin{:}, 'return', 'Call');

% Put the longitudes and latitudes into a table
latlongs = [effort.data.Deployment];
latlongs = table(...
    cell2mat([latlongs.Latitude])', cell2mat([latlongs.Longitude])', ...
    'VariableNames', {'Latitude', 'Longitude'});

% Stratify the effort
group_indices = findgroups(effort.kinds_table.SpeciesId, ...
    effort.kinds_table.Call, effort.kinds_table.Granularity);
groups = unique(group_indices)';

fig_h = zeros(size(groups));  % preallocate vector for figure handles
for g_idx = groups
    % Pull out effort associated with group and identify the detection
    % document Ids
    subkinds = effort.kinds_table(find(group_indices == g_idx),:);
    subeff = effort.effort_table(ismember(effort.effort_table.RecordIdx, ...
        unique(subkinds.RecordIdx)), :);
    sublatlongs = latlongs(subeff.RecordIdx, :);
    % Get mean longitude/latitude across deployments associated with this
    % group
    latlong_u = mean(sublatlongs{:,:}, 1);
    latlong_std = std(sublatlongs{:,:}, 0, 1);
    
    if options("UTC")
        UTCOffset = 0;
    else
        UTCOffset = dbTimeZone(queryEng, latlong_u(1), latlong_u(2));
    end
    
    effids = effort.Id(subkinds.RecordIdx);
    % Find out which detection groups are associated with this strata
    % and retrieve them.
    % In principal, effids and detids should be the same, but we can
    % run into problems if the database changes between the effort and
    % detection query.  If it does, we will ignore the extra detections
    matches = regexp(detections.Id, '(' + strjoin(effids, "|") + ')');
    if ~iscell(matches)
        matches = {matches};   % Handle single detections.Id case
    end
    detids = find(cellfun(@(x) ~ isempty(x), matches));

    call_type = unique(subkinds.Call);
    subdet = detections.detection_table(...
        ismember(detections.detection_table.DetGrp, detids) & ...
        strcmp(detections.detection_table.Call, call_type), :);
    
    granularity = subkinds{1, 'Granularity'}{1};
    fig_name = string({subkinds{1,'SpeciesId'}, subkinds{1, 'Call'}, granularity});
    resolution_min = options("Resolution_min");
    switch granularity        
        case 'binned'
            BinSize_min = unique(subkinds.BinSize_m);
            assert(length(BinSize_min) == 1, "Cannot mix detections of different BinSize_m, refine query");
            % Round to nearest bin size
            starts = subdet.Start;
            minutes = BinSize_min * floor((starts.Hour*60 + starts.Minute) / BinSize_min);
            hh = floor(minutes / min_per_h);
            mm = rem(minutes, min_per_h);
            starts.Hour = hh;
            starts.Minute = mm;
            starts.Second = 0;
            ends = starts + duration(0,BinSize_min,0);
            resolution_min = BinSize_min;
            fig_name(end+1) = sprintf("@ %d min )", resolution_min);
        case 'encounter'
            starts = subdet.Start;
            ends = subdet.End;
            
        case 'call'
            starts = subdet.Start;
            dur = duration(0, BinSize_min, 0);  % min call duration
            if ismember('End', subdet.Properties.VariableNames)
                ends = min([starts+dur, subdet.End], [], 2);
            else
                ends = starts+dur;
            end
    end
    
    EffortSpan = [min(subeff.Start), max(subeff.End)];
    EffortDuration = diff(EffortSpan);
    EffortDays = days(EffortDuration);
   
    % Determine how often date ticks will appear on ther vertical axis
    if EffortDays > 4*days_per_y
        tick_days = 90;  % Tick marks every few months
    elseif EffortDays > days_per_y
        tick_days = 'month';
    elseif EffortDays > days_per_y / 2
        tick_days = 14;  % Tick marks every couple of weeks
    else
        tick_days = 7;  % Tick marks every week
    end
        
    fig_name(end+1) = sprintf("lat %.3f˚±%.3fσ / long %.3f˚±%.3fσ", ...
        latlong_u(1), latlong_std(1), latlong_u(2), latlong_std(2));
    fig_h(g_idx) = figure('Name', strjoin(fig_name, " "));
    visPresence([starts, ends], 'Resolution_min', resolution_min, ...
        'Effort', [subeff.Start, subeff.End], ...
        'UTCOffset', UTCOffset, 'DateTickInterval', tick_days);
    
    % Retrieve and plot night
    night = dbDiel(queryEng, latlong_u(1), latlong_u(2), ...
        min(subeff.Start), max(subeff.End));
    visPresence(night, 'Color', 'black', ...
        'LineStyle', 'none', 'Transparency', .15, ...
        'Resolution_m', 1/60, 'DateRange', EffortSpan, ...
        'UTCOffset', UTCOffset, 'DateTickInterval', tick_days);
    % Plot detections
    1;
    
    if options('Lunar')
        illu = dbGetLunarIllumination(queryEng, ...
            latlong_u(1), latlong_u(2), EffortSpan(1), EffortSpan(2), 30);
        visLunarIllumination(illu, 'UTCOffset', UTCOffset);
    end
end