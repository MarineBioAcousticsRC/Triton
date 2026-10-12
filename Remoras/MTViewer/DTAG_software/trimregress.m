function    [fit,fitci,stats,residuals] = trimregress(x,y,n)
%
%    [fit,fitci,stats,residuals] = trimregress(x,y,n)
%     Trim the n extreme points from the top and bottom of
%     each of vectors x and y and then perform linear regression
%     of x on to y.
%     Return the coefficients, their confidence intervals and
%     stats = [r^2,F,p,df]
%

if nargin<2,
   help trimregress
   return
end

D = [x,y] ;
if nargin==3 & n>0,
   D = trimoutliers(D,n) ;
end

k = find(~isnan(D(:,1)+D(:,2))) ;
[fit,fitci,r,rint,stats] = regress(D(k,2),[ones(length(k),1),D(k,1)]) ;
stats(end+1) = length(k)-2 ;
residuals = [D(k,1),D(k,2),r] ;
