function return_idx = base3(baseline, percent)

    sorted_bl = sort(baseline);
    length_bl = length(sorted_bl);

    start_idx = floor((percent/100)*length_bl);
    if start_idx == length_bl
        start_idx = length_bl - 1;
    end
    
    sorted_bl = [ sorted_bl(1 : end - start_idx), ...
                  sorted_bl(start_idx + 1 : end)];

    % Find smallest interval covering x% of the distribution
    [~, smallest_diff_idx]= min(diff(sorted_bl, 1, 2));

    low = sorted_bl(smallest_diff_idx, 1);
    high = sorted_bl(smallest_diff_idx, 2);

%     val_lower = find(baseline >= low);
%     val_higher = find(baseline <= high);
%     return_idx = intersect(val_lower, val_higher);
	return_idx = find(baseline >= low & baseline <= high);

end