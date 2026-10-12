function     [v,a]=vertical(p,fs,fc,nf)
%
%     [v,a]=vertical(p,fs,fc,nf)
%     Estimate the vertical velocity and acceleration from the depth time
%     series.
%     p is the depth time series in meters, sampled at fs Hz.
%     fc is the smoothing filter cut-off frequency in Hz. Default value is
%     0.2 Hz (5 second time constant).
%
%     v is the vertical velocity in m/s
%     a is the vertical acceleration in m^2/s
%     v and a have the same size as p.
%
%     mark johnson, WHOI
%     mjohnson@whoi.edu
%     November 2003

if nargin<2,
   help('vertical') ;
   return
end

if nargin==2,
   fc = 0.2 ;
end

if nargin<4,
   nf = round(4*fs/fc) ;
end

v = fir_nodelay([p(2)-p(1);diff(p)]*fs,nf,fc/(fs/2)) ;

if nargout==2,
   a = fir_nodelay([0;diff(p,2);0]*fs.^2,nf,fc/(fs/2)) ;
end
