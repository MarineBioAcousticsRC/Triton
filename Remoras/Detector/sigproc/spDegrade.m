function [DegradedSignal, k] = spDegrade(Signal, Noise, varargin)
% [DegradedSignal NoiseScaleFactor] = spDegrade(Signal, Noise, ParameterList)
%	Corrupt a Signal with additive noise.  If the Noise signal is
%	of a shorter duration than the Signal, it will be repeated.
%	The DegradedSignal is returned along with the factor by which
%	the noise was scaled to obtain the desired SNR.
%
%	Optional arguments:
%	
%	Power estimates
%	'SignalLevel', dB	- signal power
%	'NoiseLevel', dB	- noise power
%	'SNR', dB		- desired SNR
%	

error(nargchk(2, inf, nargin))
SignalLevel = -inf;
NoiseLevel = -inf;
SNR = -inf;

n=1;
while n <= length(varargin)
  switch varargin{n}
   case 'SignalLevel'
    SignalLevel = varargin{n+1}; n=n+2;
   case 'NoiseLevel'
    NoiseLevel = varargin{n+1}; n=n+2;
   case 'SNR'
    SNR = varargin{n+1}; n=n+2;
   otherwise
    error(sprintf('Bad optional argument: "%s"', varargin{n}));
  end
end

if isinf(SNR)
  error(['Desired SNR cannot be infinite, select a different SNR ' ...
	'using the \'SNR\' option']);
end

if isinf(SignalLevel) | isinf(NoiseLevel)
  error(['Automatic Signal and NoiseLevel estimation not supported at this' ...
	 ' time.  You must specify these levels using the optional' ...
	  ' arguments.']);
end

RequiredNoiseLevel = SignalLevel - SNR;

% We will scale the noise signal by the constant k required to
% achieve the desired SNR.  
% desired noise:	sum_t( (k*noise(t))^2 )
%		in dB	10*log10((k^2) * sum_t(noise(t)^2))
%			20*log10(k) + 10*log10(noise(t)^2))
%				      |-- NoiseLevel known --|
% So,
% RequiredNoiseLevel = 20 log10 k + NoiseLevel
% and solving for k:
k = 10 ^ ((RequiredNoiseLevel - NoiseLevel)/20);

% Determine indices for the Noise signal
if (length(Noise) < length(Signal))
  % need to repeat
  FullCycles= floor(length(Signal)/length(Noise));
  LastIndex = rem(length(Signal), length(Noise));
  if (LastIndex)
    NoiseIdx = [repmat(1:length(Noise), 1, FullCycles), [1:LastIndex]];
  else
    NoiseIdx = repmat(1:length(Noise), 1, FullCycles);
  end
else
  % Noise as long or shorter
  NoiseIdx = 1:length(Signal);
end
  
DegradedSignal = Signal + k * Noise(NoiseIdx);





	 


