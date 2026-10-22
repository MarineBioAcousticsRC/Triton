function    [p,SL,f,n] = wavpsd(fname,cues,nfft,h)
%
%    [p,SL,f,n] = wavpsd(fname,cues,nfft)
%

if nargin<1,
   help wavpsd
   return
end

if nargin<2 | isempty(cues),
   cues = [0 Inf] ;
end

if nargin<3,
   nfft = 1024 ;
end

if nargin<4,
   h = [] ;
end

cue = cues(1) ;
endcue = cues(2) ;
LEN = 10 ;
nov = nfft/2 ;

% get the sampling frequency
[sz fs] = wavread(fname,'size') ;
endcue = min(endcue,sz(1)/fs(1)) ;

p = zeros(nfft/2,1) ;
w = hanning(nfft) ;
n = 0 ;

while cue<endcue,
   fprintf('Reading at cue %d\n', cue) ;
   len = min([LEN,endcue-cue]) ;
   if len*fs<=nfft,
      break
   end
   x = wavread(fname,floor([fs*cue+1 fs*(cue+len)])) ;
   if size(x,2)>1,
      x = x(:,1) ;
   end
   cue = cue+len ;

   if ~isempty(h),
      x = filter(h,1,x) ;
   end
   [x,z] = buffer(x,nfft,nov,'nodelay') ;
   x = detrend(x).*repmat(w,1,size(x,2)) ;
   f = abs(fft(x)).^2 ;
   p = p+sum(f(1:nfft/2,:),2) ;
   n = n+size(x,2) ;
end

% these two lines give correct output for randn input
% SL of randn should be -10*log10(fs/2)

slc = 3-10*log10(fs/nfft)-10*log10(sum(w.^2)/nfft) ;
SL = 10*log10(p)-10*log10(n)-20*log10(nfft)+slc ;
f = (0:nfft/2-1)/nfft*fs ;
p = p/(n*nfft^2) ;

return

