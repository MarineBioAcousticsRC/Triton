function    [xt,nd,outl] = trimoutiers(x,n)
%
%    [xt,nd,outl] = trimoutliers(x,n)
%     Remove the most extreme 2n points from each column
%     of x.
%     xt is the trimmed data set in the same order as x.
%     Trimmed entries are replaced by NaNs
%     nd is the number of rows in xt containing no NaNs.
%     outl is the matrix of data removed from x.
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     27 January, 2007

[nrow ncol] = size(x) ;
if nrow==1,
   x = x(:) ;
   nrow = ncol ; ncol = 1 ;
   swap = 1 ;
end

xt = x ;
outl = [] ;

for k=1:ncol,
   [s,I] = sort(x(:,k)) ;
   kk = find(~isnan(s)) ;
   oind = [1:n length(kk)+(-n+1:0)] ;
   excl = I(kk(oind)) ;
   xt(excl,k) = NaN ;
   outl = [outl;x(excl,:)] ;
end

if ncol>1,
   nd = sum(all(~isnan(xt)')) ;
else
   nd = sum(~isnan(xt)) ;
end

if exist('swap','var'),
   xt = xt(:)' ;
end
