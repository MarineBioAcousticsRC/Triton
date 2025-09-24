function [revised, removed] = dbRemoveOverlap(timespans)
% [revised, removed] = dbRemoveOverlap(timespans)
% Given a matrix row oriented start and end dates,
% return a new matrix where overlapping rows have
% been removed.  
%
% The optional output removed indicates which rows
% of the original matrix were deleted.

revised = timespans;
if size(timespans, 1) > 1
    % End of current block goes into start of next
    mergeP = timespans(1:end-1, 2) - timespans(2:end, 1) > -1e-10;  % >0 w/ rounding error
    
    % Merge blocks
    % When multiple blocks are adjacent, merge all into one
    removed = find(mergeP == 1);

    idx = 1;
    while idx <= length(removed)
        % save start of overlap
        start = timespans(removed(idx), 1);
        % find last block of overlap
        while idx < length(removed) & removed(idx+1) - removed(idx) == 1
            idx = idx + 1;
        end
        % copy original start time into last block
        revised(removed(idx)+1, 1) = start;
        idx = idx + 1;
    end
    revised(removed,:) = [];
    if nargout > 1
        removed = removed + 1;
    end
else
    if nargout > 1
        removed = [];
    end
end