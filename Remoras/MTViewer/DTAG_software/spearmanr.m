function    [rho,p,n] = spearmanr(x,y,N)
%
%    [rho,p,n] = spearmanr(x,y,N)
%     Calculate Spearman's rank correlation coefficient
%     for data x and y. Data length must be at least 5.
%     -1<=rho<=1 is the correlation coefficient and is
%     valid for data sets with and without ties.
%     The probability, p, is an approximation based on
%     a Student-t transformation. It is valid for data
%     length > 20.
%     n is the number of non-NaN values in the data.
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     last modified: 1 July 2007
%                    added tie correction

rho = [] ; p = [] ;

if nargin<2,
   help spearmanr
   return
end

if length(x)~=length(y),
   fprintf(' x and y must be of same length\n') ;
   return
end

k = find(~isnan(x) & ~isnan(y)) ;
if length(k)<=4,
   fprintf(' Must be more than 4 valid pairs of data in x and y\n') ;
   return
end

[rx,tiex] = tiedrank(x(k)) ;
[ry,tiey] = tiedrank(y(k)) ;
%if tiex+tiey > length(k)/2,
%   fprintf(' Too many ties - result may be untrustworthy\n') ;
%end

d = rx-ry ;
n = length(k) ;

%Unesco method from http://www.unesco.org/webworld/portal/idams/html/english/e2tables.htm
n3 = n*(n+1)*(n-1)/12 ;
sigx = n3 - tiex/6 ;
sigy = n3 - tiey/6 ;
sigd = sum(d.^2) ;
rho = (sigx+sigy-sigd)/(2*sqrt(sigx*sigy)) ;   % rho with tie correction
%rho = 1 - 6*sum(d.^2)/n/(n^2-1)               % rho without tie correction
df = n-2 ;
t = abs(rho)/sqrt((1-rho^2)/df) ;
p = 1 - tcdf(t,df) ;

if nargin==3 & N>1,
   sigd = zeros(N,1) ;
   for k=1:N,
      kk = randperm(length(ry)) ;
      d = rx-ry(kk) ;
      sigd(k) = sum(d.^2) ;
   end
   r = (sigx+sigy-sigd)/(2*sqrt(sigx*sigy)) ;   % rho with tie correction
   p = sum(r>rho)/N ;
end
