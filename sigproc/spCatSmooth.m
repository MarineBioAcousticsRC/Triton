function Smoothed = spCatSmooth(Category, MinWidth)
% Given a set of two-class classification labels, smooth them by
% changing the label of any set of frames with less than MinWidth
% classification labels is changed to be of category of the surrounding
% region.  It is assumed that some type of smoothing has already been
% done and that we do not see lots of small adjacent regions, 
%	i.e. 1 2 2 1 1 1 2 2 1 2 1 1

Smoothed = Category;
Delta = diff(Category);

[RunStarts, RunLabels, RunLengths] = spRunLengthAnalysis(Category);

% Locate the category labels which are too short. 
RunShort = find(RunLengths < MinWidth);

% Change the category of the short ones.
for idx=1:length(RunShort)
  % Find the index into the RunStarts and RunLengths vectors
  idxStartsLength = RunShort(idx);
  if idxStartsLength > 1
    % Change category to predecessor category
    idxChangepoint = RunStarts(idxStartsLength);
    Smoothed(idxChangepoint+(0:(RunLengths(idxStartsLength)-1))) ...
	= RunLabels(idxStartsLength - 1);
  end
end

    
    


