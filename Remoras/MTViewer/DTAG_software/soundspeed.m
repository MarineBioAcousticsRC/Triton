function    v = soundspeed(T,D,S)
%
%    v = soundspeed(T,D,[S])
%        T = temperature in degrees C
%        D = depth in meters
%        S = salinity in part-per-thousand (defaults to 35)
%        v is sound speed in m/s
%
%    mark johnson, WHOI
%    from RDI manual 951-6069-00
%    October 2001

v = [] ;
if nargin==0,
   help soundspeed
   return
end

if nargin==2,
   S = 35 ;     % ppt
end

v = 1449.2+4.6*T-0.055*T.^2+0.00029*T.^3+(1.34-0.01*T).*(S-35)+0.016*D ;
