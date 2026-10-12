function      [A,M] = rotateAM(A,M,prh)
%
%      A = rotateAM(A,prh)
%      or
%      [A,M] = rotateAM(A,M,prh)
%
%	    Rotate tri-axial field measurement(s) from one frame to another.
%      prh=[p0,r0,h0] are the Euler angles in radians of the second frame 
%      relative to the first. 
%      For time varying rotations, prh may be a nx3 matrix where n is the 
%      row dimension of A.
%      prh can also be replaced by a 3x3 rotation (or direction cosine) matrix.
%
%      A is a sequence of accelerometer or magnetometer observations in a
%      nx3 matrix. Two triaxial matrices, A and M, may be specified and 
%      are treated identically.
%
%      Returns nx3 matrices A and M in the new frame.
%
%      mark johnson, WHOI
%      majohnson@whoi.edu
%      last modified: 24 June 2006

if nargin<2,
   help rotateAM ;
   return
end

if nargin==2,
   prh = M ;
   M = [] ;
end

if isempty(A),
   return
elseif size(A,1)*size(A,2)==3,
   A = A(:)' ;
   if ~isempty(M),
      M = M(:)' ;
   end
end

[m n] = size(prh) ;

if m==3 & n==3,
   T = prh ;
elseif size(prh,1)*size(prh,2)==3,
   T = makeT(prh) ;      % transformation tag-to-whale
else
   T = [] ;
end

if ~isempty(T),
   A = A*T' ;            % Aw' = At'*T'

   if ~isempty(M),
      M = M*T' ;
   end

else
   if m~=size(A,1),
      fprintf(' size of prh must match size of A\n') ;
      A = [] ; M = [] ;
      return
   end

   if ~isempty(M) & size(A,1)~=size(M,1),
      fprintf(' size of M must match size of A\n') ;
      A = [] ; M = [] ;
      return
   end

   for k=1:size(A,1),
      T = makeT(prh(k,:)) ;      % transformation tag-to-whale
      A(k,:) = A(k,:)*T' ;
      if ~isempty(M),
         M(k,:) = M(k,:)*T' ;
      end
	end
end
