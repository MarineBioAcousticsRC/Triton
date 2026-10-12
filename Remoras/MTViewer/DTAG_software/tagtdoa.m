function       [toffs,q,D] = tagtdoa(tag1,tag2,D,sigintvl,filt,srchintvl)
%
%    [toffs,q,D] = tagtdoa(tag1,tag2,D,sigintvl,filt,srchintvl)
%    Wideband time-difference-of-arrival estimator for pairs of tags
%    using the generalized cross-correlation.
%    cmin  the delay time in samples between each column of X and Y
%    q     the fit quality (1=perfect, 0=rotten)
%
%    mark johnson, WHOI
%    November, 2008

cmin = [] ; q = [] ;

if nargin<4,
   help tagtdoa
   return
end

if nargin<5 | isempty(filt),
   filt = [5e3 30e3] ;
end

if nargin<6,
   srchintvl = [] ; 
end

[x1,afs] = lookupcues(tag1,D(:,1),sigintvl,filt) ;
x2 = lookupcues(tag2,D(:,1)+D(:,2),sigintvl,filt) ;

if size(x1,3)>1,
   x1 = squeeze(x1(:,CH,:)) ;
end

if size(x2,3)>1,
   x2 = squeeze(x2(:,CH,:)) ;
end

X = hilbert(x1) ;
Y = hilbert(x2) ;
rx = sum(conj(X).*X)' ;
ry = sum(conj(Y).*Y)' ;

if isempty(srchintvl),
   MAX = size(X,1)-1 ;
else
   MAX = min(round(afs*srchintvl),size(X,1)-1) ;
end

z = zeros(2*MAX+1,size(X,2)) ;

for k=1:size(X,2),
   z(:,k) = real(xcorr(Y(:,k),X(:,k),MAX)) ;
end

[m n] = max(z) ;
k = find(n==1) ;
n(k) = n(k)+1 ;
k = find(n==size(z,1)) ;
n(k) = n(k)-1 ;

p = zeros(size(X,2),3) ;
for k=1:size(X,2),
   p(k,:) = z(n(k)+(-1:1),k)' ;
end

xm = 0.5*(p(:,1)-p(:,3))./(p(:,3)-2*p(:,2)+p(:,1)) ;
ym = p(:,2)+(p(:,3)-p(:,1)).*xm/4 ;
toffs = real(n'-MAX-1+xm)/afs ;

q = ym./sqrt(rx.*ry) ;
D(:,2)=D(:,2)+toffs ;
