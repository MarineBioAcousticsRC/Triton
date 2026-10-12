function	[h,f] = sensitivity_tag2(sens,postemph)
%
% 	[h,f] = sensitivity_tag2(sens,[postemph])
%
%	Returns the gain and frequency response of the audio recording made by
%  a tag2.
%  sens is the tag sensitivity as reported by taginfo.m. If no sensitivity
%    info is reported, use the value -203+g where g is the gain specified on
%    the post-tag data sheet for the tag deployment. sens is in
%    dB re V/uPa.
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
%  1. hydrophone sensitivity.
%  2. hydrophone high-pass filter at 400Hz.
%  3. tag preamp input amplifier gain.
%  4. ADC conversion gain.
%  5. wavread (and hence tag2wavread) scaling in Matlab.
%  6. optionally, post-emphasis in Matlab.
%
%  Notes:
%  (i) the anti-alias filter in the ADC is not included in the
%  response. Refer to the data-sheet for the CS5333 or CS5341 ADC for
%  details of the anti-alias response as a function of sampling-rate.
%  See also the MATLAB function cs5341.
%  (ii) h is the sensitivity in V/uPa - to work backwards from signal levels
%  in MATLAB, subtract the values in h, e.g., if h is -192 at 1kHz and you 
%  have a -20dB 1kHz component in a wav file, the in-water level was 
%  -20-(-192) = 172dB re uPa.
%
%  example:  [h,f]=sensitivity_tag2(-171) ;
%            % results apply to signals accessed using:
%            [x,fs] = tagwavread(tag,cue,secs) ;
%
%  or:       [h,f]=sensitivity_tag2(-193,1) ;
%            % results apply to signals accessed using:
%            [x,fs] = tagwavread(tag,cue,secs) ;
%            [y,fs] = postemph(x,fs) ;
%
%  Use:   semilogx(f,h),grid   to view the results.
%
% 	mark johnson, WHOI
% 	majohnson@whoi.edu
%  last modified: 12 May 2006

if nargin<1,
   help sensitivity_tag2
   return
end

if isempty(sens),
   sens = -205+10 ;   % nominal hydrophone and preamp sensitivity in dB re uPa
end

hphpf = 500 ;         % hydrophone high-pass filter -3dB frequency

% test frequencies from flow to fhigh

flow = 50 ;
fhigh = 40e3 ;

f = logspace(log10(flow),log10(fhigh),200)' ;
w = 2*pi*f ;
Hhp = abs(freqs([1 0],[1 2*pi*hphpf],w)) ;

if nargin<3,
   postemph = 0 ;
end

if postemph==1,
   Hpost = abs(freqs([1 2*pi*400],[1 2*pi*40],w)) ;
else
   Hpost = 1 ;
end

h = 20*log10(Hhp.*Hpost)+sens ;
