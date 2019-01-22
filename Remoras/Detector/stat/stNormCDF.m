function p = stNormCDF(x)
% p = stNormCDF(x)
% Find the value of p such that integrating the normal
% distribution from -inf to x = p.
%
% Algorithm from GKS StatBox

p=(1+erf(x/sqrt(2)))./2;
