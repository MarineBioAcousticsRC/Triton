function MFCC = spMFCC(SpectralVectors, SampleRate, CepstralCount, ...
		       MelFilterCount, LowCutoffHz, HighCutoffHz)
% MFCC = spMFCC(SpectralVectors, SampleRate, CepstralCount, ...
%		MelFilterCount, LowCutoffHz, HighCutoffHz)
%
% Create a set of Mel-filtered cepstral coefficients using MelFilterCount
% Mel filters.  SpectralVectors consists of a set of FFT squared magnitudes
% where each column represents one frame.
%
% Typically, 12-15 Mel-warped cepstral coefficients are retained and
% the number of Mel filters ranges between 24-40.  
%
% The dimensionality of MFCC is CepstralCount+1 by the number of spectral
% vectors.  The first component is energy and the remaining components are
% the CepstralCount vectors requested.
%
% The low and high cutoff parameters allow the user to specify the frequency
% band that the Mel filters cover.  If omitted, it defaults to 0 Hz and
% the Nyquist rate.
%
% Warnings: Note that the Mel filters must be spaced far enough apart to
% have DFT frequency bins to either side.  Overspecifying the number of Mel
% filters can result in both the center and either side of a Mel filter map
% to the same frequency bin.  This is not currently supported and will
% result in an error.  This can be circumvented by either specifying a
% smaller number of Mel filters or performing the DFT with a larger number
% of points which will interpolate the frequency for the additional
% frequency bins.
%
% This code is copyrighted 2002-2005 by Marie Roch.
% e-mail:  marie.roch@ieee.org
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 


CepstralCount = CepstralCount + 1;	% account for energy

[DFTSize, VectorCount] = size(SpectralVectors);
NyquistSize = DFTSize / 2;
NyquistRate = SampleRate / 2;

% Analyze in this frequency range only
if nargin < 6
  HzHigh = NyquistRate;
else
  HzHigh = HighCutoffHz;

  if nargin < 5
    HzLow = 133.33334;
  else
    HzLow = LowCutoffHz;
  end
end

% Create the Mel filter bank
fb = spFilterBank(MelFilterCount, SampleRate, DFTSize, ... 
                  'LowHz', HzLow, 'HighHz', HzHigh, 'Scale', 'Mel');

% preallocate
MFCC = zeros(MelFilterCount, VectorCount);


% Filter the spectrum --------------------
MF = zeros(MelFilterCount, VectorCount);        % preallocate for speed
% More efficient to do as a loop than matrix computation due to large size
for t = 1:VectorCount	
  for k = 1:MelFilterCount
    MF(k,t) = sum(SpectralVectors(1:size(fb.Windows,1), t) .* fb.Windows(:,k));
  end
end

% Set a minimum floor so we don't end up with any log 0 values.
LogFloor = 1.9287e-22;	% log(-50)
% Floor log Mel filters at the ETSI ES 201 108 v1.1.2 2000-04 specification.
MF(find(MF < LogFloor)) = LogFloor;

% Mel cepstrum is the inverse Fourier transform of the log Mel filters
MFCC = real(dct(log(MF)));	% real Cepstrum

% Remove excess cepstral vectors if needed
if CepstralCount < MelFilterCount
  MFCC(CepstralCount+1:end, :) = [];
end
