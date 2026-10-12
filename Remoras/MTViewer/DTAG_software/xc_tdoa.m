function       [cmin,q] = xc_tdoa(X,Y,MAX)
%
%    [cmin,q] = xc_tdoa(X,Y,[MAX])
%    Wideband time-difference-of-arrival estimator for stereo data
%    using the generalized cross-correlation.
%    X and Y are matrices of observed signals. Each column
%    is a distinct signal. X and Y are the signals from the
%    1st and 2nd channel, respectively, of a two-hydrophone array.
%    Optional argument MAX sets the maximum number of samples over which
%    the algorithm searches for a peak in the cross-correlation. This should be
%    just a little larger than the maximum possible time delay, i.e., the
%    end-fire time delay of fs*h/v, where v is the sound speed (m/s), h is the 
%    hydrophone separation in m, fs is the audio sampling rate in Hz. Default
%    value is MAX=4.
%
%    Returns:
%    cmin  the delay time in samples between each column of X and Y
%    q     the fit quality (1=perfect, 0=rotten)
%
%    To convert cmin to angle of arrival with respect to broadside,
%    use:   a = asin(cmin*v/(h*fs))
%    where: v is the sound speed, h is the hydrophone separation in m,
%           fs is the audio sampling rate.
%    Note that, in 3-dimensions, the angle of arrival is ambiguous with
%    the loci of equal angle of arrival being hyperboloids co-axial with
%    the line joining the two hydrophones.
%
%    markjohnson@st-andrews.ac.uk
%    November, 2004

cmin = [] ; q = [] ;

if nargin<2,
   help xc_tdoa
   return
end

if nargin<3,
   MAX = 4 ;               % choose this to be just larger than fs*h/v 
else
   MAX = ceil(abs(MAX)) ;
end

rx = sum(conj(X).*X)' ;
ry = sum(conj(Y).*Y)' ;

z = zeros(2*MAX+1,size(X,2)) ;

for k=1:size(X,2),
   z(:,k) = real(xcorr(Y(:,k),X(:,k),MAX)) ;
end

[m n] = max(z) ;
k = find(n==1) ;
n(k) = n(k)+1 ;
k = find(n==size(z,1)) ;
n(k) = n(k)-1 ;

p = zeros(size(X,2),3) ;
for k=1:size(X,2),
   p(k,:) = z(n(k)+(-1:1),k)' ;
end

xm = 0.5*(p(:,1)-p(:,3))./(p(:,3)-2*p(:,2)+p(:,1)) ;
ym = p(:,2)+(p(:,3)-p(:,1)).*xm/4 ;
cmin = real(n'-MAX-1+xm) ;

r = sqrt(rx.*ry) ;
q = ym./r ;
