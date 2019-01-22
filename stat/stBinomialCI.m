function [Offset, LowHigh] = stBinomialCI(p, N, CI)
% [Offset, MeanHigh] = stMeanCI(p, N, CI)
% Compute the CI% confidence interval (95% if not given) for a mean sampled
% from a binomial distribution.  
%
% If p is a vector, the confidence interval is computed for each value
% of p.
% 
% If the LowHigh output is present, returns the lower & upper values in
% LowHigh.where each row corresponds to an element of p.
%
% This code is copyrighted 2004-2005 by Marie Roch.
% e-mail:  marie.roch@ieee.org
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 


q = 1 - p;
if nargin < 3
  Alpha = .05;
else
  Alpha = 1 - CI;
end

Offset = zeros(size(p));

for k=1:length(Offset)
  Offset(k) = norminv(1-Alpha/2, 0, sqrt(p(k)*q(k)/N));        % requires statistics toolbox
end

if nargout > 1
  LowHigh = p + [-1 1] .* Offset;
end
