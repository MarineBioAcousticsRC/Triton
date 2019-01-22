function [m,b,y1] = linefit(x,y,x1)
%linefit	Fit a line to a set of (x,y) points
%
% [m,b] = linefit(x,y)
%    Given vectors x and y of the same length, solve for best-fitting m and b 
%    in  y = m*x + b.  "Best-fitting" is in the least-squares sense.  This
%    could be done with polyfit, but this special case is faster by a factor
%    of 5 or so.
%
% [m,b,y1] = linefit(x,y,x1)
%    If a third arg x1 is given, also calculate y1 = m*x1 + b.
%
% See also polyfit, polyval.
%
% Dave Mellinger
% David.Mellinger@oregonstate.edu

% Fit the line.
n = length(x);
sumx = sum(x);
sumy = sum(y);
Sxx = sum(x.^2) - sumx.^2/n;
Sxy = sum(x.*y) - sumx*sumy/n;
if (Sxx == 0), m = 0;
else m = Sxy / Sxx;
end
b = sumy/n - m*sumx/n;

% Calculate y1.
if (nargin >= 3), y1 = m * x1 + b; end
