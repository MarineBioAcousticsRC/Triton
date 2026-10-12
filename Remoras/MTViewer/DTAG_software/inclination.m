function    incl = inclination(A,M)
%
%    incl = inclination(A,M,COORDS)
%     Estimates the magnetic field vector inclination angle
%     from the whale or tag frame A and M.
%     incl is in degrees with +ve meaning an angle below the horizontal.
%     A left-hand coordinate system (north,east,up) is assumed.

fldang = real(acos(A.*M*[1;1;1]./norm2(M))) ;
incl = 180/pi*(fldang-pi/2) ;
