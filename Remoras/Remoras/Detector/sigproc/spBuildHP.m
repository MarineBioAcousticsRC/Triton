function FIR = spBuildHP(EdgeFreq, SampleRate, ...
                         MagnitudeResponse, ...
                         Ripple_dB)
% ImpulseResponse = spBuildHP(EdgeFreq, SampleRate, 
%                             MagnitudeResponse, Ripple_dB)
% Construct a high pass filter with the following properties:
%       Stop band to EdgeFreqs(1)
%       Pass band to EdgeFreqs(2)
%       MagnitudeResponse(k), Ripple_dB(k) -
%               Response and ripple of passband (k=1) 
%               and stopband (k=2).

% not finished
DeviationPB = ...
    (10^(Ripple_dB(1)/20)-1)/(10^(Ripple_dB(1)/20)+1);
DeviationSB = 10^(-Ripple_dB(2)/ 20);

% Estimate the design parameters
DesignParameters = firpmord(EdgeFreq, MagnitudeResponse, ...
                            [DeviationPB DeviationSB], ...
                            SampleRate, 'cell');
FIR = firpm(DesignParameters{:});

