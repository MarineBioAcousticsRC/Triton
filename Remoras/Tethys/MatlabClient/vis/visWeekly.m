function visWeekly(queryH, varargin)
% visWeekly(queryH, SelectionCriteria)
% Plot the number of hours per week with detections for the given
% SelectionCriteria.   See dbGetDetections for information on 
% selecting detections and effort.
%
% Caveats:
% Weeks start on Sunday and this may cause slight shifts in distributions
% from other tools that may choose to start weeks on the first day of
% effort



% We count the number of units per bin
% This function is designed to work on weekly bins.  
unit = hours(1);
bin = days(7);
bin_type = 'week';
units_per_bin = unit / bin;

[~, eff] = dbGetEffort(queryH, varargin{:});

if isempty(eff)
    warning("No effort matches query");
    return;
end

group_by_call = false;
if group_by_call
    groups = findgroups(eff.kinds_table.SpeciesId, ...
        eff.kinds_table.Granularity, eff.kinds_table.Call)
else
    groups = findgroups(eff.kinds_table.SpeciesId, eff.kinds_table.Granularity);
end

group_ids = unique(groups);

for g_idx = 1:length(group_ids)
    % todo:  verify that all things are consistent
    
    % Generate true/false vectors that let us select effort and kinds
    select_kinds = groups == g_idx;
    records = eff.kinds_table.RecordIdx(select_kinds);
    unique_records = unique(records);

    select_effort = ismember(eff.effort_table.RecordIdx, unique_records);
    sub_effort = eff.effort_table(select_effort,:);
    gaps = gaps_and_overlap(sub_effort);
    
    % Gather up ids.  
    ids = sub_effort.Id';
    [det, det_info] = dbGetDetections(queryH, 'Id', ids, varargin{:});
    1;
    
    % Get a row from the selected group so that we can know the grouping
    row = eff.kinds_table(find(select_kinds, 1), :);
    % Create an appropriate label
    if group_by_call
        call_str = " " + row.Call{1}; 
    else
        call_str = ""; 
    end
    if ~isnan(row.BinSize_m)
        granularity_str = sprintf(" (%d min bins)", row.BinSize_m); 
    else
        granularity_str=" (" + row.Granularity{1} + ")"; 
    end
    label = row.SpeciesId{1} + call_str + granularity_str;
    
    % effort table is sorted by start time, we are guaranteed 
    % that the first start will be the earliest, but we are not
    % guaranteed that the end will be the latest.
    earliest = sub_effort.Start(1);
    latest = max(sub_effort.End);

    figure('Name', label);
    barH = zeros(2,1);  % handle groups for legend
                
    if isempty(det_info)
        starts = [earliest; latest];
        bin_assignments = discretize(starts, bin);
        binsN = length(bin_assignments);
        % plot detections
        bin_start = dateshift(earliest, 'start', 'week'); % first bin
        bin_labels = bin_start + (bin*[0:binsN-1]);
        counts = zeros(binsN, 1);
        barH(1) = bar(bin_labels, counts);
    end
        
    % Analysis will be different depending on the kind of effort
    switch row.Granularity{1}
        % We handle binned and call granularity similarly, we just check
        % to see which bin their start time is in
        case {'binned', 'call'}
            if strcmp(row.Granularity{1}, 'binned')
                % Sanity checks for binned data
                
                % Check bin sizes consistent
                bin_sizes = unique(eff.kinds_table.BinSize_m(select_kinds));
                if length(bin_sizes) > 1
                    msg = "Refine query, binned detections have mutiple bin sizes: ";
                    msg = msg + row.SpeciesId;
                    if group_by_call
                        msg = msg + " " + row.Call{1};
                    end
                    msg = msg + "bin sizes (min): ";
                    msg = msg + sprintf('%d ', bin_sizes);
                    error(msg);
                end
                % Ensure bin not larger than the duration of the units
                % we are counting
                if minutes(row.BinSize_m) > unit
                    error("Cannot plot when bin size %d min is larger than %s", row.BinSize_m, units);
                end
            end
            
            if ~ isempty(det_info)
                % Bracket with effort to ensure correct week numbers
                starts = [earliest; det_info.detection_table.Start; latest];
                
                % Assign each detection to a unit and bin
                unit_assignments = discretize(starts, unit);
                bin_assignments = discretize(starts, bin);
                binsN = bin_assignments(end);
                % Remove first and last as they represent the effort and are
                % only there to ensure that we have the right number of bins
                unit_assignments = unit_assignments(2:end-1);
                bin_assignments = bin_assignments(2:end-1);
               
            end
            


        case 'encounter'
            % Bracket with effort to ensure correct week numbers
            % We need to look at both the starts and ends as they
            % may span multiple units and bins
            if ~ isempty(det_info)
                starts = [earliest; det_info.detection_table.Start; latest];
                ends = [earliest; det_info.detection_table.End; latest];
                unit_starts = discretize(starts, unit);
                unit_ends = discretize(ends, unit);
                % Create arrays spanning the units (hours) from start to end
                % of each encounter.  Merge these unit arrays, keeping
                % only one entry per unit.
                bins_cell = arrayfun(@(first,last) [first:last]', ...
                    unit_starts(2:end-1), unit_ends(2:end-1), ...
                    'UniformOutput', false);
                unit_assignments = unique(vertcat(bins_cell{:}));
                % As the original times are gone, we compute the bin
                % to which these are assigned.
                bin_assignments = ceil(unit_assignments * units_per_bin);
                binsN = ceil(unit_ends(end) * units_per_bin);
            end
            
    end
    
    if ~ isempty(det_info)
        % switch statemet will have taken care of assigning
        % detections to units and bins.  Collect and plot
        % Find out how many units/bin --------------------
        % Determine groups of non-empty bins
        bin_group = findgroups(bin_assignments);
        % Determine how many unique unit assignments we had per bin
        group_counts = splitapply(@(x) length(unique(x)), unit_assignments, bin_group);
        group_units = unique(bin_assignments);
        % Assing the identified units/bin to a counts vector
        counts = zeros(binsN, 1);
        counts(group_units) = group_counts;
        
        
        % plotting ---------------------------------
        
        % plot detections
        bin_start = dateshift(earliest, 'start', 'week'); % first bin
        bin_labels = bin_start + (bin*[0:binsN-1]);
        barH(1) = bar(bin_labels, counts);
    end
    
    xlabel('week')
    ylabel('hours/week of detections')
    set(gca, 'YLim', [0, hours(bin)]);
    
    % plot regions of no analysis effort
    barH(2) = plot_noeffort(sub_effort, gaps, bin, bin_start);
end

function gaps = gaps_and_overlap(table)
% gaps = gaps_and_overlap(table)
% Compute gaps between subsequent ends and starts
% Warn if there are overlaps
%
% Caveat:  We do not check for overlaps other than between subsequent
%          entries of the table.
gaps = table.Start(2:end) - table.End(1:end-1);
overlap = gaps < seconds(0);
if any(overlap)
    msg = ["Warning:  Overlapping effort"];
    indices = find(overlap)';
    for idx = indices
        msg(end+1) = sprintf("(%s - %s) and (%s - %s)", ...
            table.Start(idx), table.End(idx), ...
            table.Start(idx+1), table.End(idx+1));
    end
    warning(strjoin(msg, '\n'));
end



function barH = plot_noeffort(effort, gaps, bin, bin_start)
% barH = plot_noeffort(effort, gaps, bin, bin_labels)
%
% Internal function for adding no-effort regions to the plot
% Arguments:
%  effort - effort table to be anlayzed.  
%  gaps - durations showing gaps in the effort
%  bin - size of bins into which we are plotting (duration)
%  bin_labels - datetime array of x-axis values for plot


NoEffortTransparency = 0.3;
NoEffortColor = visRGB('gray');

% identify gap regions
% if pos_gaps(i) = j, then there is a gap between
% sub_effort j and sub_effort j+1
pos_gaps = find(gaps>0)';

gap_table = table(effort.End(pos_gaps), ...
    effort.Start(pos_gaps+1), ...
    'VariableNames', {'GapStart', 'GapEnd'});
% Determine the start/end unit (week) of the gaps
% Contains a dummy row so that discretize treats the
% start of effort as unit (week) 1.
gap_bins = table(...
    discretize([bin_start;gap_table.GapStart], bin), ...
    discretize([bin_start;gap_table.GapEnd], bin), ...
    'VariableNames', {'GapStart', 'GapEnd'});
gap_bins(1,:) = [];  % Remove dummy row

% Determine partial effort
% PartialStart shows the duration of effort in the first
% partial bin, PartialEnd in the last.  When the gap is
% only one bin, the two must be summed to determine how
% much effort was in the bin
eff_partial = table(...
    gap_table.GapStart - dateshift(gap_table.GapStart, 'start', 'week'), ...
    dateshift(gap_table.GapEnd, 'end', 'week') - gap_table.GapEnd, ...
    'VariableNames', {'PartialStart', 'PartialEnd'});

% plot the missing effort
barH = hggroup();
hold_state = ishold();  % Save for later
hold on
delta_weeks = gap_bins.GapEnd - gap_bins.GapStart;

for idx=1:height(gap_table)
    if delta_weeks(idx) == 0
        % analysis gap smaller than bin size
        missing = bin - ...
            (eff_partial.PartialStart(idx) + ...
            eff_partial.PartialEnd(idx));
        gap_start = bin_start + (gap_bins.GapStart(idx)-1)*bin;
        gap_end =  bin_start + (gap_bins.GapStart(idx))*bin;
        lower = hours(bin - missing);
        upper = hours(bin);
        Xs = [gap_start; gap_end; gap_end; gap_start];
        Ys = [lower; lower; upper; upper];
        fill(Xs,Ys, ...
            NoEffortColor, ...
            'Parent', barH, 'LineStyle', 'none', ...
            'FaceAlpha', NoEffortTransparency);
    else
        % Find first bin before the gap & end of last one
        gap_start = bin_start + (gap_bins.GapStart(idx)-1)*bin;
        gap_end =  bin_start + (gap_bins.GapEnd(idx))*bin;
        % h of analysis missing from first/last bins
        miss_start = bin - eff_partial.PartialStart(idx);
        miss_end = bin - eff_partial.PartialEnd(idx);
        if delta_weeks(idx) > 1
            Xs = [gap_start; gap_start+bin; gap_start+bin; gap_end-bin; gap_end-bin; gap_end; gap_end; gap_start];
            Ys = [hours(miss_start); hours(miss_start); 0; 0; hours(miss_end); hours(miss_end); hours(bin); hours(bin)];
        else
            Xs = [gap_start; gap_start+bin; gap_start+bin; gap_end; gap_end; gap_start];
            Ys = [hours(miss_start); hours(miss_start); hours(miss_end); hours(miss_end); hours(bin); hours(bin)];
        end
        fill(Xs,Ys, ...
            NoEffortColor, ...
            'Parent', barH, 'LineStyle', 'none', ...
            'FaceAlpha', NoEffortTransparency);
    end
end
if ~ hold_state, hold off; end   % Restore hold state


    
    

