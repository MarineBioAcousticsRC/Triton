function	    [h,f] = sensitivity_tag1(g,filt,postemph)
%
%  DTAG V1.1 support scripts
%
% 	[h,f] = sensitivity_tag1(g,filt,[postemph])
%
%	Models the gain and frequency response of the DTAG-1 programmable 
%  front-end circuit for a given set of gain and filter numbers.
%  g is the programmed gain, an integer between 0 and 255.
%  filt is the programmed filter settings, a 4-element integer vector 
%    with each element between 0 and 255. The values used for g and 
%    filt can be found on the post-tagging data sheets for each tag 
%    deployment.
%  postemph is an optional argument stating that the high-pass filter post-
%    emphasis function (postemph.m) is to be included in the tag response.
%    If postemph=1, the correction filter will be included and the results
%    will represent the output of postemph. If postemph is not 1 or is
%    absent, the results will be for the raw audio data, i.e., the output
%    of tagwavread.
%    
%  The magnitude response of the tag is returned in h in dB re V per uPa 
%  at frequencies specified in f (in Hz). The frequencies are logarithmically
%  spaced from 50Hz to 40kHz. The values in h take into account:
%  1. hydrophone sensitivity (using a nominal value of -165dB re V/uPa - refer to 
%     the assembly data sheet of each tag to get the exact value and add
%     the difference to h for a precise sensitivity).
%  2. hydrophone high-pass filter at 400Hz.
%  3. tag preamp input amplifier high-pass filter and gain
%  4. tag programmable filter (2 biquads)
%  5. ADC conversion gain
%  6. wavread (and hence tagwavread) scaling in Matlab
%  7. optionally, a post-emphasis step performed in Matlab
%
%  example:  [h,f]=sensitivity_tag1(120,[40 40 43 43]) ;
%            % results apply to signals accessed using:
%            [x,fs] = tagwavread(tag,fbase,cue,secs) ;
%
%  or:       [h,f]=sensitivity_tag1(120,[40 40 43 43],1) ;
%            % results apply to signals accessed using:
%            [x,fs] = tagwavread(tag,fbase,cue,secs) ;
%            [y,fs] = postemph(x,fs) ;
%
%  Use:   semilogx(f,h),grid   to view the results.
%
% 	mark johnson, WHOI
%  majohnson@whoi.edu
% 	August 2004, based on pgaf1


if nargin<2,
   help sensitivity_tag1
   return
end

hpsens = -165 ;   % hydrophone sensitivity in dB re uPa
hphpf = 400 ;     % hydrophone high-pass filter -3dB frequency
Rin = 100e3 ;		% input resistor
Cin = 47e-9 ;		% input capacitor
R = 100e6 ;		   % parallel resistor in PGA (was 2.2e3)
C1 = 2.2e-9 ; %10e-9 ;		% filter capacitor values
C2 = 1.8e-9 ; %8.2e-9 ;
C3 = 4.7e-9 ; %22e-9 ;
C4 = 0.68e-9 ; %3.3e-9 ;

rgain = 50e3 ;		% AD8400 resistance
rfilt = 50e3 ;		% AD8403 resistance, was 10e3

gout = 1.62 ;

% test frequencies from flow to fhigh

flow = 50 ;
fhigh = 40e3 ;

g = g/256 ;
f = logspace(log10(flow),log10(fhigh),200)' ;
w = 2*pi*f ;
Hhp = abs(freqs([1 0],[1 2*pi*hphpf],w)) ;
Hinp = abs(freqs([1 0],[1 1/(Cin*Rin)],w)) ;
gain = (R+rgain*g.*(1-g)).*(R*(1-g)).^(-1) ;

r = filt/256*rfilt+100 ;
w1 = 1/sqrt(C1*C2*r(1)*r(2)) ;
f1 = w1/2/pi ;
q1 = sqrt(C1/C2*r(1)*r(2)/(r(1)+r(2))^2) ;
Hbq1 = abs(freqs([0 0 w1^2],[1 w1/q1 w1^2],w)) ;
w2 = 1/sqrt(C3*C4*r(3)*r(4)) ;
f2 = w2/2/pi ;

q2 = sqrt(C3/C4*r(3)*r(4)/(r(3)+r(4))^2) ;
Hbq2 = abs(freqs([0 0 w2^2],[1 w2/q2 w2^2],w)) ;

if nargin<3,
   postemph = 0 ;
end

if postemph==1,
   Hpost = abs(freqs([1 2*pi*400],[1 2*pi*40],w)) ;
else
   Hpost = 1 ;
end

h = 20*log10(gout*gain*Hhp.*Hinp.*Hbq1.*Hbq2.*Hpost)+hpsens ;
