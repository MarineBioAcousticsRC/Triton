function    R = clickparams(h,fs,magresp,Nrms)

%     R = clickparams(h,fs,[magresp,Nrms])
%     h is a vector or matrix of the signal(s) of interest with a 
%     signal in each column. If h is real, the hilbert transform is 
%     calculated.
%     fs is the sampling rate in Hz
%     returns structure R containing:
%     R.tr     Woodward time resolution constant, s
%     R.be     Effective bandwidth, Hz
%     R.f0     Centroid frequency, Hz
%     R.t0     Centroid time, s
%     R.beta   rms bandwidth, Hz
%     R.td     rms duration, s
%     R.tb     time bandwidth product
%     R.te     97% energy criteria window length
%     R.fp     peak frequency
%     R.rms    RMS level in the 97% energy window
%     R.bw10   -10 dB bandwidth
%     R.low10  lower -10 dB frequency
%     R.up10   upper -10 dB frequency
%     R.bw3    -3 dB bandwidth
%     R.low3   lower -3 dB frequency
%     R.up3    upper -3 dB frequency
%
%     Optional magresp input is a 512 point vector containing the
%     magnitude response of the ADC and anti-alias filter in dB, e.g., 
%     from cs5341(512,-30). This is used to correct the spectrum of
%     h before calculation of frequency-based parameters. Use [] to
%     force a flat response.
%
%     Optional Nrms is the RMS noise level in a preceding section
%     of audio (e.g., calculated using std(x)) which is used to remove
%     the noise contribution in the sample from the 97% energy window.
%     If Nrms is not specified, an estimate of the noise is made from 
%     the first 30 and last 30 samples of h. If Nrms=0 or [], the noise
%     level is taken as 0 resulting in a conservative 97% energy
%     duration.
%
%     Most definitions taken from Au, 'Sonar of Dolphins'
%     
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     Last modified: 18 Nov. 2005

if nargin<2,
   help clickparams
   return
end

N = 1024 ;
ENERGY_CRIT = 0.97 ;
NWIN = 30 ;

if nargin>=3 & ~isempty(magresp),
   emph = 10.^(-magresp/20) ;
else
   emph = ones(N/2,1) ;
end

if nargin<4,
   Nrms = NaN ;            % force noise computation
elseif isempty(Nrms),
   Nrms = 0 ;              % assume no noise
end
np = Nrms.^2 ;
if length(np)==1,
   np = np*ones(size(h,2),1) ;
end

kk = [1:NWIN;size(h,1)+(-NWIN+1:0)]' ;     % noise windows, if needed

if isreal(h),
   h = hilbert(h) ;
end

tr = zeros(size(h,2),1) ;
td = tr ; f0 = tr ; t0 = tr ; beta = tr ; te = tr ; rms = tr ;
low10 = tr ; up10 = tr ; low3 = tr ; up3 = tr ;
fh = fft(h,N) ;
fh = fh(1:N/2,:).*(emph*ones(1,size(h,2))) ;
f = (0:N/2-1)'/N*fs ;
t = (0:size(h,1)-1)'/fs ;
afh = abs(fh).^2 ;
env = abs(h).^2 ;

for k=1:size(h,2),
   c = xcorr(h(:,k)) ;
   tr(k) = sum(abs(c).^2)/abs(c(size(h,1)))^2/fs ;
   f0(k) = sum(f.*afh(:,k))/sum(afh(:,k)) ;
   fms = sum(f.^2.*afh(:,k))/sum(afh(:,k)) ;
   beta(k) = sqrt(fms-f0(k)^2) ;
   t0(k) = sum(t.*env(:,k))/sum(env(:,k)) ;
   tms = sum(t.^2.*env(:,k))/sum(env(:,k)) ;
   td(k) = sqrt(tms-t0(k)^2) ;
   if isnan(Nrms(1)),
      np = min(var(real([h(kk(:,1),k) h(kk(:,2),k)]))) ;
      w = choosewindow(h(:,k),ENERGY_CRIT,np) ;
   else
      w = choosewindow(h(:,k),ENERGY_CRIT,np(k)) ;
   end
   te(k) = length(w)/fs ;
   rms(k) = std(real(h(w,k))) ;

   pk10 = max(afh(:,k))/10 ;
   mx = max(find(afh(:,k)>pk10)) ;
   mn = min(find(afh(:,k)>pk10)) ;
   low10(k) = f(mn) ;
   up10(k) = f(mx) ;

   pk3 = max(afh(:,k))/2 ;
   mx = max(find(afh(:,k)>pk3)) ;
   mn = min(find(afh(:,k)>pk3)) ;
   low3(k) = f(mn) ;
   up3(k) = f(mx) ;
end

be = tr.^(-1) ;
tb = td.*beta ;

R.tr = tr ;
R.be = be ;
R.f0 = f0 ;
R.t0 = t0 ;
R.beta = beta ;
R.td = td ;
R.tb = tb ;
R.te = te ;
R.rms = rms ;
[mm nn] = max(abs(fh)) ;
R.fp = f(nn) ;
R.low10 = low10 ;
R.up10 = up10 ;
R.bw10 = R.up10-R.low10 ;
R.low3 = low3 ;
R.up3 = up3 ;
R.bw3 = R.up3-R.low3 ;
