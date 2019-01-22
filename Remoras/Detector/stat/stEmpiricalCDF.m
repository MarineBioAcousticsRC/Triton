function [Fx, N] = stEmpiricalCDF(Sample)
% [Fx, N] = stEmpiricalCDF(Sample)
% Given a sample, estimate the cumulative distribution function.
%
% Example:  Show the CDF of a normal distribution
% z = randn(500, 1);  % 500 draws from normal(0,1)
% [Fx, N] = stEmpiricalCDF(z);
% plot(N, Fx);
% xlabel('x'); ylabel('P(Z \leq x)')

N = sort(Sample);
d1 = diff(N);
identical = find(d1 == 0);

Count = length(N);
Fx = [1:Count] ./ Count;

Fx(identical) = [];
N(identical) = [];


