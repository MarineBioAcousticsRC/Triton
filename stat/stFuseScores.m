function Fused = stFuseScores(Unfused, Method, varargin)
% FusedScores = stFuseScores(UnfusedScores, Method)
% Given a column vector of scores produced by different models, fuse
% the scores according to the techniques specified by Method.  Valid
% methods:
%
% 'sum' - default
% 'max' - Maximum value
% 'weight', Run, TestIdx - Weights are stored in the runtime structure
%	and should be used to weight the scores.
%
% If Unfused is a matrix, data fusion is performed on each column.
% Unfused may also be a three dimensional MxNxK matrix in which the results
% for each plane are computed and a 1xNxK result is returned.

error(nargchk(1, inf, nargin))

if nargin < 2	% supply default if method not specified
  Method = 'sum';
end

switch Method
  case 'sum'
    Fused = sum(Unfused, 1);
  case 'max'
    Fused = max(Unfused, [], 1);
  case 'weight'
    Weights = varargin{1}.Test.Weights(varargin{2}, :)';
    [SubBands Speakers Tests] = size(Unfused);
    Fused = sum(Unfused .* Weights(:, ones(Speakers, 1), ones(Tests, 1)), 1);
  otherwise
    error('Bad method');
end
