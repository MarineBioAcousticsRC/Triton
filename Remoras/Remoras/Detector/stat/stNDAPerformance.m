function Performance = stNDAPerformance(Weight, Alpha, Beta, Scores, ClassSpecific)
% Performance = stNDAPerformance(Weight, Alpha, Beta, Scores)
% Given a cell array of scores, and parameters for LDA,
% determine how well classification performs.
% It is assumed that LDA has been set such that a positive
% distance implies in class, and the maximum LDA value for each class
% is determined.
% 
% Percentage correct is returned.

ClassCount = length(Scores);
FeatureCountP = size(Scores{1}, 1);
TokenCounts = zeros(ClassCount, 1);

Features=1:FeatureCountP-1;	% Assume last feature is fused score - ignore

Correct = 0;
Incorrect = 0;
Count = 0;

if nargin < 5
  ClassRange = 1:ClassCount
else
  ClassRange = ClassSpecific;
end

for class=ClassSpecific
  Count = Count + size(Scores{class}, 3);
  for test=1:size(Scores{class}, 3)
    TestResult = Alpha .* ...
	(squeeze(Scores{class}(Features,:,test))' * Weight) + Beta;
    [MaxVal MaxIdx] = max(TestResult);
    if MaxIdx == class
      Correct = Correct + 1;
    else
      Incorrect = Incorrect + 1;
    end
  end
end

Performance = Correct/Count;
