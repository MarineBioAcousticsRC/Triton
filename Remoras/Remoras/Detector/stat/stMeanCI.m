function [CIMeanLow, MeanHigh] = stMeanCI(Mean, Variance, N)
% [CIOffsetOrMeanLow, MeanHigh] = stMeanCI(Mean, Variance, N)
% Compute the 95% confidence interval for a Mean sampled from a normal
% (Gaussian) distribution.  If only one output is given, computes the
% CI offset.  If two output arugments are specified, gives the low and
% high CI values (mean +/- CIOffset).
%
% Note:  Currently only works with 1 dimensional data.

CIMeanLow = 1.96 * sqrt(Variance) ./ sqrt(N);
if nargout > 1
  MeanHigh = Mean + CIMeanLow;
  CIMeanLow = Mean - CIMeanLow;
end

