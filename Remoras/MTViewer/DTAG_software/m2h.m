function     [h,v,incl] = m2h(M,p,r)
%
%     [h,v,incl] = m2h(M,pitch,roll)
%
%     Compute heading, field intensity and inclination angle by gimballing 
%     the magnetic field measurement matrix with the pitch and roll signals.
%     M is the magnetometer signal matrix, M=[mx,my,mz] in uT (microtesla). 
%        M can be in tag or whale frame.
%     pitch is the pitch estimate in radians in the same frame as M. 
%     roll is the roll estimate in radians in the same frame as M.
%     M, p and r must all have the same number of rows. Use a2pr.m to
%     generate pitch and roll.
%
%     h is the heading in radians in the same frame as M. The heading is 
%        with respect to magnetic north and so must be corrected for declination.
%     v is the field intensity estimate in uT.
%     incl is the field inclination angle in radians.
%
%     Output sampling rate is the same as the input sampling rate.
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     Last modified: 25 November 2005

if nargin<3,
   help m2h
   return
end

if size(M,1)*size(M,2)==3,
   M = M(:)' ;
end

if size(M,1)~=size(p,1) | size(M,1)~=size(r,1),
   fprintf('m2h: M, p and r must have same number of rows\n') ;
   return
end

% slow way to do the gimballing:
% Mh = zeros(size(M,1),size(M,2)) ;
% for k=1:size(M,1),
%   T = makeT(p(k),r(k),0) ;   % transformation to horizontal frame
%   Mh(k,:) = M(k,:)*T' ;       % gimbal each M vector
% end
   
% equivalent but faster way:
cp = cos(p) ;
sp = sin(p) ;
cr = cos(r) ;
sr = sin(r) ;
Tx = [cp -sr.*sp -cr.*sp] ;
Ty = [zeros(length(cp),1) cr -sr] ;
Tz = [sp sr.*cp cr.*cp] ;
Mh = [M.*Tx*[1;1;1] M.*Ty*[1;1;1] M.*Tz*[1;1;1]] ;

% heading estimate in left-hand system
h = atan2(-Mh(:,2),Mh(:,1)) ;

% compute mag field intensity and inclination
v = sqrt(Mh.^2*[1;1;1]) ;         % compute magnetic field intensity
incl = -real(asin(Mh(:,3)./v)) ;  % compute inclination

% Mh(:,3) is sp*Mx+srcp*My+crcp*Mz which is A.M if there is no
% specific acceleration. So the inclination angle computed here is the 
% same as the angle computed directly from A and M by the function 
% inclination.m if there is no specific acceleration. 
% If there is specific acceleration, both methods produce
% inclination angle estimates with errors and the errors are different
% because of the different computational methods.
