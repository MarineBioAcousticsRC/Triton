function Class = stNDAClassify(Weight, Alpha, Beta, Scores)
% Class = stNDAClassify(Weight, Alpha, Beta, Scores)
% Compute scores of normalized LDA.
% Class is a vector with with one entry per observation.
% If the value is less than 0, the observations was
% classified as belonginto to class 1, otherwise class 2.

Class = Alpha .* (Scores * Weight) + Beta;

N = size(Scores,1);
Neg = length(find(Class < 0));
fprintf('Classification:  Neg %.3f\tPos %.3f\n', Neg / N, (N - Neg) / N);
