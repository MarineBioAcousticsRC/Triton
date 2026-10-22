function    Y = rmsenv(X,n,nov)
%
%    H = rmsenv(X,n,nov)
%

if nargin<3,
   nov = 0 ;
end

S = abs(hilbert(X)).^2 ;      % square envelope
ss = buffer(S(:,1),n,nov,'nodelay') ;
Y = zeros(size(ss,2),size(X,2)) ;
Y(:,1) = sum(ss)' ;
for k=2:size(X,2),
   ss = buffer(S(:,k),n,nov,'nodelay') ;
   Y(:,k) = sum(ss)' ;
end

Y = sqrt(Y/n) ;
