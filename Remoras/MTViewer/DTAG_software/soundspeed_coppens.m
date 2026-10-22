function    v = soundspeed_coppens(T,D,S)
%
%    v = soundspeed_coppens(T,D,[S])
%        T = temperature in degrees C
%        D = depth in meters
%        S = salinity in part-per-thousand (defaults to 35)
%        v is sound speed in m/s
%
%    Sound speed estimate using Coppens equation
%    Range of validity: temperature 0 to 35 °C, salinity 0 to 45 parts per
%    thousand, depth 0 to 4000 m
%    Source:
%     http://resource.npl.co.uk/acoustics/techguides/soundseawater/content.
%     html#UNESCO
%
%    April 2012

v = [] ;
if nargin==0,
   help soundspeed_coppens
   return
end

if nargin==2,
   S = 35 ;     % ppt
end

t = T/10 ; D = D/1000 ;
v0 = 1449.05 + 45.7*t - 5.21*t.^2 + 0.23*t.^3 + (1.333 - 0.126*t + 0.009*t.^2).*(S - 35) ;
v = v0 + (16.23 + 0.253*t).*D + (0.213-0.1*t).*D.^2 + (0.016 + 0.0002*(S-35)).*(S - 35).*t.*D ;
