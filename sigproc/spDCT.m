function b=spDCT(a,nn,omega,FFTW)
%spDCT  Discrete cosine transform of type II
%   Specifically, a modified Type II DCT --
%   it computes an orthogonal DCT, i.e. IDCT = (DCT)^*, where the
%   IDCT is a DCT of modified Type III; and IDCT = (DCT)^-1 )
%   Unless given the fftw argument (see below), this gives the same
%   result as calling matlab's DCT
%
%   modified from DCT (builtin matlab function) by Stephen Becker
%
%   Y = DCTT(X) returns the discrete cosine transform of X.
%   The vector Y is the same size as X and contains the
%   discrete cosine transform coefficients.
%
%   Y = DCTT(X,N) pads or truncates the vector X to length N 
%   before transforming.
%
%   Y = DCTT(X,N,OMEGA) returns Y(OMEGA), where OMEGA
%   is some subsample (i.e. so length(Y) = length(OMEGA) )
%   Use N = [] if you want to ignore this parameter
%   This is equivalent to sampling the rows of the DCT matrix.
%
%   Y = DCTT(X,N,OMEGA,true) will return a Type II DCT using
%   the normalization coefficients from the fftw website
%   (and 2x the coefficients from the wikipedia definitions).
%   This version is NOT orthogonal.  If the DCT and IDCT are
%   both called in this mode, then they are adjoints but not inverses,
%   and DCT(IDCT) is a diagonal matrix, and IDCT(DCT) is a full matrix.
%   Use N = [] and OMEGA = [] to ignore these parameters
%
%   If X is a matrix, the DCTT operation is applied to each
%   column.  This transform can be inverted using IDCTT.
%
%   See also IDCTT.
%
%
%   This version is modified by Stephen Becker, 1/28/08
%   srbecker@caltech.edu
%   This version uses persistent variables to achieve
%   a more than 2x speed reduction on subsequent calls
%   On subsequent calls, should be about only 1.4 to 1.5x slower 
%   than a FFT instead of 4x slower (original matlab code)
%   On the first call, it's still faster than matlab's DCT
%
%   Based off matlab's "dct" function, which was written by:
%              C. Thompson, 2-12-93
%              S. Eddins, 10-26-94, revised
% 
%   Matlab File Exchange:  dctt.m
%   http://www.mathworks.com/matlabcentral/fileexchange/18924
%   Posted 26 Feb 2008, downloaded 8 Aug 2009
%
% Do not modify the following line, maintained by CVS
% $Id: spDCT.m,v 1.1 2009/08/27 13:24:53 mroch Exp $

% 
% To implement: clear N upon any error

% this is independent of any subsampling
persistent ww N

if nargin == 0,
	error('Not enough input arguments.');
end
if isempty(a)
   b = [];
   return
end
% If input is a vector, make it a column:
do_trans = (size(a,1) == 1);
if do_trans, a = a(:); end

[n,m] = size(a);
if nargin<2 || isempty(nn)  % changing this slightly
  nn = size(a,1);
end
% m = size(a,2);

% decide whether to recompute "ww" (which depends only on n)
if isempty(N) || ( N ~= n)
    RECOMPUTE = true;
    N = n;
else
    RECOMPUTE = false;
end

% Pad or truncate input if necessary
if n<nn,
  aa = zeros(n,m);
  aa(1:n,:) = a;
elseif n==nn
  aa = a;
else
  aa = a(1:nn,:);    % truncate
end

odd =  ( rem(n,2)==1 || ~isreal(a) );

% Look at inputs and decide whether to subsample
if nargin > 2 && ~isempty(omega)
    SUBSAMPLE = true;
else
    SUBSAMPLE = false;
end

% Compute weights to multiply DFT coefficients
if RECOMPUTE
    c = -i*pi/(2*n);
    d = 1/sqrt(2*n);
    if ~odd, d = 2*d; end
    ww = d*(exp((0:n-1)*c)).';
    ww(1) = ww(1) / sqrt(2);
end
% ww = (exp(-i*(0:n-1)*pi/(2*n))/sqrt(2*n)).';  % SLOW
% ww(1) = ww(1) / sqrt(2);

if odd % odd case
  % Form intermediate even-symmetric matrix
  y = zeros(2*n,m);
  y(1:n,:) = aa;
  y(n+1:2*n,:) = flipud(aa);
  
  % Compute the FFT and keep the appropriate portion:
  yy = fft(y);  
  yy = yy(1:n,:);

else % even case
  % Re-order the elements of the columns of x
  if m == 1
      y = [ aa(1:2:n); aa(n:-2:2) ];
  else
      y = [ aa(1:2:n,:); aa(n:-2:2,:) ];
  end
  yy = fft(y);  
%   ww = 2*ww;  % Double the weights for even-length case  
end

% Multiply FFT by weights:
if m == 1
    if SUBSAMPLE
        b = ww(omega) .* yy(omega);
    else
        b = ww .* yy;
    end
else
    if SUBSAMPLE
        b = ww(omega,ones(1,m)) .* yy(omega,:);
    else
        b = ww(:,ones(1,m)) .* yy;
    end
end

if nargin > 3 && FFTW
% If requested, convert to fftw conventions
% For all except the DC component (k=0),
%   multiply by sqrt(n/2)
% For the DC component, multiply by just sqrt(n)
    sqrtn = 2*sqrt(n);
    sqrtn2 = sqrt(2*n);
    % Note that if we sample with omega, we might not have the DC component left
    if (SUBSAMPLE && (omega(1)==1)) || ~SUBSAMPLE
        if m == 1       % breaking into cases not necessary, but it's faster
            b(2:end) = sqrtn2*b(2:end);
            b(1)     = sqrtn *b(1);
        else
            b(2:end,:) = sqrtn2*b(2:end,:);
            b(1,:)     = sqrtn*b(1,:);
        end
    else
        b = sqrtn2*b;
    end
end

if isreal(a), b = real(b); end
if do_trans, b = b.'; end
