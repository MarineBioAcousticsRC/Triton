function    [H,f,ir] = absorptiontaper(N,fs,d,amin,amax)

%    [H,f,ir] = absorptiontaper(N,fs,d,amin,amax)
%     Estimate the frequency response of a filter that matches
%     the absorpion of the ocean over d meters.
%     e.g., [H,f]=absorptiontaper(1024,96e3,1500,-1,-15);
%     N is the number of frequencies to use in the freq. response.
%     fs is the sampling rate, Hz
%     d is the distance in m
%     amin and amax are the minimum and maximum attenuations to
%     avoid numerical problems if inverting the absorption.
%     The depth and temperature are set to 450 m and 12.3 degrees C
%     but can be changed in the script.
%
%     Returns:
%     H is the sampled frequency response (linear) at N frequencies 
%     around the unit circle.
%     f is the vector of frequencies
%     ir is the impulse response of a causal symmetric FIR filter that 
%     can be used to simulate the absorption.
%
%     mark johnson

T = 12.3 ;        % ocean temperature at which to calculate absorption, deg C
D = 450 ;         % water depth at which to calculate absorption, m
p = 8 ;           % power law to use in pinching the attenuation curves
nf = 64 ;         % filter length

if nargin<4 | isempty(amin),
   amin = 100 ;
end

f = (0:N-1)'/N*fs ;
a = absorption(f(1:N/2+1),T,D) ;           % absorption in dB/m
h = 10.^(-a*d/20) ;                        % total absorption as a pressure multiplier

if nargin==5 & ~isempty(amax),
   h = (h.^p+10^(p*amax/20)).^(1/p) ;      % pinch off the curve at high attenuations
end

h = (h.^(-p)+10^(-p*amin/20)).^(-1/p) ;    % pinch off the curve at low frequencies
H = [h;h(end-1:-1:2)] ;                    % make symmetric taper
ir = real(ifft(H)) ;
ir = ir([end+(-ceil(nf/2)+1:0) 1:floor(nf/2)]) ;
