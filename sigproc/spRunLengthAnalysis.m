function [Start, Label, Length] = spRunLengthAnalysis(Signal, MergeLabel, MergeLength)
% [Start, Label, Length] = spRunLengthAnalysis(Signal, MergeLabel, MergeLength)
% Given a signal with discrete values, return the following vectors
% Start(j) = j'th type of value to be found in signal
% Label(j) = value of j'th entry
% Length(j) = Number of consecutive times Label(j) appears starting at
%	Start(j)
%
% Example:
% >> [zs, zlab, zlen] = spRunLengthAnalysis([1 1 1 2 2 3 3 3 3 2 1 1 1]);
% >> [zlab' zs' zlen']
%  
%  ans =
%  
%       1     1     3	Label 1 starts at position 1 and is of length 3.
%       2     4     2   Label 2 starts at position 4 and is of length 2
%       3     6     4   Label 3 starts at position 6 and is of length 4
%       2    10     1   Label 2 starts at position 10 and is of length 1
%       1    11     3   Label 1 starts at position 11 and is of length 3
%
% When the MergeLabel and MergeLength arguments are present, when two
% identical values appear in the Signal and are separated by no more than
% MergeLength instances with the value MergeLabel, the two runs are
% merged.
%
% Example:
% >> [zs, zlab, zlen] = spRunLengthAnalysis(...
%                       [1 1 1 0 0 0 1 1 0 0 1 1 0 1 0 0 0 0 1 1 1], 0, 2)
% >> [zlab' zs' zlen']
% 
% ans =
% 
%      1     1     3    Label 1 starts at position 1 and is of length 3
%      0     4     3    Label 0 starts at position 4 and is of length 3
%      1     7     8    Label 1 starts at position 7 and is of "length" 7
%                               Note that since there were two sets of 0s
%                               of <= length 2, they are merged into this
%                               group.
%      0    15     4    Label 0 starts at position 15 and is of length 4
%      1    19     3    Label 1 starts at position 19 and is of length 3

if (nargin ~=1) && (nargin ~= 3)
  error('One or three arguments required.')
end

Delta = diff(Signal);

% First run starts at 1.  Subsequent ones start everytime (|Delta| > 0) + 1.
Start = [1, find(abs(Delta) > 0) + 1];

% Use diff of starting positions to figure out how long each run is.
Length = [diff(Start), length(Signal) - Start(end) + 1];

Label = Signal(Start);

if nargin == 3
  % Find all instances of the label that satisfy the length requirement
  Candidates = find((Length <= MergeLength) & (Label == MergeLabel));
  if ~ isempty(Candidates)
    % Remove instances that come at the beginning or end of the list
    if Candidates(end) == length(Label)
      Candidates(end) = [];
    end
    if Candidates(1) == 1
      Candidates(1) = [];
    end
    % Find all candidates with the same label before & after
    Candidates = Candidates(Label(Candidates - 1) == Label(Candidates + 1));
    % Merge these by updating preceding run length to span the label being
    % dropped and the subsequent instance of the preceding label class.  Then
    % remove the skipped and subsequent runs.
    for c = length(Candidates):-1:1       % work backwards (prevent index change)
      Cand_idx = Candidates(c);   % Avoid for Cand_idx = Candidates in case
                                  % column vector
      Length(Cand_idx-1) = sum(Length(Cand_idx-1:Cand_idx+1));
      Length(Cand_idx:Cand_idx+1) = [];
      Start(Cand_idx:Cand_idx+1) = [];
      Label(Cand_idx:Cand_idx+1) = [];
    end
  end
end
  

