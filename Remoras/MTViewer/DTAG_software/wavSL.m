function    [SL,f] = wavSL(fname,cues,nfft,len)
%
%    [SL,f] = wavSL(fname,cues,nfft,len)
%

if nargin<2 | isempty(cues),
   cues = [0 Inf] ;
end

if nargin<3,
   nfft = 1024 ;
end

if nargin<4,
   len = 10 ;
end

cue = cues(1) ;
endcue = cues(2) ;
nov = nfft/2 ;

% get the sampling frequency
[sz fs] = wavread16(fname,'size') ;
endcue = min(endcue,sz(1)/fs(1)) ;
N = floor((endcue-cue)/len) ;

P = zeros(nfft/2,N) ;
w = hanning(nfft) ;

for k=1:N,
   fprintf('Reading at cue %d\n', cue) ;
   x = wavread16(fname,floor([fs*cue+1 fs*(cue+len)])) ;
   if size(x,2)>1,
      x = x(:,1) ;
   end
   if length(x)<=nfft,
      P = P(:,1:k-1) ;
      break
   end
   cue = cue+len ;
   [x,z] = buffer(x,nfft,nov,'nodelay') ;
   x = detrend(x).*repmat(w,1,size(x,2)) ;
   f = abs(fft(x)).^2 ;
   P(:,k) = sum(f(1:nfft/2,:),2)/size(x,2) ;
end

P = P/(nfft^2) ;
slc = 3-10*log10(fs/nfft)-10*log10(sum(w.^2)/nfft) ;
SL = 10*log10(P)+slc ;
f = (0:nfft/2-1)/nfft*fs ;
return

