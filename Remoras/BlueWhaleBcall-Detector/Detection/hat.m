function y = hat(x)
% y = hat(x)
% The center-surround function
%                       2
%           2          x
%     (1 - x ) exp( - --- )
%                      2
%
% It equals 1 at x=0 and 0 at x=+/-1.
% Its integrated area is 0.
%
% See also gauss.

y = (1 - x .* x) .* exp( - x.*x ./ 2 );
