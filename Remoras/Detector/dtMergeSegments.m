function Segments = dtMergeSegments(Segments, MinLength, MinSeparation)
% Segments = dtMergeSegments(Segments, MinLength, MinSeparation)
% Segments contains a N x 2 matrix where column 1 is a starting
% position and column 2 is an ending position.
%
% MergeSegments first merges all pairs of segments which are less than
% MinSeparation apart from one another and then deletes segments
% that are shorter than MinLength.
%
% Do not modify the following line, maintained by CVS
% $Id: dtMergeSegments.m,v 1.1.1.1 2006/09/23 22:31:58 msoldevilla Exp $


if isempty(Segments)
  return
end

%Segments
%fprintf('initial\n')

N = size(Segments, 1);

% Find separation between the two
Separation = Segments(2:N,1) - Segments(1:N-1,2);

% Determine which ones should be merged
Merge = find(Separation < MinSeparation);

% merge them
for row = length(Merge):-1:1
  % New end point - copy next endpoint into current one
  Segments(Merge(row), 2) = Segments(Merge(row)+1, 2);
  % delete row that was merged
  Segments(Merge(row)+1, :) = [];
end

%fprintf('Post merge\n')
%Segments

% Check for segments that are too short and remove them
Lengths = Segments(:,2) - Segments(:,1) + 1;
Segments(find(Lengths < MinLength), :) = [];

%fprintf('Post deletion\n')
%Segments
