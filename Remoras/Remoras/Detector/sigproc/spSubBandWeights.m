function Weights = spSubBandWeights(Conversations)
% spSubBandWeights(Conversations, FilterBank)

Count = length(Conversations);
SampleRate = 8000;  % Assumed

WindowSpacingMS = 16;
WindowLengthMS = 32;

WindowSpacingSec = WindowSpacingMS / 1000;
WindowLengthSec = WindowLengthMS / 1000;

FilterBankFile = [spiBase, 'derived/filterbank/bp001'];
load(FilterBankFile);	% loads FilterBank structure
FilterN = length(FilterBank.Band);

% preallocate for efficiency
Statistic = zeros(1, FilterN);
Weights = zeros(Count, FilterN);

if Count
  n = 1;

  % Prime the loop
  % Read in first signal and send through filter bank.
  Signal = spiReadPCM([spiBase, 'derived/chansepEP/sw', Conversations{n}]);
  BPSignal = spBandPass(Signal, SampleRate, FilterBank);
  
  % Extract timing information from each subband.
  for k=1:FilterN
    [WindowSpacing(k) WindowSpacingTime(k)] = ...
	nearestpower2(WindowSpacingSec, BPSignal.SampleRate(k));
    [WindowLength(k), WindowLengthTime(k)] = ...
	nearestpower2(WindowLengthSec, BPSignal.SampleRate(k));
    fprintf('%d\t%d\t%d\t%d\t%.4f\t%d\t%.4f\t%.4f\n', ...
	k, BPSignal.PassBands(k,:), ...
	WindowSpacing(k), WindowSpacingTime(k), ...
	WindowLength(k), WindowLengthTime(k), ...
	1/WindowSpacingTime(k));
  end
  
  
  while n <= Count

    for k=1:FilterN
      % Frame, subject to window
      FramedPcm = spFrame(BPSignal.Signal{k}, ...
	  WindowSpacing(k), WindowLength(k));
      Energy{k} = sum(FramedPcm .* conj(FramedPcm));
      Statistic(k) = std(Energy{k});
    end  
    Weights(n,:) = Statistic / sum(Statistic);
    fprintf('%s\t', Conversations{n});
    fprintf('%.4f\t', Weights(n,:)); fprintf('\n');
    
    n = n + 1;
    if n <= Count
      % Prepare next signal
      Signal = spiReadPCM([spiBase, 'derived/chansepEP/sw', Conversations{n}]);
      BPSignal = spBandPass(Signal, SampleRate, FilterBank);
    end
  end  % loop
end
