function SNRDemo(Conversation, varargin)
% SNRDemo(Conversation, Options)
% Options
%	'Endpointed' 0|~0 non zero read in endpointed speech (default)

% default values
Endpointed = 1;

n=1;
while n <= length(varargin)
  switch varargin{n}
    case 'Endpointed'
      Endpointed = varargin{n+1}; n=n+2;
    otherwise
      error(sprintf('Unsupported arugment ''%s''', varargin{n}));
  end
end

if Endpointed
    FilePath = [spiBase, 'derived/chansepep/', Conversation];
else
    FilePath = [spiBase, 'derived/chansep/', Conversation];
end

    
Pcm = spiReadPCM(FilePath);
SampleRate = 8000;

WindowSpacingMS = 16;
WindowLengthMS = 32;

WindowSpacingSec = WindowSpacingMS / 1000;
WindowLengthSec = WindowLengthMS / 1000;

FilterBankFile = [spiBase, 'derived/filterbank/bp001'];

if ~isempty(FilterBankFile)
  load(FilterBankFile);	% loads FilterBank structure
  FilterN = length(FilterBank.Band);
else
  FilterBank = [];
  FilterN = 1;
end

% Band pass filter 
% If not filter was specified (FilterBank == []), simply places 
% unfiltered data in the same format as band pass filtered signals
% for uniformity.
BandPassSignals = spBandPass(Pcm, SampleRate, FilterBank);
BandPassSignals.FilterFile = FilterBankFile;

% First pass, compute window spacing & length
fprintf('Filter Bank window information:\n')
fprintf('\t\t\t\tSpacing\t\tLength\n');
fprintf('Bank\tLow\tHigh\tFrames\tSec\tFrames\tSec\tFrame/Sec\n');
for k=1:FilterN
  [WindowSpacing(k) WindowSpacingTime(k)] = ...
      nearestpower2(WindowSpacingSec, BandPassSignals.SampleRate(k));
  [WindowLength(k), WindowLengthTime(k)] = ...
      nearestpower2(WindowLengthSec, BandPassSignals.SampleRate(k));
  fprintf('%d\t%d\t%d\t%d\t%.4f\t%d\t%.4f\t%.4f\n', ...
      k, BandPassSignals.PassBands(k,:), ...
      WindowSpacing(k), WindowSpacingTime(k), ...
      WindowLength(k), WindowLengthTime(k), ...
      1/WindowSpacingTime(k));
end


for k=1:FilterN
  % Frame, subject to window
  FramedPcm = spFrame(BandPassSignals.Signal{k}, ...
      WindowSpacing(k), WindowLength(k));
  Energy{k} = sum(FramedPcm .* conj(FramedPcm));
  logEnergy{k} = log(Energy{k} + eps);	% avoid log 0
end  

SNRStat('var', 'var', Energy);
SNRStat('logvar', 'var', logEnergy);
SNRStat('std', 'std', Energy);
SNRStat('logstd', 'std', logEnergy);

%for k=1:FilterN
  % Frame, subject to window
%  [FramedPcm, IndexPcm] = spFrame(BandPassSignals.Signal{k}, ...
%      WindowSpacing(k), WindowLength(k));
  % FramedPcm = spWindow(FramedPcm);
  
  % spSNR(FramedPcm);
  % xlabel(sprintf('%s - %d-%d Hz, Endpointed Speech', Conversation, ...
  %    BandPassSignals.PassBands(k,:)));  
  % zoom on
  
%  Energy = sum(FramedPcm .* conj(FramedPcm));
%  Stat(k) = std(Energy);
%end
%StatName = 'STD';
%


function SNRStat(StatName, StatFN, Values)
N = length(Values);
for k=1:N
  eval(sprintf('Stat(k) = %s(Values{k});', StatFN));
end

Norm = Stat / sum(Stat);

for k=1:N
  fprintf('Band %d\t%s %f\t%% %f\n', k, StatName, Stat(k), Norm(k));
end
  


  

