function [first, last] = lt_lVis_getrange(start, stop, varargin)
% [first, last] = lt_lVis_getrange(start, stop, dates1, dates2, ...)
% Given Matlab serial date (datenum) start and stop, search a list
% of dates to find the first index in dates that is after start
% and the last index that is before stop
% 
% Multiple sets of datenums may be passed in, but they must
% all be the same length and represent measurements on the same
% observation e.g. start and stop times

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

if isinf(first) % Nothing found
    first = [];
    last = [];
end


function idx = binarysearch(target, values, direction)

N = length(values);
% Handle no search cases where target is before the start
% or after the end, then invoke the binary search helper
if target < values(1)
    idx = 1;  % First value after target is values(1)
elseif target > N
    idx = length(values);  % First value after target is valued(end)
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
% fprintf('(%d=%f, %d=%f) midpt=%d\n', low,values(low),high, values(high), midpt);
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
