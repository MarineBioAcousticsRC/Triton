function      [y,Z] = decz(x,Z)
%
%      [y,Z] = decz(x,Z)
%     Recursive version of decdc.
%     Initial call is [y,z] = decz(x,df)
%     Subsequent calls are [y,z] = decz(x,z)
%     Final call is y = decz([],z)
%     Initial call can also be [y,z] = decz(x,[df,nf,frbw])
%     where df is the decimation factor
%     nf is the number of output samples spanned by the filter
%     frbw is the fractional bandwidth of the filter
%     defaults are nf=12, frbw=0.8
%
%     modifed for multichannel operation
%     mj 27 june 2012

if ~isstruct(Z),
   frbw = 0.8 ;
   nf = 12 ;
   if length(Z)>=2,
      nf = Z(2) ;
      if length(Z)>=3,
         frbw = Z(3) ;
      end
   end

   df = Z(1) ;
   Z = struct('df',df) ;
   Z.h = fir1(df*nf,frbw/df) ;
   nh = length(Z.h) ;
   Z.n = nh ;
   npre = floor(nh*0.5) ;
   Z.z = [2*x(1,:)-x(1+(nh-df-npre:-1:1),:);x(1:npre,:)] ;
   x = x(npre+1:end,:) ;
end

nh = Z.n ;
df = Z.df ;
if isempty(x),
   % reuse the last few inputs to squeeze some more output
   % from the filter.
   x = 2*Z.z(1,:)-flipud(Z.z(2:ceil(nh/2),:)) ;
end

for k=1:size(x,2),
   [X,zz,z] = buffer(x(:,k),nh,nh-df,Z.z(:,k)) ;
   if k==1,
      y = zeros(size(X,2),size(x,2)) ;
   end
   y(:,k) = (Z.h*X)' ;
   Z.z(:,k) = z ;
end
return

