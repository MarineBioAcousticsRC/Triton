function FilterBank = spFilterBank(FilterCount, SampleRate, DFTSize, varargin)
% FilterBank = spFilterBank(FilterCount, SampleRate, DFTSize, varargin)
%
% Generate a filterbank for the given DFT.  FilterBank is cell array where
% each entry is a vector of DFTSize containing weights for each of the DFT
% bins.  By default, the filter ceter frequencies are placed at uniform
% distances on the Mel scale.
%
% Optional arguments
%       'Scale', 'Mel'|'Hz' (default 'Mel')
%               Distribute the filter uniformly on which scale?
%       'LowHz', N - Left edge of the filter bank, default 0
%       'HighHz', N - Right edge of the filter bank, default is the
%               Nyquist rate
%
% This code is copyrighted 2002-2005 by Marie Roch.
% e-mail:  marie.roch@ieee.org
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 

Nyquist = SampleRate / 2;
HzLow = 0;
HzHigh = Nyquist;
Scale = 'Mel';

k=1;
while k < length(varargin)
  switch varargin{k}
   case 'LowHz'
    HzLow = varargin{k+1}; k = k+2;
   case 'HighHz'
    HzHigh = varargin{k+1}; k = k+2;
   case 'Scale'
    Scale = varargin{k+1}; k = k+2;
   otherwise
    error('Unknown option ''%s''', varargin{k})
  end
end

if HzHigh > Nyquist
  error('Highest frequency cannot exceed the Nyquist barrier');
end
HzRange = [HzLow HzHigh];
MelRange = spHz2Mel(HzRange);

% Filter bank will cover this bandwidth
HzBandwidth = diff(HzRange);
MelBandwidth = diff(MelRange);

% Find frequency bins of DFT
HzSpectralFilterBandwidth = SampleRate / DFTSize;
HzSpectralFilterBins = ...
    HzSpectralFilterBandwidth:HzSpectralFilterBandwidth:SampleRate;

% Find center frequencies
switch Scale
 case 'Mel'
  % Find center Mel frequencies 
  MelFilterBandwidth = MelBandwidth / (FilterCount+1);
  MelCenterFreqs = MelRange(1):MelFilterBandwidth:MelRange(2);
  % Determine bin indices of the center frequencies 
  % +1 added to conform to CMU feature extraction
  BinCenterFreqs = round(spMel2Hz(MelCenterFreqs) / ...
                         HzSpectralFilterBandwidth)+1;
  HzCenterFreqs = BinCenterFreqs * HzSpectralFilterBandwidth;
  
 case 'Hz'
  % Find center frequencies
  HzFilterBandwidth = HzBandwidth / (FilterCount + 1);
  % Determine bin indices of the center frequencies 
  % +1 added to conform to CMU feature extraction
  BinCenterFreqs = round([HzRange(1):HzFilterBandwidth:HzRange(2)] / ...
                         HzSpectralFilterBandwidth)+1;
  HzCenterFreqs = BinCenterFreqs * HzSpectralFilterBandwidth;

 otherwise
  error('Bad Scale value ''%s''', Scale)
end


if find(diff(BinCenterFreqs) == 0)
  error('SP:bandwidth', ...
        'Insufficient bandwidth in DFT bins for %d filters.', FilterCount);
end

% Generate triangular masks --------------------
FilterBank.Nyquist = Nyquist;
for k=1:FilterCount;
  
  Scale = 2 / (HzCenterFreqs(k+2) - HzCenterFreqs(k));

  % process left side - from left to center frequencies
  Slope = Scale / (HzCenterFreqs(k+1) - HzCenterFreqs(k));
  LeftRange = BinCenterFreqs(k):BinCenterFreqs(k+1);
  FilterBank.Windows(LeftRange, k) = ...
      (HzSpectralFilterBins(LeftRange)' - HzCenterFreqs(k)) * Slope;
  
  % process right side - from center+1 to right frequencies
  Slope = Scale / (HzCenterFreqs(k+1) - HzCenterFreqs(k+2));
  RightRange = (BinCenterFreqs(k+1)+1):BinCenterFreqs(k+2);
  FilterBank.Windows(RightRange, k) = ...
      (HzSpectralFilterBins(RightRange)' - HzCenterFreqs(k+2)) * Slope;
  
  % We could use the range of the coefficients to limit the 
  % range over which we multiply when computing the Mel filters,
  % but this turns out to be slower than simply multiplying
  % by everything up to the Nyquist rate, so we provide the 
  % full vector.
  FilterBank.Range{k} = [LeftRange, RightRange];
end

% Store frequencies associated with each bin for easy plotting
FilterBank.BinFreqs = HzSpectralFilterBins(1:size(FilterBank.Windows, 1));
FilterBank.CenterFreqs = HzCenterFreqs;

