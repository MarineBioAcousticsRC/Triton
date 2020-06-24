function [first, last] = lt_lVis_getrange(start, stop, varargin)
% [first, last] = lt_lVis_getrange(start, stop, dates1, dates2, ...)
% start, stop - Matlab serial dates (datenum)
% date1, date2, ... - Arrays of related serial dates all of the same size.
%    Operates on each date vector spearately and assumes that the vectors
%    are related to one another (e.g. different measurements on the same
%    event such as start and end time).
%
%    For each date vector, we find:
%    values(first) - First date > start
%    values(last) - Last date < stop
%
%    When multiple date vectors are passed in, we merge all indices,
%    first = min([first1, first2, ...])
%    last = max([last1, last2, ...])
%
% When the dates are entirely outside of the specified range,
% first = [], last = []


first = Inf;
last = -Inf;

for idx = 1:length(varargin)
    dates = varargin{idx};
    
    vfirst = binarysearch(start, dates, 1);
    vlast = binarysearch(stop, dates, -1);

    if vfirst <= vlast
        % Good range, update 
        first = min(first, vfirst);
        last = max(last, vlast);
    end
end

if isinf(first) || isinf(last) % Nothing found
    first = [];
    last = [];
end


function idx = binarysearch(target, values, direction)
% idx = binarysearch(target, values, direction)
% Given a set of values, find the index of values such that:
% direction 1:
%   values(idx) is the first item such that values(idx) >= target
% direction -1
%   values(idx) is the last item such that values(idx) <= target

N = length(values);
% Handle no search cases where target is before the start
% or after the end, then invoke the binary search helper
if direction == 1 && (target > values(end))
    % First value after target: no such value
    idx = Inf;
elseif direction == -1 && (target < values(1))
    % Last value before target: no such value
    idx = -Inf;
else
    % Perform a binary search to find it.
    idx = searchhelper(1, N, target, values, direction);
end

function idx = searchhelper(low, high, target, values, direction)
% idx = searchelper(low, high, target, values, direction)
% Given a target and a set of sorted values, find the index
% of the first item in values after value (direction = 1)
% or the last item in values before value (direciton = -1)
% within the range values[low] and values[high]

midpt = floor((high - low) / 2) + low;
%debug
%fprintf('(%d=%s, %d=%s) tgt=%s midpt=%d\n', low, datestr(values(low)),high, datestr(values(high)), datestr(target), midpt);
%fprintf('(%d=%d, %d=%d) tgt=%d midpt=%d\n', low, values(low), high, values(high), target, midpt);
if ismember(midpt, [low, high])
    % low and high are consecutive
    % Base case of recursion, need to make a decision
    switch direction
        case 1
            % First value past target
            if target <= values(low) 
                idx = low;
            else
                idx = high;
            end
        case -1
            % Last value before target
            if target < values(high)
                idx = low;
            else
                idx = high;
            end
    end
else
    % Need to narrow range between low and high
    % Find out which side the midpoint the target is on and search
    if target < values(midpt)
        high = midpt;
        idx = searchhelper(low, high, target, values, direction);
    else
        low = midpt;
        idx = searchhelper(low, high, target, values, direction);        
    end
end
