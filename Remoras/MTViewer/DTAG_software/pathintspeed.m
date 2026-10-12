function    v = pathintspeed(SStab,p1,p2)
%
%   v = pathintspeed(SStab,p1,p2)
%     SStab = [depth,soundspeed]
%  use negative p1 or p2 for a surface bounce
%

v = [] ;
N = 50 ;         % number of interpolation points to use between p1 and p2

if nargin<3,
   help pathintspeed
   return
end

if length(p1)~=length(p2),
   fprintf(' Error: depth vectors must be the same length\n') ;
   return
end

dmax = max(SStab(:,1)) ;
if min(SStab(:,1))~=0,              % there has to be a zero depth table value
   SStab = [0 SStab(1,2);SStab] ;   % if a negative depth is given (i.e., for an image source)
end

p1 = sign(p1).*min(abs(p1),dmax) ;
p2 = sign(p2).*min(abs(p2),dmax) ;
PP = zeros(N,length(p1)) ;
for k=1:length(p1),
   PP(:,k) = linspace(p1(k),p2(k),N)' ;
end

vi = interp1(SStab(:,1),SStab(:,2),abs(PP(:))) ;
vi = reshape(vi,N,[]) ;
v = 1./mean(1./vi)' ;
