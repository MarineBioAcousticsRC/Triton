function presenceI = visPresenceAbsence(presence, varargin)
% visPresenceAbsence(presence, Optional args...)
% Show presence/absence plot
% Display presence/absence in resolution_m increments
% Presence is a one or two column matrix giving starting (and 
% possibly ending times) as Matlab serial dates.  If end time 
% is unavailable, only the resolution_m segment containing the 
% start time will be selected. 
%
% Optional arguments:
%  'Effort', [start, end] - Plot over the range of these serial dates
%  'Resolution_m', M - Plot resolution (bin size) in minutes
%  'Title', String - Plot title

% Todo:  implement optional arguments
% it would make sense to take matrix for effort so that we can grey
% out off times (e.g. for multiple efforts plotted on the same grid)

% defaults
Effort = [];  % Use passed in dates
Resolution_m = 5;
Title = 'Presence/Absence plot';
WinTitle = Title;
DateTickInterval = 7;  % one week between date tick labels
mTickInterval = 60;


[rows, cols] = size(presence);
if cols > 2
    error('Bad presence information, must be Nx1 or Nx2');
end

% Round to the start and end of each day
% If effort was not set, use earliest/latest detections
if isempty(Effort)
    % find first and last detections
    firstdet = min(presence(:,1));
    if cols == 2
        lastdet= max(presence(:,2));
    else
        lastdet = max(presence(:,1));
    end
    Effort = [firstdet, lastdet];
end
% Determine range over which we will plot
% Range is beginning of first day of effort
% to the end of the last day of effort.
Range = [floor(Effort(1)), ceil(Effort(end))];

days_of_data=Range(1):Range(2); %vector of all recording days

% set up plot grid
m_per_h = 60;
m_per_day = 24*m_per_h^2;  % minutes per day
bins_per_day = ceil(m_per_day / Resolution_m);
days = diff(Range);  % how many days we will be plotting across
presenceI = zeros(days, bins_per_day);  % presence/absence indicator
row_days = 1;
col_days = Resolution_m / m_per_day;

offsets = presence - Range(1);
for idx=1:rows
    % convert start date to day and bin
    [start_r, start_c] = ...
        date_to_rowcol(offsets(idx, 1), row_days, col_days);
    if cols > 1
        % convert stop date to day and bin
        [stop_r, stop_c] = ...
            date_to_rowcol(offsets(idx, 2), row_days, col_days);
    else
        % no stop date, use the start date
        stop_r = start_r;
        stop_c = start_c;
    end
    
    % prime our loop variables
    current_r = start_r;
    current_c = start_c;
    % loop until we move one bin past the last detection
    while (current_r < stop_r || ...
            (current_r == stop_r && current_c <= stop_c))
        presenceI(current_r, current_c) = 1;  % note detection
        % move to next bin and check for wrap around
        current_c = current_c + 1;
        if (current_c > bins_per_day)
            current_c = 1;  
            current_r = current_r + 1;  % new day
        end
    end
end % end idx loop
    
figure('Name', WinTitle);
colormap([1 1 1; .25 .25 .25]);  % white/gray color scheme
h_axis = 0:Resolution_m/60:24-Resolution_m/(2*60);
d_axis = 0:days;
axH = imagesc(h_axis, d_axis, presenceI);

% set up labels for the days, create a label every DateTickInterval
% so that the display is not too cluttered.  The empty labels will
% not be displayed.  It would have been nicer to use major ticks for
% the weeks and minor ticks 
day_labels = cell(length(days_of_data), 1);
day_labels(1:DateTickInterval:length(days_of_data)) = ...
    cellstr(datestr(days_of_data(1):DateTickInterval:days_of_data(end), 2));

set(gca, 'YDir', 'normal', ...
    'YTick', 0:length(days_of_data), ...
    'YTickLabel', day_labels, ...
    'XTick', 0:23, ...
    'XTickLabel', (0:mTickInterval:m_per_day)/m_per_h, ...
    'XGrid', 'on', 'YGrid', 'on');


    %{
  set(h(n), 'Title',text('String',speciesname{n}), ...
    'XTick',[min(get(h(n),'XLim')):60:max(get(h(n),'XLim'))-1], ...
    'XTickLabel', num2str([0:1:23]'), ...
    'YTick',[min(get(h(n),'YLim')):1:max(get(h(n),'YLim'))-1], ...
    'YTickLabel',datestr(days_of_data(1:1:length(days_of_data))), ...
    'XLabel',text('String','hour'), ...
    'XGrid','on', 'YGrid', 'on');    
    %}
    

end % end function

function [row, col] = date_to_rowcol(serdate, row_days, col_days)
% Given the minutes per row and column, convert to row and col indices
    
    % determine row
    row = floor(serdate/row_days);
    col = floor((serdate - row*row_days) / col_days) + 1;
    row = row + 1;  % account for Matlab indices starting at 1
end

