function [Fx, N] = stDiscreteCDF(Sample, Population)
% Fx = stDiscreteCDF(Sample, Population)
% Given a random sample from an ordered population, determine the empirical
% cumulative distribution function: P(sample <= Population)
%
% Population is the set of possible values, e.g. 1:6 for a die
% Sample is the set of samples
%
% Example:  
% die = round(rand(20,1) * 6 + .5)';  % 20 throws of a fair die
% Fx = stDiscreteCDF(1:6, die);
% figure; 
% bar(1:6, Fx);
% xlabel 'X'
% ylabel('P(X \leq N)')
%
% This function can be used to compute empirical cdf's when the
% distribution that a samplple was drawn from is unknown.
% In this case, just provide the sample
%
% Example:
% x = (randn(5000, 1)+17)*10;  % N draws from n(u=17, sigma^2=100)
% [Fx, N] = stDiscreteCDF(x);
% figure;
% plot(N, Fx);
% xlabel 'X'
% ylabel('P(X \leq N)')


values = sort(Sample);  % order the sample
if nargin < 2
    N = unique(values);  % remove duplicates
else
    % Make sure that population is sorted and unique
    N = unique(Population);   % <= N
end

valuesN = length(values);
pidx = 1;
vidx = 1;
while pidx <= length(N)
  while (vidx < valuesN & values(vidx+1) <= N(pidx))
    vidx = vidx + 1;
  end
  Fx(pidx) = vidx / length(values);
  pidx = pidx + 1;
end

