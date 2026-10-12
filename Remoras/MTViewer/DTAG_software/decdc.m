function      [y,h] = decdc(x,df,n)
%
%    [y,h] = decdc(x,df,[n])
%    D.C. accurate decimation by a factor of df. Use this instead
%    of decimate(x,df) when d.c. accuracy is important. x may be
%    a matrix, in which case each column is decimated separately.
%    Optional argument n specifies the decimation filter length.
%    Default value is n=12. Actual filter length is 12*df.
%    Optional second output argument h returns the filter coeficients.
%    The decimation filter is a linear phase FIR filter. Group
%    delay of n*df/2 samples is corrected in output y.
%
%    mark johnson, WHOI
%    August, 2001
%    revised Jan 2007 - fixed bug for large column matrices

if nargin<2,
   help decdc ;
   return
end

if nargin<3,
   n = 12 ;
end

flen = n*df ;
h = fir1(flen,0.8/df)' ;
xlen = size(x,1) ;
dc = flen+floor(flen/2)+1+(df:df:xlen) ;
y = zeros(length(dc),size(x,2)) ;

for k=1:size(x,2),
    xx = [2*x(1,k)-x(1+(flen+1:-1:1),k);x(:,k);2*x(xlen,k)-x(xlen-(1:flen+1),k)] ;
    v = conv(h,xx) ;
    y(:,k) = v(dc) ;
end
