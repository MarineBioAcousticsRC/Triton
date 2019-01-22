function QuantizedSignal = spQuantize(Bits, Signal)
% QuantizedSignal = spQuantize(Bits, Signal)
% Perform N bit biplolar quantization of a signal assuming that it has been
% matched to the full scale range of the quantizer (i.e. normalized between
% -1 and 1-step size).  Clipped values are set to NaN.
%
% Current quantization shemes:
% uniform - As a rule of thumb, for a well matched, signal, SNR increases by
%	about 6 dB for every bit in a uniform quantizer. 
%
% See Discrete-Time Signal Processing (1989, pp 114-123) by
% Oppenheim/Schafer for a discussion of uniform quantization.  Note that
% their discussion is for continuous to discrete, and here we are only
% approximating continuous with floating point arithmetic.
%
% This code is copyrighted 1998 by Marie Roch.
% e-mail:  marie-roch@uiowa.edu
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 

BitsMinus1 = Bits - 1;		% Find full amplitude signal limits
QuantMin = - 2^BitsMinus1;
QuantMax = 2^BitsMinus1 - 1;

% If the input signal has been matched precisely to the full scale range
% we are in trouble as the twos complement representation won't permit
% equal magnitudes for min and max.  We'll fudge this by setting input
% levels of 1 to one quantization step below.
QuantVals = [QuantMin:QuantMax QuantMax];	% Build quantizer data
QuantBins = -1:2^-BitsMinus1:1;			% Quantizer input levels

% old way which didn't fudge
% QuantBins = -1:2^-BitsMinus1:1-2^-BitsMinus1;	% Quantizer input levels

% Quantize signal
QuantizedSignal = interp1(QuantBins, QuantVals, Signal, '*nearest');

