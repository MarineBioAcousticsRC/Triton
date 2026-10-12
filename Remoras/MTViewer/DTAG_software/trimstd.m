function [s,m] = trimstd(x,percent)
%TRIMSTD The trimmed standard deviation of X is a robust estimate of the sample variability.
%   [S,M] = TRIMSTD(X,PERCENT) calculates the std of X excluding the highest
%   and lowest percent/2 of the data. For matrices, TRIMMEAN(X) is a vector
%   containing the trimmed std for each column. The scalar, PERCENT, 
%   must take values between 0 and 100. Also returns the trimmed mean as a
%   2nd output argument.
%
%   For matrix, X, [S,M] = TRIMSTD(X,PERCENT) is a row vector containing the
%   trimmed std for each column of X.   

%   mark johnson, WHOI
%   based entirely on TRIMMEAN by:
%   B.A. Jones 3-04-93
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 2.10 $  $Date: 2002/01/17 21:32:06 $

if nargin < 2
    error('Requires two input arguments.');
end

if percent >= 100 | percent < 0
    error('Percent must take values between 0 and 100.');
end

zlow = prctile(x,(percent / 2));
zhi  = prctile(x,100 - percent / 2);

[n p] = size(x);

zlow = zlow(ones(n,1),:);
zhi  = zhi(ones(n,1),:);
indicator = (x >= zlow & x <= zhi & ~isnan(x));
sumi = sum(indicator);
x(isnan(x)) = 0;
m = sum(x .* indicator) ./ max(1, sumi);
s = sqrt(sum((x-ones(n,1)*m).^2.*indicator))./max(1,sumi) ;

if (any(sumi==0))
   m(sumi==0) = NaN;
   s(sumi==0) = NaN ;
   if (all(sumi==0))
      warning('Too much data trimmed.  Result returned as NaN.');
   else
      warning('Too much data trimmed.  Some output values set to NaN.');
   end
end
