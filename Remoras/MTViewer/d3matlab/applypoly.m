function    y = applypoly(x,p,fsin,fsout)
%    y = applypoly(x,p,fsin,fsout)
%
%

y = polyval(p,x) ;
if nargin<4 || fsin==fsout,
   return 
end

tin = (0:length(x)-1)'/fsin ;
tout = (0:floor(length(x)*fsout/fsin)-1)'/fsout ;
y = interp1(tin,y,tout) ;
