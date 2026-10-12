function     [p,r,v] = a2pr(A)

%     [p,r,v] = a2pr(A)
%     Pitch and roll estimator for DTAG data. This is a simple
%     non-iterative estimator with |pitch| constrained to <= 90 degrees.
%     The p & r estimates give the least-square-norm error between A and
%     the A-vector that would be measured at the estimated pitch and roll.
%
%     Inputs:
%     A is a nx3 acceleration matrix
%
%     Outputs:
%     p is the pitch estimate in radians
%     r is the roll estimate in radians
%     v is the 2-norm of the acceleration measurements
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     last modified: 24 Nov. 2005

if nargin==0,
   help a2pr
   return
end

if min([size(A,1) size(A,2)])==1,
   A = A(:)' ;
end

v = sqrt(A.^2*[1;1;1]) ;

% compute pitch and roll
p = asin(A(:,1)./v) ;
r = real(atan2(A(:,2),A(:,3))) ;
