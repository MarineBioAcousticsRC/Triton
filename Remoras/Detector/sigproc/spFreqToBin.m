function Bin = spFreqToBin(Freq, Bins, SampleRate)
% Bin = spFreqToBin(Freq, Bins, SampleRate)
% Map a frequency Freq to the nearest bin in a Fourier transform.
% Bins indicates the number points in the Fourier transform,
% SampleRate is an optional argument, if it is not present,
% the mapping is done on normalized [0,1] frequency.

error(nargchk(2, 3, nargin));

if nargin < 3
  SampleRate = 2;
end

Bin = round(Freq / SampleRate * (Bins - 2))+ 1;



