function y = spFFTBandPass(x, SampleRate, FilterBank)
% BandLimitedFreqs = spFFTBandPass(Signal, SampleRate, FilterBank)
% Given Signal and a set of start and stop bands, filter the signal and
% a cell array containing frequency domain representations of the filtered
% signal.  If Signal is a matrix, each column is filtered.
%
% FilterBank has a similar structure to that of spBandPass, and filter banks
% designed for spBandPass may be used.  The only difference is that
% spFFTBandPass does not require (nor use) the Band{} cell vector which
% contains digital filter bank realizations.
%
% BandLimitedSignals contains
%	.Signal{n} - Band limited Signal from the nth bank.
%	.PassBands(n) - N x 2 matrix containing start/stop of the
%		signal before being passed throught the filter bank.
%
% This code is copyrighted 1997, 1998 by Marie Roch.
% e-mail:  marie-roch@uiowa.edu
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 

error(nargchk(3,3,nargin));
debug = 0;

Nyquist = SampleRate / 2;

y.PassBands = FilterBank.PassBands;

if SampleRate ~= FilterBank.SampleRate
  if FilterBank.SampleRate ~= 1
    % if not normalized, filter bank mismatch.  We could
    % certainly convert, but just return error.
    error('FilterBank and Signal sampling rate mismatch');
  else
    % normalized filterbank.  
    NormalizedPB = FilterBank.PassBands;
  end
else
  % Normalize frequencies between [0, 1]
  NormalizedPB = FilterBank.PassBands / Nyquist;
end

NormalizedPBRad = NormalizedPB * pi;	% convert pass band to radians
  
FreqDom = fft(x);
Bins = size(FreqDom, 1);
% Determine which frequency bins correspond to each passband.
% We copy both the below Nyquist components and their reflection
LoIndices = floor((0.5 * (Bins - 1)) * NormalizedPB) + 1;
% Since axis of reflection is at Pi we need to reverse the indices
% as well as shifting them.
HiIndices = Bins+1 - LoIndices(:,[2 1]);		

Bands = size(FilterBank.PassBands, 1);
y.Signal = cell(Bands, 1);
Epsilon = eps;	% Put in variable so we can easily replicate the value.
for k=1:Bands
  
  % Set base energy equal to small noise value so that
  % if a logarithm is computed (i.e. extracting cepstrum)
  % values will not go to -Inf
  y.Signal{k} = Epsilon(ones(size(FreqDom)));

  % copy out frequency components for each band
  Low = LoIndices(k,1):LoIndices(k,2);
  High = HiIndices(k,1):HiIndices(k,2);
  y.Signal{k}(Low,:) = FreqDom(Low,:);
  y.Signal{k}(High,:) = FreqDom(High,:);
end

if debug
  newplot
  subplot(Bands+1,1,1)
  plot(abs(FreqDom(:,2)))
  for k=1:Bands
    subplot(Bands+1,1,k+1)
    plot(abs(y.Signal{k}(:,2)))
  end
end
