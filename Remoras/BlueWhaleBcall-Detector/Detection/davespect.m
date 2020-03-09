function [result,fRate,gramParams] = ...
  davespect(seq, frameSize, nOverlap, zeroPad, windowFn, sRate)
%DAVESPECT    Compute the short-time periodic windowed FFT of a signal.
%
% gram = davespect(signal,frameSize,[nOverlap[,zeroPad[,windowFn[,sRate]]]])
%    For each frame, window it with a Hanning window of length frameSize,
%    compute the FFT, remove the negative frequencies, and take log(abs())
%    of the resulting elements.  Then hop ahead by (frameSize - nOverlap)
%    elements to the next frame.  nOverlap defaults to frameSize/2.
%    
%    If the zeroPad argument is supplied, that many zeros are appended
%    to the frame before computing the FFT.  zeroPad+frameSize should be
%    a power of two.
%
%    If a windowFn string is supplied, then that windowing function is
%    used instead of the default 'hanning'.
%   
%    The resulting array has (frameSize+zeroPad)/2 rows and
%    a number of columns determined by the framesize and overlap values
%    and the signal length.  Low frequencies in the result come first,
%    i.e., they have low row indices.
%   
%    If the input sound ever has a long sequence of zeros, then the FFT
%    output has zeros.  MATLAB will complain about "log of zero" and the 
%    gram returned will contain -Inf values.
%
% gram = davespect(signal, gramParams, sRate)
%    Spectrogram parameters are specified in a structure with these fields:
%	frameSizeS	frame size, in seconds
%	overlapFrac	[optional] e.g., 0.5 or 0.25; default is 0.5
%	zeroPadFrac	[optional] e.g., 0, 1, 3, or 7; default is 0
%	window		[optional] e.g., 'hamming'; default is hanning
%
% [gram,fRate] = davespect ( ... )
%    The second output argument 'fRate' is the frame rate, i.e., the number of
%    time-slices (columns) per second in the returned spectrogram.  In order to
%    calculate fRate, the sRate parameter must be one of the input arguments.
%
% [gram,fRate,gramParams] = davespect(signal, gramParams, sRate)
%    A third return argument is the gramParams structure with fields in units
%    of samples, including frameSize, nOverlap, and zeroPad.  All of these are
%    integers.  Also included is the field windowFn, which is a string.
%
% Dave Mellinger
% David.Mellinger, oregonstate.edu

if (isstruct(frameSize))
  gramParams = frameSize;
  p = frameSize;	% parameter structure
  sRate = nOverlap;	% rename the input arg
  frameSize = 2^round(log2(p.frameSizeS * sRate));
  nOverlap = frameSize * 0.5;
  if (isfield(p, 'overlapFrac')), nOverlap = frameSize * p.overlapFrac; end
  zeroPad = 0;
  if (isfield(p, 'zeroPadFrac')), zeroPad = frameSize * p.zeroPadFrac; end
  windowFn = 'hanning';
  if (isfield(p, 'windowFn')), windowFn = p.windowFn; end
else
  if (nargin < 3), nOverlap = frameSize/2;	end
  if (nargin < 4), zeroPad  = 0; 		end
  if (nargin < 5), windowFn = 'hanning';	end
end

gramParams.frameSize = frameSize;
gramParams.nOverlap = nOverlap;
gramParams.zeroPad = zeroPad;
gramParams.windowFn = windowFn;

[inrows, incols] = size(seq);
if inrows ~= 1 & incols ~= 1,
    error('Davespect requires a 1-dimensional sequence');
end

nfft    = frameSize + zeroPad;
seqsize = max(inrows, incols);
outcols = floor(1 + (seqsize - frameSize) / (frameSize - nOverlap));
outrows = nfft / 2;
window  = feval(windowFn, frameSize);             % column vector
outpos  = 1:outrows;

result  = zeros(outrows, outcols);

for i = 1:outcols
  start = 1 + (frameSize - nOverlap) * (i - 1);
  frame = reshape(seq(start:(start + frameSize - 1)), frameSize, 1);
  spectrum = fft(frame .* window, nfft);   % column vector
  result(:,i) = log(abs(spectrum(outpos)));
end
%result = result;		% move inside loop if memory problems

if (exist('sRate'))
  fRate = sRate / (frameSize - nOverlap);
end
