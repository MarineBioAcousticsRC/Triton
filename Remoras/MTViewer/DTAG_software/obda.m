function    [e,w,Ah] = obda(A,fs,fh,fl)
%
%    [e,w,Ah] = obda(A,fs,fh,fl)
%       Compute the 'Overall Body Dynamic Acceleration'
%       sensu Wilson et al. 2006.
%       OBDA is the norm of the high-pass-filtered
%       acceleration. In the Wilson paper, the 1-norm is
%       used. The 2-norm may be preferable if the tag
%       orientation is unknown or may change. Delay-free
%       filtering is used to avoid mis-match of OBDA with
%       other sensor signals.
%       A is the 3-column acceleration recording in g's.
%        Can be in the tag or whale frame - it doesn't matter
%        if you use the 2-norm.
%       fs is the sampling rate of A in Hz.
%       fh is the high-pass filter cut-on frequency in Hz.
%        Choose this to be about half of the normal stroking
%        rate for the animal.
%       fl is an optional low-pass filter to reduce high
%        frequency noise in the accelerometers. This could be
%        chosen about 3x or 4x the stroking rate.
%       Returns:
%       e is the 2-norm OBDA
%       w is the 1-norm OBDA
%       Ah is the high-pass-filtered acceleration
%
%    markjohnson@st-andrews.ac.uk
%    15 aug 2012

n = 5*round(fs/fh) ;
if nargin<4,
   Ah = fir_nodelay(A,n,fh/(fs/2),'high') ;
else
   Ah = fir_nodelay(A,n,[fh fl]/(fs/2)) ;
end

e = sqrt(abs(Ah).^2*ones(3,1)) ;
w = mean(abs(Ah),2) ;
