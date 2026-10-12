function    [T,pe,S]=ptrack(pitch,head,p,fs,LPF,s)
%
%    T=ptrack(pitch,head,p,fs,LPF,s)
%    Simple pseudo-track computation (dead-reckoning).
%    If p is specified, a Kalman filter is used to estimate the swim
%    speed and then the track is generated from this and the pitch and
%    heading. If p is a scalar, it is taken as a constant speed value
%    which is used instead of the Kalman speed estimate. 
%    fs is the sampling rate of the sensor data in Hz.
%    LPF specifies an optional low-pass filter cut-off frequency in Hz.
%    Default is no track filtering.
%    Optional argument s allows time-varying speed to be specified as a vector.
%
%    Returns T=[tN tE] or [tN tE depth] if p is given, the horizontal 
%    and vertical positions on the track at the same sampling moments as 
%    in the input data.
%
%    Caution: the resulting pseudo-track is not reliable. Speed estimation
%    from pitch and depth data is unproven and no allowance is made for
%    currents. Use at your own risk!
%
%    markjohnson@st-andrews.ac.uk
%    Last modified: Feb 2014

if nargin<4,
   help ptrack
   return
end

if nargin<5,
   LPF = [] ;
end

if nargin<6,
   if length(p)==length(pitch),
      s = kalmanspeedest(p,pitch,fs) ;
   else
      s = p(1) ;
   end
end

T = cumsum((((s/fs).*cos(pitch))*[1 1]).*[cos(head) sin(head)]) ;

if length(p)==length(pitch),
   T = [T p] ;
end

if nargout>=2,
   pe = -cumsum((s/fs).*sin(pitch)) ;
end

if nargout==3,
   S = s ;
end

if ~isempty(LPF),
   [b a] = butter(3,LPF/(fs/2)) ;
   T = filtfilt(b,a,T) ;
   if exist('S','var'),
      S = filtfilt(b,a,S) ;
      k = find(S<0) ;
      S(k) = 0 ;
   end
end
