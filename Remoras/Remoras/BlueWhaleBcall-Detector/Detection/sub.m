function y = sub(x,i,j)
% SUB     Subscripting of constants, return values of functions, etc.
%
% y = sub(x,i)
%    Return x(i).  This is occasionally useful when x is a function call, 
%    as MATLAB has no built-in way to subscript the return value of a 
%    function.  For instance, sub(size(x),1) is the number of rows in x.
%    As with any Matlab subscripting, i may be a vector.  i may be logical, 
%    in which case it must be the same length as x.  As a special case, if
%    i is 0, return x(:).  
%
% y = sub(x,i,j)
%    Return x(i,j).  Thus sub(x,0,0) returns x.  i and/or j may be
%    logical, in which case their length must be nRows(x) and nCols(x), 
%    respectively.  As a special case, if i is 0, return x(:,j), and
%    analogously if j is 0.  

if (nargin < 3),
  if (i == 0), y = x(:);
  else y = x(i);
  end
else 
  if (i == 0), i = 1:nRows(x); end
  if (j == 0), j = 1:nCols(x); end
  y = x(i,j);
end
