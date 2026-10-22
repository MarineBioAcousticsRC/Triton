function    T = makeT(p,r,h)
%
%      T = makeT(p,r,h) or
%      T = makeT([p,r,h])
%      Make a rotation matrix out of Euler angles
%      pitch, roll, and heading. Inputs are in radians.
%      T = H*P*R
%      To rotate a basis, post multiply by T.
%      To transform a vector sensor measurement, pre-multiply by T'.
%
%      mark johnson, WHOI
%      majohnson@whoi.edu
%      Last modified: 5 July 2009
%        - added support for vector arguments

if nargin~=1 & nargin~=3,
   help makeT
   return
end

if nargin==1,
   h = p(:,3) ;
   r = p(:,2) ;
   p = p(:,1) ;
end

n = [length(p) length(r) length(h)] ;
nn = max(n) ;
if n(1)<nn, p = p(1)*ones(nn,1) ; end
if n(2)<nn, r = r(1)*ones(nn,1) ; end
if n(3)<nn, h = h(1)*ones(nn,1) ; end

cp = cos(p) ;
sp = sin(p) ;
cr = cos(r) ;
sr = sin(r) ;
ch = cos(h) ;
sh = sin(h) ;

T = zeros(3,3,nn) ;
for k=1:nn,
   P = [cp(k) 0 -sp(k);0 1 0;sp(k) 0 cp(k)] ;   % there was a bug here until 14apr12
   R = [1 0 0;0 cr(k) -sr(k);0 sr(k) cr(k)] ;
   H = [ch(k) -sh(k) 0;sh(k) ch(k) 0;0 0 1] ;
   T(:,:,k) = H*P*R ;
end

T = squeeze(T) ;
