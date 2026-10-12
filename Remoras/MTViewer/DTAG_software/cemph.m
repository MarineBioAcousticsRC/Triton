function     [y,fs,b,a] = cemph(x,fs,noresamp)

%    [y,fs,b,a] = cemph(x,fs)
%    Implement the NMFS Cetacean weighting filter for mid-frequency odontocetes ('mo').
%    x is the audio signal to be weighted (use tag2wavread to access
%      the raw audio and postemph to correct for tag response). Stereo or mono data can be used.
%    fs is the sampling rate in Hz (again, this can be derived from tag2wavread).
%    noresamp is an optional argument that prevents down-sampling of x (see
%      below). Use noresamp=1 to disable down-sampling. Default is to allow
%      down-sampling.
%
%    y is the emphasised audio signal. If fs<96kHz, y will have the same
%      sampling-rate as x. If fs >= 96kHz, x will be decimated by 2 or 4
%      as appropriate to yield an output sampling rate no greater than
%      48kHz. This is done to prevent numerical problems that can arise
%      with a high ratio of sampling-rate to filter cut-off frequency.
%    fs is the output sampling rate in Hz.
%
%    mark johnson, WHOI
%    majohnson@whoi.edu
%    last modified: November 2004

if nargin<3,
   noresamp = 0 ;
end

if fs>=96e3 & noresamp~=1,
   df = round(fs/48e3) ;
   fs = fs/df ;
   if ~isempty(x),
      x = decdc(x,df) ;
   end
end

% Gweight filter (presumed perceptual weighting for odontocetes) is
% essentially a 2-pole high pass filter with a cut-off frequency of
% 150 Hz and a Q of 1.

fp = 150 ;          % values come from an empirical fit to Gweight
Q = 1 ;
[b a] = bilinear([1 0 0],[1 2*2*pi*fp/Q (2*pi*fp)^2],fs,200) ;

if isempty(x),
   y = [] ;
   return ;
end

[y zi] = filter(b,a,x(20:-1:1,:)) ;       % prime filter states
y = filter(b,a,x,zi) ;
