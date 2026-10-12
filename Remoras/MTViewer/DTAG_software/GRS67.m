function    g = GRS67(latitude)
%
%    g = GRS67(latitude)
%     Earth's gravitational field at the surface
%

g = 9.78031846.*(1 + 0.005278895*sin(latitude).^2 + 0.000023462*sin(latitude)^4) ;
