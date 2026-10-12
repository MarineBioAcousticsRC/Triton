function    W = bodyaxes(A,M,I)

%   W = bodyaxes(A,M,[I])
%   EXPERIMENTAL - SUBJECT TO CHANGE!!
%   Generate an approximate orthonormal basis from A and M at each time step by:
%   (i)   normalizing A and M to unit length
%   (ii)  rotating the magnetometer measurement to the horizontal plane (Mh), 
%   (iii) computing the cross-product of A and Mh to generate the missing sensor
%         basis vector, 
%   (iv)  transposing [Mh,N,A] to form the body axis basis.
%   Inputs:
%     A is the accelerometer measurement matrix 
%     M is the magnetometer measurement matrix
%     I is the magnetic field inclination angle for the measurement location
%     in radians. If not specified, a value is deduced from A and M.
%
%   returns:
%     W is the 3x3xn matrix of body axes bases. W(:,1,:) are the X or caudal-rostral
%     axes. W(:,2,:) are the Y or transverse (left-right) axes. W(:,3,:) are the Z 
%     or ventral-dorsal axes. [X,Y,Z] = [Mh,N,A]'.
%
%     To extract individual axes from W use e.g.:
%     X = squeeze(W(:,1,:))' ;
%
%   markjohnson@st-andrews.ac.uk
%   last updated: July 2014

if nargin<2,
   help bodyaxes
   return
end

b = sqrt(M.^2*[1;1;1]) ;
g = sqrt(A.^2*[1;1;1]) ;
M = M./(b*[1 1 1]) ;
A = A./(g*[1 1 1]) ;

if nargin<3,
   %I = acos(mean((A.*M)*[1;1;1]))-pi/2 ;
   I = acos((A.*M)*[1;1;1])-pi/2 ;     % or -sin(A.M)
   %fprintf(' Using magnetic field inclination of %3.1f degree\n',I*180/pi);
else
   if length(I)<size(A,1),
      I = I(1)*ones(size(A,1),1) ;
   end
end

Mh = (M+(sin(I)*[1 1 1]).*A)./(cos(I)*[1 1 1]) ;
v = sqrt(Mh.^2*[1;1;1]) ;
Mh = Mh./(v*[1 1 1]) ;

N = -cross(Mh,A,2) ;       % for left-hand axes

W = zeros(3,3,size(A,1)) ;
W(1,:,:) = Mh' ;
W(2,:,:) = N' ;
W(3,:,:) = A' ;
