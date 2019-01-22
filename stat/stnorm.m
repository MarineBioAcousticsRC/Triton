function p = stNorm(x)
% p = stNorm(x)
% Given a 1 dimensional standard normal distribution (mean 0, std dev 1),
% compute the density measure at x.  If x is a matrix, compute the 
% density for each element.

p = 1/(2*pi) * exp(-.5 * x .* x);
