function    [SL,f] = tagwavSL(tag,cues,nfft,len,freqr,plim)
%
%    [SL,f] = tagwavSL(tag,cues,nfft,len,freqr,plim)
%     Compute the SL in blocks of len seconds from tag audio.
%     If freqr and plim are specified, calculate the spectral
%     power between freqr(1) and freqr(2) Hz for each nfft-length 
%     interval within each len block. Select the largest (or
%     smallest if plim is negative) plim percent of spectra according
%     to the power in this band. Mean the power in this subset of
%     spectra.
%     If freqr and plim are not given, just average the power spectra
%     over each len block.
%
%     mark johnson
%     7 feb 2013

SL = [] ; f = [] ;
if nargin<2,
   help tagwavSL ;
   return
end

if nargin<3 || isempty(nfft),
   nfft = 1024 ;
end

if nargin<4 || isempty(len),
   len = 10 ;
end

if nargin<6,
   plim = [] ;
end

cue = cues(1) ;
endcue = cues(2) ;
nov = nfft/2 ;

% get the sampling frequency
[x,fs] = tagwavread(tag,cue,0.1) ;
N = floor((endcue-cue)/len) ;

P = zeros(nfft/2,N) ;
w = hanning(nfft) ;
f = (0:nfft/2-1)/nfft*fs ;
if nargin>=5 & ~isempty(freqr),
   kf = find(f>=freqr(1) & f<freqr(2)) ;
else
   kf = 1:length(f) ;
end

for k=1:N,
   fprintf('Reading at cue %d\n', cue) ;
   x = tagwavread(tag,cue,len) ;
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
   ff = abs(fft(x)).^2 ;
   if ~isempty(plim),
      p = sum(ff(kf,:)) ;
      if plim<0,
         thr = prctile(p,-plim) ;
         kp = find(p<thr) ;
      else
         thr = prctile(p,100-plim) ;
         kp = find(p>thr) ;
      end
      P(:,k) = sum(ff(1:nfft/2,kp),2)/length(kp) ;      
   else
      P(:,k) = sum(ff(1:nfft/2,:),2)/size(x,2) ;
   end
end

P = P/(nfft^2) ;
slc = 3-10*log10(fs/nfft)-10*log10(sum(w.^2)/nfft) ;
SL = 10*log10(P)+slc ;
return

