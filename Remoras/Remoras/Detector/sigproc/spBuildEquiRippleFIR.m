function FIR = spBuildEquiRippleFIR(EdgeFreq, MagResponse, varargin)
% ImpulseResponse = spBuildEquiRippleFir(EdgeFreq, MagnitudeResponse, ...
%                                        OptionalArgs)
% Construct an FIR equiripple with the following properties:
%       EdgeFreq - Frequencies for each transition point.
%       MagResponse - Magnitude response along each point defined
%               by the EdgeFrequences.
%
%
% Optional arguments:
%       'Display', N - plot filter response if N ~= 0
%       'Fs', N - Assume sample rate N
%       'Attenuation', N - Filter should have N dB of attenuation
% examples:
% Construct a lowpass filter for 48 kHz with following chracteristics:
%       stop band transition between 16 and 20 kHz
% lp = spBuildEquiRippleFIR([16000 20000], , ...
%                           [1 0], 'Fs', 48000);
%
% Construct a highpass filter with the same transition and characterstics
% for the pass & stop bands:
% hp = spBuildEquiRippleFIR([16000 20000], [0 1], 'Fs', 48000);
%
% Note that fitler order is approximated and there is no guarantee 
% that the filter will meet design constraints.

Fs = 1;
Display = 0;
Attenuation_dB = 60;

k=1;
while k <= length(varargin)
  switch varargin{k}
   case 'Attenuation'
    Attenuation_dB = varargin{k+1}; k=k+2;
   case 'Display'
    Display = varargin{k+1}; k=k+2;
   case 'Fs'
    Fs = varargin{k+1}; k=k+2;
   otherwise
    error('Argument %d bad', nargin + k)
  end
end

NyquistRate = Fs/2;

if length(MagResponse) > 2
  error('Only handles lp/hp')
end

% Equiripple optimizes the filter such that ripple in pass and stop
% bands are eqaul.  Set ratio of ripples with stop band ripples being
% N times greater than pass band ripples.
StopBandToPassBand = 10;
Penalties = ones(size(MagResponse));
StopBandIdcs = find(MagResponse == 0);
Penalties(StopBandIdcs) = StopBandToPassBand*Penalties(StopBandIdcs);

% Extend MagResponse for 0 Hz & NyquistRate
%       e.g. high pass:  [0 1] --> [0 0 1 1]
%            low pass:   [1 0] --> [1 1 0 0]
MagResponse = [MagResponse(1), MagResponse, MagResponse(end)];

% Approximate filter order using fred harris's approximation
NTaps = round((Fs/diff(EdgeFreq))*Attenuation_dB/22);
% Ensure filter of an even length
if mod(NTaps, 2)
  NTaps = NTaps + 1;
end


FIR = firpm(NTaps, [0, EdgeFreq, NyquistRate] ./ NyquistRate, ...
            MagResponse, Penalties);


