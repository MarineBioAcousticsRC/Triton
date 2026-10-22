function     [y,fs,b,a] = postemph(x,fs,noresamp)
%
%    [y,fs,b,a] = postemph(x,fs,[noresamp])
%    Correct for the 400Hz single-pole high-pass-filter in DTAG
%    version 1 and 2.
%    x is the audio signal to be corrected (use tagwavread to access
%      the raw audio). Stereo or mono data can be used.
%    fs is the sampling rate in Hz (again, this can be derived from tagwavread).
%    noresamp is an optional argument that prevents down-sampling of x (see
%      below). Use noresamp=1 to disable down-sampling. Default is to allow
%      down-sampling.

%    y is the emphasised audio signal. If fs<96kHz, y will have the same
%      sampling-rate as x. If fs >= 96kHz, x will be decimated by 2 or 4
%      as appropriate to yield an output sampling rate no greater than
%      48kHz. This is done to prevent numerical problems that can arise
%      with a high ratio of sampling-rate to filter cut-off frequency.
%      Set noresamp=1 to disable this feature.
%    fs is the output sampling rate in Hz.
%    b and a are the coefficients of the post-emphasis filter used in case
%      these are of interest.
%
%    mark johnson, WHOI
%    majohnson@whoi.edu
%    last modified: November 2004

if nargin<2,
   help postemph ;
   return
end

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

[b a] = bilinear([1 2*pi*400],[1 2*pi*40],fs,400) ;

if isempty(x),
   y = [] ;
   return ;
end

[y zi] = filter(b,a,x(20:-1:1,:)) ;       % prime filter states
y = filter(b,a,x,zi) ;
