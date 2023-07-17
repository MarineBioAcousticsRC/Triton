function [y,t] = spFramData(x,Nframe,Ncolumn,Noverlap,varargin)
% spFramData - Form overlapping frames of vectored data.
%	[frames, timescale] = spFramData(X,Nframe,Ncolumn,Noverlap,OptArgs) 
%	Forms matrix frames whose columns contain individual frames
%	of data vector x. Each column of frames is formed from Nframe 
%	consecutive samples of x.  Each consecutive column is formed by
%	taking the last Noverlap samples from the previous frame as its 
%	first portion.  See the optional arguments for specifying the
%	treatment for the last frame when it is partial.
%
%	timescale is a vector whose values correspond to the start time
%	of each frame with respect to the sampling frequency as specified
%	by the optional sampling rate argument (or its default).
%
%	Parameter constraints:
%		0 < Nframe <= Ncolumn
%		0 <= Noverlap < Nframe
%
%	OptArgs is an optional argument list.  If there is only a number
%	it is assumed to be a single argument indicating the sampling
%	frequency and the output argument timescale yields the start
%	time of each frame.  This is provided for backward comptability
%	with previous versions of spFramData.  The preferred method of
%	using OptArgs is to provide keyword value pairs:
%		'FS', fs - Set sampling rate to fs  (default 1)
%		'PartialFrame', n - 
%			n ~= 0 - Zero pad partial frames.  (default)
%			n == 0 - Discard partial frames.
%	
%	[y,tscale] = SPframdata(x,Nframe,Ncolumn,Noverlap,fs)
%	Returns the output vector tscale whose values correspond
%	to the start times of each frame in y based on the
%	sampling frequency fs. The sampling frequency defaults
%	to fs = 1 if not given.
%
%	The last frame receives additional zero padding if
%	there are not enough elements remaining in x to fill
%	the frame with Nframe samples.
%
%       Example:
%		>> x = 1:10
%		x =
%		     1   2   3   4   5   6   7   8   9  10
%
%		>> [y,t] = spFramData(x,3,4,1,'FS',2)
%		y =
%		     1     3     5     7     9
%		     2     4     6     8    10
%		     3     5     7     9     0
%		     0     0     0     0     0
%		t =
%		     0
%		     1
%		     2
%		     3
%		     4

%       LT Dennis W. Brown 11-1-93, DWB 6-23-94
%       Naval Postgraduate School, Monterey, CA
%       May be freely distributed.
%       Not for use in commercial products.
%
%	Modification history:
%		Marie Roch (MAR) 12-4-1997
%			Changed formal args & made partial frames optional


error(nargchk(4,inf,nargin));	% arg check

if Nframe > Ncolumn
  error(sprintf('Sample/frame Nframe=%d > Ncolumn=%d.', Nframe, Ncolumn));
end;

if Noverlap < 0,
  error('Frame overlap (Noverlap) cannot be less than zero.');
end;

if Noverlap >= Nframe,
  error(sprintf('Frame overlap Noverlap=%d > samples/frame Nframe=%d', ...  
      Noverlap, Nframe));
end

fs = 1;					% set defaults 
IncludePartial = 1;

switch length(varargin)			% process OptArgs
  case 0,
  case 1, fs = varargin{1};
  otherwise
    for m=1:2:length(varargin)
      switch varargin{m}
	case 'FS', fs = varargin{m+1};
	case 'PartialFrame', IncludePartial = varargin{m+1};
	otherwise, error(sprintf('Bad optional argument %s', varargin{m}));
      end
    end
end

x = x(:);				% make x a column vector
Ns = length(x);				% number of samples
Ndiff = Nframe - Noverlap;		% step size
L = fix((Ns-Nframe+Ndiff) / Ndiff);	% number of full frames

if L*Ndiff < Ns-Noverlap & IncludePartial		% partial frame?
	partial = 1;
else
	partial = 0;
end;

% output matrix
y = zeros(Ncolumn,L+partial);
t = zeros(L+partial,1);

% step index
col = 0;

% up to the last frame
for k = 1:Ndiff:L*Ndiff,

	% increase column
	col = col + 1;

	% fill the frame
	y(1:Nframe,col) = x(k:k+Nframe-1,1);
	t(col) = (k-1)/fs;

end;

if partial,

	k = k + Ndiff;
	nleft = Ns - L * Ndiff;

	y(1:nleft,L+1) = x(k:k+nleft-1,1);
	t(L+1) = (k-1)/fs;
end;

