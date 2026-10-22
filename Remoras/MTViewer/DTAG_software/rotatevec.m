function      V = rotatevec(V,Q)
%
%      V = rotatevec(V,Q)
%
%	    Rotate tri-axial field measurements from one frame to another.
%      T is the time-varying direction cosine (3x3xn) relating the second 
%      frame to the first. 
%
%      V is a sequence of accelerometer or magnetometer observations in a
%      nx3 matrix.
%
%      Returns nx3 matrix V in the new frame.
%
%      mark johnson, WHOI
%      majohnson@whoi.edu
%      last modified: 1 June 2011

if nargin<2,
   help rotatevec ;
   return
end

for k=1:size(V,1),
   V(k,:) = V(k,:)*Q(:,:,k)' ;
end
