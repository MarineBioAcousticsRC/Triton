function [start, stop, duration] = spDurations(Indices, MergeThreshold)
% [start, duration] = spDurations(Indices)
% Given a vector of indices into another vector, determine
% the starting point of each distinct region and how long it is.
%
% example:
% [start, stop, dur] = spDurations([17:20, 50:52, 75:80])
% returns
% start = [17, 50, 75]
% stop = [20, 52, 80]
% duration = [4, 3, 6]

% find skips in sequence
diffs = diff(Indices);

% 1st index is always a start 
% last index is always a stop
% indices whose first difference is greater than one denote a 
% start or stop boundary.
%start = Indices([1; find(diffs > 1) + 1]);
StartPositions = [1; find(diffs > MergeThreshold) + 1];
if length(StartPositions) > 1
  StopPositions = [StartPositions(2:end) - 1; length(Indices)];
else
  StopPositions = length(Indices);
end
start = Indices(StartPositions);
stop = Indices(StopPositions);

duration = stop - start + 1;
