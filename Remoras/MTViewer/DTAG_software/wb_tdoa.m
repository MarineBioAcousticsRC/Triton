function       [cmin,q,z,c] = wb_tdoa(X,Y)
%
%    [cmin,q,z,c] = wb_tdoa(X,Y)
%    Wideband time-difference-of-arrival estimator for stereo data.
%    X and Y are matrices of observed signals. Each column
%    is a distinct signal. X and Y are the signals from the
%    1st and 2nd channel, respectively, of a two-hydrophone array.
%    returns:
%    cmin  the delay time in samples
%    q     the fit quality (0=perfect, 1=rotten)
%    z     the matrix of mean-square-errors. z has a column for
%          each signal in X and a row for each time delay tested.
%    c     the vector of test time delays in samples
%
%    mark johnson, WHOI
%    November, 2004

cmin = [] ; q = [] ; z = [] ; c = [] ;

if nargin<2,
   help wb_tdoa
   return
end

STEP = 0.1 ;
MAX = 3 ;
k = (-30:30)' ;
c = (-MAX:STEP:MAX)' ;
s = k*ones(1,length(c))+ones(length(k),1)*c' ;
T = sinc(s) ;

X = [X;zeros(length(k)-1,size(X,2))] ;
Y = [Y;zeros(length(k)-1,size(X,2))] ;
R = filter(sinc(k),1,X) ;
z = zeros(length(c),size(X,2)) ;

for k=1:length(c),
   Z = filter(T(:,k),1,Y) ;
   z(k,:) = sum(abs(Z-R).^2) ;
end

[m n] = min(z) ;
q = (m./sum(abs(R).^2))' ;
k = find(n==1) ;
n(k) = n(k)+1 ;
k = find(n==length(c)) ;
n(k) = n(k)-1 ;

p = zeros(size(X,2),3) ;
for k=1:size(X,2),
   p(k,:) = z(n(k)+(-1:1),k)' ;
end

cmin = real(c(n) + 0.5*STEP*(p(:,1)-p(:,3))./(p(:,1)-2*p(:,2)+p(:,3))) ;
