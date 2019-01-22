function [BarH, presence_d, presence_dayfrac] = visPresence(presence, varargin)
% [BarH, presence_d, presence_dayfrace] = visPresence(presence, Optional args...)
% Show presence/absence plot
% Display presence/absence in resolution_m increments
% Presence is a one or two column matrix giving starting (and
% possibly ending times) as Matlab serial dates.  If end time
% is unavailable, only the resolution_m segment containing the
% start time will be selected. Dates are assumed to be UTC and sorted.
%
% BarH is a column vector where the first entry is a handle group
% containing the presence patches.  The second entry is a handle group
% for areas of no effort.  When no patches are plotted, the BarH entry is
% 0.  Handle groups are Matlab's way of treating groups of graphics objects
% (handle objects) as a unit.  Returning these groups allows the user
% to modify the presence/effort rectangles that have been plotted, changing
% color, outline, etc.  If you do not plan on modifying/removing the
% presence plots, you do not need to retain the variable.
%
% presence_d and presence_dayfrac are the presence matrix translated into days
% and fractions of days.
%
% Optional input arguments:
%  'UTCOffset', N - Convert to local time using an offset of N (default 0)
%  'Color' - Specify color as a string (e.g. 'g' or 'green') or as
%      a red, green, blue triplet.  Avoid using light colors as they
%      will be lightened to show areas without effort.  Default 'blue'.
%  'NoEffortColor' - Color for no effort, similar to color.  Defaults
%      to a transparent version of color which will not work well in
%      a legend.
%  'DateRange', [StartSerialDate, StopSerialDate] - Specify the range
%      over which the plot is to span.  If not given, the plot will span
%      from the earliest effort (or detection if effort not given) to
%      the latest effort (or last detection).
%  'DateTickInterval', N - Plot dates and ticks every N days (default 7)
%  'HourTickInterval', N - Plot hour ticks every N hours (default 3)
%  'Effort', SerialDateMatrix - Indicates where effort to detect was
%      made.  Regions of the plot where there was no effort will be
%      displayed with a lighter version of the plot color.
%
%  'Label', String - Uniform label for detections.  Label is displayed
%      when user clicks on a detection bar.  This is useful when
%      visPresence is called multiple times and each invocation is for a
%      different type of data.
%  'LabeledData', CellArray - Individual labels for region.  Labels
%      are displayed over the region and are only really useful for large
%      patches relative to the overall plot size (e.g. multiday event in
%      monthly plot, multiweek in yearly plot)
%
%  'ShowLabels', true|false - Display label in detection box
%  'Resolution_m', M - Plot resolution (bin size) in minutes (default 60)
%  'Title', String - Plot title
%  'BarHeight', N - Height relative to day row [0, 1] (default 1)
%  'BarOffset', N - Vertical offset into day [0, 1-BarHeight]]
%                     (default  0)
%  'LineStyle', String - Line style, i.e. '-', 'none' (default 'none')
%  'Transparency', N - [0=transparent, 1=opaque] alpha transparency value
%                      (default 1)
%  Unsupported:  'XLength_d', M - Length of X axis in days (default 1)

% defaults
Effort = [];  % Use passed in dates
DateRange = [];
Resolution_m = 5;
ResolutionNoEffort_m = 1/60;
Title = [];
DateTickInterval = 7;  % one week between date ticks and labels
HourTickInterval = 3;  % N hours between hour ticks
BarHeight = 1;
BarOffset = 0;
Color = 'b';
BarH = zeros(2,1);
debug = false;
LineStyle = 'none';
Transparency = 1;
UTCOffset = 0;
XLength_d = 1;
Label = [];
LabeledData = {};
NoEffortColor = [];

if ~isempty(presence)
    if ~ issorted(presence(:,1))
        error('Dates not sorted');
    end
end

vidx = 1;
while vidx < length(varargin)
    switch varargin{vidx}
        case 'UTCOffset'
            UTCOffset = varargin{vidx+1}; vidx=vidx+2;
            if ~isscalar(UTCOffset)
                error('UTCOffset must be scalar')
            end
        case 'DateTickInterval'
            DateTickInterval = varargin{vidx+1}; vidx=vidx+2;
            if ~isscalar(DateTickInterval)
                error('DateTickInterval must be scalar');
            end
        case 'DateRange'
            DateRange = varargin{vidx+1}; vidx=vidx+2;
            if numel(DateRange) ~= 2 || ~ isnumeric(DateRange)
                error('DateRange requires [start, stop] matlab serial dates');
            end
        case 'Effort'
            Effort = varargin{vidx+1}; vidx=vidx+2;
            if size(Effort, 2) ~= 2
                error('Effort must have start and end serial dates');
            end
        case 'HourTickInterval'
            HourTickInterval = varargin{vidx+1}; vidx=vidx+2;
            if ~isscalar(HourTickInterval)
                error('HourTickInterval must be scalar');
            end
        case 'Label'
            Label = varargin{vidx+1}; vidx=vidx+2;
            if ~ischar(Label)
                error('Label must be a string');
            end
        case 'LabeledData'
            LabeledData = varargin{vidx+1}; vidx=vidx+2;
            if ~iscell(LabeledData)
                error('LabeledData must be a cell array');
            end
        case 'Resolution_m'
            Resolution_m = varargin{vidx+1}; vidx = vidx+2;
            if ~ isscalar(Resolution_m)
                error('Resolution_m must be scalar');
            end
        case 'Title'
            Title = varargin{vidx+1}; vidx=vidx+2;
            if ~ ischar(Title)
                error('Title must be a character string');
            end
        case 'BarHeight'
            BarHeight = varargin{vidx+1}; vidx=vidx+2;
        case 'BarOffset'
            BarOffset = varargin{vidx+1}; vidx=vidx+2;
        case 'Color'
            Color = varargin{vidx+1}; vidx = vidx+2;
        case 'NoEffortColor'
            NoEffortColor = varargin{vidx+1}; vidx = vidx+2;
        case 'Debug'
            debug = varargin{vidx+1}; vidx = vidx+2;
        case 'LineStyle'
            LineStyle = varargin{vidx+1}; vidx = vidx+2;
        case 'Transparency'
            Transparency = varargin{vidx+1}; vidx = vidx+2;
        case 'XLength_d'
            XLength_d = varargin{vidx+1}; vidx = vidx+2;
        otherwise
            error('Bad argument %s', varargin{vidx+1});
    end
end

if UTCOffset ~= 0
    offset = datenum(0, 0, 0, UTCOffset, 0, 0);
    presence = presence + offset;
    if ~ isempty(Effort)
        Effort = Effort + offset;
    end
    if ~ isempty(DateRange)
        DateRange = DateRange + offset;
    end
    Xstring = sprintf('h (UTC%+.1f)', UTCOffset);
else
    Xstring = 'h (UTC)';
end


Color = visRGB(Color);
if isempty(NoEffortColor)
    NoEffortColor = Color;
    NoEffortTransparency = Transparency*.10;
else
    NoEffortColor = visRGB(NoEffortColor);
    NoEffortTransparency = 1;
end


% Check validity of BarHeight & BarOffset parameters
if BarHeight > 1 || BarHeight < 0 || BarHeight + BarOffset > 1
    error('BarHeight must be in [0, 1] and BarHeight + BarOffset <= 1')
end

%WinTitle = sprintf('%s (%d m bins)', Title, Resolution_m);

[rows, cols] = size(presence);
if cols > 2
    error('Bad presence information, must be Nx1 or Nx2');
end

if ~ isempty(Effort)
    if ~ isempty(presence) && ...
            (presence(1) < Effort(1, 1) || Effort(end, 2) < presence(end,end))
        warning('Detections [%s %s] outside of effort: [%s %s]', ...
            datestr(presence(1)), datestr(presence(end, end)), ...
            datestr(Effort(1,1)), datestr(Effort(end,2)));
    end
end

% default to detections and override later if needed
if ~ isempty(presence)
    if cols == 1
        dates = [min(presence(:,1)), max(presence(:,1))];
    else
        dates = [min(presence(:,1)), max(presence(:,2))];
    end
end

% convert presence information to days and day offsets
if ~ isempty(presence)
    [presence_d, presence_dayfrac] = dbDateToOffsets(presence, Resolution_m, debug);
end

axH = gca;  % get axis handle for current figure

if ~ isempty(presence)
    N = size(presence_d, 1);
    presenceH = zeros(N, 1);
    width = diff(presence_dayfrac, 1, 2);
    if N > 0
        BarH(1) = hggroup;
        set(BarH(1), 'Parent', axH);
        
        for idx = 1:N
            x = presence_dayfrac(idx, 1);
            y = presence_d(idx, 1) + BarOffset;
            % plot the rectangle on the axis
            %presenceH(idx) = rectangle('Position', [x y width(idx) BarHeight],
            %...
            presenceH(idx) = patch([x; x+width(idx); x+width(idx); x], ...
                [y; y; y+BarHeight; y+BarHeight], Color, 'Parent', BarH(1), ...
                'LineStyle', LineStyle, 'FaceAlpha', Transparency);
            % store serial dates as user data
            info.dates = [y+x, y+x+width(idx)];
            info.label = Label;
            set(presenceH(idx), 'UserData', info, ...
                'ButtonDownFcn', @visPresenceCB);
            
        end % end idx loop
    end
end

if ~isempty(LabeledData)
    % Plot labels
    duration = diff(presence, [], 2); % event duration
    mid = mean(presence, 2);   % midway through event
    noon = datenum([0 0 0 12 0 0]);
    for k=1:size(presence, 1)
        % Determine where to put text
        if duration > 2
            % Over a 2 day period, put at ~ 12:00 in middle of event
            day = dbDateToOffsets(mid(k), Resolution_m);
            text(noon, day, LabeledData{k});
        else
            % short event, place around start
            [day, partial] = dbDatesToOffsets(presence(k,1), Resoution_m);
            text(partial, day, LabeledData{k});
        end
    end
end

if ~ isempty(DateRange)
    % Set date axis to desired interval
    dates = [floor(DateRange(1)), ceil(DateRange(2))];
    set(axH, 'YLim', dates, 'YTickMode', 'manual');
elseif ~ isempty(Effort)
    % Set date axis to appropriate interval
    if isempty(dates)
        dates = [floor(Effort(1,1)), ceil(Effort(end,2))];
    else
        dates = [min(floor(Effort(1,1)), dates(1)), ...
            max(ceil(Effort(end,2)), dates(2))];
    end
    set(axH, 'YLim', dates, 'YTickMode', 'manual');
end

% Show regions of no effort
if ~ isempty(Effort)
    Effort = dbRemoveOverlap(Effort);  % entries might have overlap
    
    % See if we need to show no effort at start and end
    startP = Effort(1,1) > dates(1);
    stopP = Effort(end,2) < dates(2);
    % Find out how many NoEffort entries we will have
    NoEffort = zeros(size(Effort,1) + startP + stopP - 1, 2);
    % handle time before first effort
    if startP
        NoEffort(1,:) = [dates(1), Effort(1,1)];
    end
    % construct areas where no effort was made
    if size(NoEffort, 1) > startP + stopP
        NoEffort(startP+1:end-stopP, :) = ...
            [Effort(1:end-1, 2) Effort(2:end, 1)];
    end
    % handle time after last effort
    if stopP
        NoEffort(end, :) = [Effort(end, 2) dates(2)+1-eps];
    end
    
    [noeffort_d, noeffort_m] = ...
        dbDateToOffsets(NoEffort, ResolutionNoEffort_m, debug);
    NoEffortH = zeros(size(noeffort_d, 1)); % preallocate handle array
    width = diff(noeffort_m, [], 2);
    if ~ isempty(NoEffortH)
        BarH(2) = hggroup;  % create a handle graphics group
        set(BarH(2), 'Parent', axH);
        for idx=1:size(noeffort_d, 1)
            x = noeffort_m(idx, 1);
            y = noeffort_d(idx, 1)+ BarOffset;
            NoEffortH(idx) = patch([x; x+width(idx); x+width(idx); x], ...
                [y; y; y+BarHeight; y+BarHeight], NoEffortColor, ...
                'Parent', BarH(2), 'LineStyle', LineStyle, ...
                'FaceAlpha', NoEffortTransparency);
            % store serial dates as user data
            info.dates = [y+x, y+x+width(idx)];
            info.label = sprintf('No effort: %s', Label);
            set(NoEffortH(idx), 'UserData', info, ...
                'ButtonDownFcn', @visPresenceCB);
            
        end
    end
end

XTicks = linspace(0, 1, round(24/HourTickInterval)+1);

set(axH, 'XLim', [0, 1], ...
    'XTick', XTicks,'TickDir','out', 'XTickLabel', XTicks * 24, ...
    'XGrid', 'on');

set(axH, 'YTickMode', 'manual');
% order is important here.
% do not use datetick before setting YTick
% datetick will not recalculate the dates
set(axH, 'YGrid', 'on', ...
    'YTick', dates(1):DateTickInterval:dates(2));
datetick(axH, 'y', 1, 'keeplimits', 'keepticks');

title(Title);
xlabel(Xstring)
% ylabel('date')

end % end function
