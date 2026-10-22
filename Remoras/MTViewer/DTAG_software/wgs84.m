function    g = wgs84(latitude)
%
%     g = wgs84(latitude,height)
%     Returns the total acceleration due to gravitation and centripetal
%     force at the earth's surface according to the WGS84 international
%     gravity formula.
%     g is in m/s^2
%
%     Source: http://solid_earth.ou.edu/notes/potential/igf.htm
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     Last modified: 4 December 2005

g = 9.7803267714*(1+0.0019318514*sin(latitude).^2)./sqrt(1-0.00669438*sin(latitude).^2) ;

