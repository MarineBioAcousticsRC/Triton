function    [H,f,b,a] = cs5341(N,Hmin)
%
%  [H,f,b,a] = cs5341(N,[Hmin])
%  Model the frequency response of the CS5341 ADC in high
%  speed ('quad') mode evaluated at N points between 0 
%  and fs (192kHz).
%  Optional argument Hmin sets the minimum attenuation level
%  for the ADC in dB. Use this to prevent ringing in the 
%  calculated post-emphasis filter.
%
%  Outputs:
%  H is the response in dB re V
%  f is the corresponding frequency in Hz.
%  b and a are the coefficients of an IIR post-emphasis filter
%  that can be used to correct for the ADC response with a
%  resulting error of +/- 1dB upto 80kHz.
%  To post-emphasise audio data, use:
%     y = filter(b,a,x) ;
%
%  mark johnson, WHOI
%  last modified: 30 October, 2005

if nargin==0,
   help cs5341
   return
end

fs = 192e3 ;
if nargin<2,
   hmin = 0 ;
else
   hmin = 10^(Hmin/20) ;
end

FR = [0 0
   0.25 0
   0.3 -0.9
   0.35 -2.9
   0.375 -4.9
   0.4 -7.1
   0.425 -10.5
   0.45 -16
   0.475 -24
   0.5 -60
   ] ;

% ADC response is <-25dB at f>96kHz

h = (10.^(FR(:,2)/20)+hmin)/(1+hmin) ;
fo = (1:N/2)'/N ;
H = 20*log10(interp1(FR(:,1),h,fo)) ;
f = fo*fs ;

% design a postemphasis filter
w = 2*pi*80e3 ; Q = 2.5 ;
[b a] = bilinear(w^2,[1 w/Q w^2],fs,w/2/pi) ;
