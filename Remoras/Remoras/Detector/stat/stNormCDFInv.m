function x = stNormCDFInv(Pr, Mu, Sigma)
% x = stNormCDFInv(Pr, Mu, Sigma)
% Find x for the univariate normal(Mu, Sigma^2) such that
%
%	      _ x
%	Pr = _/    f_norm(Mu, Sigma ^ 2)(x) dx
%	     -Inf
% 
% Algorithm from 
%      M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 7.1.1 and 26.2.2

% Used to use GKS Statbox
% x = erfinv(2*p-1) * sqrt(2) * sigma + 1;

if nargin < 3
  Sigma = 1;
end

if nargin < 2
  Mu = 0;
end

x = (-sqrt(2)*Sigma).*erfcinv(2*Pr) + Mu;
