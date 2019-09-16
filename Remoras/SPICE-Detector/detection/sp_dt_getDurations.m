function [start, stop] = sp_dt_getDurations(detIndices, mergeThreshold,idxMax)
% [start, duration] = spDurations(Indices)
% Given a vector of indices into another vector, determine
% the starting point of each distinct region and how long it is.

if isempty(detIndices)
    stop = [];
    start = [];
    return
end
% find skips in sequence
diffs = diff(detIndices)';

% 1st index is always a start 
% last index is always a stop
% indices whose first difference is greater than one denote a 
% start or stop boundary.
startPositions = [1; find(diffs > mergeThreshold) + 1];
start = detIndices(startPositions);
if length(startPositions) > 1
    stopPositions = [startPositions(2:end) - 1; length(detIndices)];
    stop = detIndices(stopPositions);
else
    stop = min(detIndices(startPositions)+1,idxMax);
end



