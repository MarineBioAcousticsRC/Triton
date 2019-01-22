function [frames, SNR] = spDetectEnergy(spectrogram, varargin)
% frames = spDetectEnergy(spectrogram, optional args)
% Given a (frequency bin X time frame) spectrogram, determine which
% frames have energy exceeding the background energy by a given
% threshold.  frames is an indicator function vector of the same
% length as the spectrogram.  1s indicate energy has been detected.
% 
%
% Optional args:
% Multiple bandwidths may be analyzed.  In this case vectors are passed
% in for each scalar option and cell arrays are used in place of vectors.
% The returned frames will also be a cell array.
%
% 'UseBins', Vector - Only use frequencies contained in the bins
%                  contained in Vector.  This permits arbitrary
%                  frequency filtering.  Defaults to using all
%                  bins.
%            Cell - Multiple ranges, one per cell
% 'MeanFrames', N - Use N frames to compute the mean power, use Inf for 
%                  global mean, 0 for no mean.
% 'MeanVector', Vector - Use the specified vector as the mean power.
%                  When MeanVector is specified, MeanFrames is ignored.
% 'MinDuration', N - Events must exceed the threshold for at least N
%                  frames.  NOT CURRENTLY IMPLEMENTED
% 'Threshold_dB', N - How many decibels must the frequency bins exceed
%                  the background.  When UseBins spans multiple ranges
%                  N should be a vector with one threshold per range.
% 'MinThresholdFreqBins', N : how many frequency bins must exceed the
%                   threshold
% 'MaxThresholdFreqBins', N : N-1 is maximum number of frequency bins that 
%                   can exceed the threshold.  Goal is to eliminate clipped
%                   data.  Defaults to Inf which disables this feature
% 'Display', N : If N ~= 0, display the normalized spectrogram and
%                   indicate where the signal is detected.
% CAVEAT:  When using multiple bandwidths, you must supply all
% optional arguments as the defaults will not be appropriate.


[Bins, Frames] = size(spectrogram);

% defaults
UseBins = {1:Bins};       % use all bins
MinDuration = 3;
MeanFrames = 50;
MeanVector = [];
Threshold_dB = {18};
MinThresholdFreqBins = {1};
MaxThresholdFreqBins = {Inf};
Display = 0;

k=1;
while k < length(varargin)
  switch varargin{k}
   case 'UseBins'
    UseBins = varargin{k+1};
    if ~ iscell(UseBins)
      UseBins = {UseBins};
    end
    k=k+2;
    for s=1:length(UseBins)
      if max(UseBins{s}) > Bins || min(UseBins{s}) < 1
        error('UseBins: bins inappropriate for given spectrogram.')
      end
    end
   case 'MeanFrames'
    MeanFrames = varargin{k+1};
    k=k+2;
   case 'MinDuration'
    MinDuration = varargin{k+1};
    if ~ iscell(MinDuration)
      MinDuration = {MinDuration};
    end
    k=k+2;
   case 'MeanVector'
    MeanVector = varargin{k+1}; k = k+2;
    if size(MeanVector) ~= [Bins, 1]
        error('MeanVector inappropriate size, must match spectrogram')
    end
   case 'Threshold_dB'
    Threshold_dB = varargin{k+1};
    if ~ iscell(Threshold_dB)
      Threshold_dB = {Threshold_dB};
    end
    k=k+2;
   case 'MinThresholdFreqBins'
    MinThresholdFreqBins = varargin{k+1};
    if ~ iscell(MinThresholdFreqBins)
      MinThresholdFreqBins = {MinThresholdFreqBins};
    end
    k=k+2;
   case 'MaxThresholdFreqBins'
    MaxThresholdFreqBins = varargin{k+1};
    if ~ iscell(MaxThresholdFreqBins)
      MaxThresholdFreqBins = {MaxThresholdFreqBins};
    end
    k=k+2;
   case 'Display'
    Display = varargin{k+1};
    k=k+2;
   otherwise
    error('Bad optional argument:  %s', varargin{k})
  end
end

SubBands = length(UseBins);

frames = zeros(Frames, SubBands);
SNR = zeros(Frames,SubBands);

for s = 1:SubBands
  % Determine offsets from mean
  if isempty(MeanVector)
    switch MeanFrames
     case 0     % no mean
      normspec = spectrogram(UseBins{s});
     case Inf   % global mean
      u = mean(spectrogram(UseBins{s},:), 2);
      normspec = zeros(length(UseBins{s}), Frames);
      for f=1:Frames
          normspec(:,f) = spectrogram(UseBins{s},f) - u;
      end
     otherwise
      % set up for noncausal centered MA process
      if ~ rem(MeanFrames, 2)
        shift = MeanFrames/2;
        MeanFrames = MeanFrames + 1;  % must be odd to be centered
      else
        shift = (MeanFrames - 1)/2;
      end
      % Compute MeanFrames moving average
      u = stMA(spectrogram(UseBins{s},:)', MeanFrames, shift)';
      % debug - removed shift to be consistent w/ calcEndpoints2
      % u = stMA(spectrogram(UseBins{s},:)', MeanFrames)';
      normspec = spectrogram(UseBins{s}, :) - u;
    end
  else
    normspec = spectrogram(UseBins{s}) - MeanVector(UseBins{s});
  end

  % Find number of frequency bins exceeding threshold
  OverThresh = sum(normspec > Threshold_dB{s})';
  SNR(:,s) = max(normspec)';
    
  % Set indicator function for frames which exceed threshold 
  % and the saturation requirements.
  frames(:,s) = OverThresh >= MinThresholdFreqBins{s} & ...
           OverThresh < MaxThresholdFreqBins{s};
  
  if Display
    % Use out of range bins to display detections
    IndBins = setdiff(1:Bins, UseBins{s});
    if isempty(IndBins)
      % User is detecting over entire bandwidth, use bottom three bins for
      % indicator function
      IndBins = 1:min(4,Bins);
    end
    % Find dynamic range of normalized spectrogram to avoid changing
    % color range.
    MaxVal = max(max(normspec));
    MinVal = min(min(normspec));
    % First half of bins will be used to display if there are counts over
    % SNR.
    
    figure('Name', 'spDetectEnergy - axes in bins')
    IndRows = length(IndBins);
    Detections = frames(:,s)' * (MaxVal - MinVal) + MinVal;
    Candidates = (OverThresh > 0)' * (MaxVal - MinVal) + MinVal;
    CandBins = floor(length(IndBins)/2);
    DetBins = length(IndBins)-CandBins;
    % Replicate using Tom's trick and fill outside bandwidth 
    normspec(IndBins(1:CandBins),:) = Candidates(ones(CandBins,1),:);
    normspec(IndBins(CandBins+1:CandBins+DetBins),:) = Detections(ones(DetBins,1),:);
    imagesc(normspec);
    set(gca, 'YDir', 'Normal')
    xlabel('Time')
    ylabel('Frequency')
    keyboard
  end
end

1;


