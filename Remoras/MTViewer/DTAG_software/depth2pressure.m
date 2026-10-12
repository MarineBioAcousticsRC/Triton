function    p = depth2pressure(d,latitude)
%
%    p = depth2pressure(d,latitude)
%     d is depth in m
%     latitude in degrees
%     p is the pressure in Pa
%
%     Based on the Leroy and Parthiot (1998) formula.
%     See:
%     http://resource.npl.co.uk/acoustics/techguides/soundseawater/content.
%     html#UNESCO

thyh0Z = 1e-2*d./(d+100) + 6.2e-6*d ;
g = 9.7803*(1 + 5.3e-3*sin(latitude*pi/180)^2) ;
k = (g - 2e-5*d)./(9.80612 - 2e-5*d) ;
hZ45 = 1.00818e-2*d + 2.465e-8*d.^2 - 1.25e-13*d.^3 + 2.8e-19*d.^4 ;
p = 1e6*(hZ45.*k - thyh0Z) ;
