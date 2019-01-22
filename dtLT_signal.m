function [SignalBins]= dtLT_signal(Specgram, ignore_periodic, HzRange,...
            Fbins, FrameLength, Threshold_dB,MeanAve_hr, Plot, varargin)
% [SignalBins]= dtLT_signal(Specgram, ignore_periodic, HzRange, ...
%                           Fbins, FrameLength, Threshold_dB,MeanAve_hr,
%                           Plot, OptionalArgs)
% Perform signal detection on the specified spectrogram.
% Specgram - spectrogram on which detection is to be conducted
% ignore_periodic - boolean indicating whether or not correlation
%       analysis is performed to locate frequency bands with periodic
%       noise and ignore the contribution of energy in these bands.
%       When ignore_periodic is set, the optional arguments
%       'LowPeriod_s', Nlow and 'HighPeriod_s', NHigh specify the 
%       range of periods that are searched.
% HzRange - vector showing the frequency range over which signals are
%       detected.
% FBins - Frequency bin labels of spectrogram.
% FrameLength - Frame advance of spectrogram in s.
% Theshold_dB - the amount by which the signal must exceed noise.
% MeanAve_hr - The number of hours over which a rolling mean noise
%       estimate is performed.
% Plot - boolean indicating whether or not outcome should be plotted.
%
% Do not modify the following line, maintained by CVS
% $Id: dtLT_signal.m,v 1.4 2008/10/22 07:01:01 sqiu Exp $

global PARAMS

% defaults
  LowPeriod_s = 3 * 60;     %For Find periodic calculations
  HighPeriod_s = 7 * 60;     %For Find periodic calculations

k=1;
while k < length(varargin)
  switch varargin{k}
   case 'LowPeriod_s'
        LowPeriod_s = varargin{k+1};
        k=k+2;
   case 'HighPeriod_s'
    HighPeriod_s = varargin{k+1};
    k=k+2;
   otherwise
    error('Bad optional argument:  %s', varargin{k})  
  end
end


% probably shouldn't have this hard-coded, but see how it works for now
MinSep_frames = 3;

% find places where signals are likely.
BinRange = find(Fbins >= HzRange(1) & ...
                Fbins <= HzRange(2));

MeanFrames = min(MeanAve_hr*60^2 / FrameLength, size(Specgram, 1));

% Delete periodically occurring signals from the set of frequency
% ranges to search.
if ignore_periodic
  % find periodic signal components which occur in a certain range.
  PeriodicBins = ...
      spFindPeriodic(Specgram, ...
                     LowPeriod_s, HighPeriod_s, FrameLength);
  
  BinRange = setdiff(BinRange, PeriodicBins);
end

if PARAMS.ltsa.dt.mean_enabled
    Args = {'MeanVector', PARAMS.ltsa.dt.pwr_mean};
else 
    Args = {};
end

% Find frames that have energy exceeding the background energy.
if ~ isempty(BinRange)
  SignalCandidates = spDetectEnergy(Specgram, ...
                                    'UseBins', BinRange, ...
                                    'MeanFrames', MeanFrames, ...
                                    'MinDuration', 1, ...
                                    Args{:}, ...
                                    'Threshold_dB', Threshold_dB)';
  

  % Might get into trouble here with skips, talk to Sean
  % about how to handle this.
  [Start, Label, Length] = spRunLengthAnalysis(SignalCandidates);
  % note labels which indicate signal present
  SignalPresent = find(Label == 1);
  SignalBins = [Start(SignalPresent)', ...
                Start(SignalPresent)'+Length(SignalPresent)'-1];
  SignalBins = dtMergeSegments(SignalBins, 1, MinSep_frames);           
  y = Fbins(floor(size(Specgram, 1)/2));
  s_Per_h = 60^2;
  
  % show where the candidate detections occur.  
  % We plot in the middle of the detected frame.  Since our indices
  % start at 1 but time starts at 0, we subtract the center point
  % instead of adding it.
  if Plot
    Center = FrameLength / 2;
    dtPlotDetections((SignalBins .* FrameLength - Center) / s_Per_h, ...
                    y, 'wp-');
  end
else
    SignalBins=[];
  %%%
  %%%NOTE THESE TIMES ARE MEANINGLESS - dvecStart & dvecEnd are for each
  %%%raw file of each xwav - need better idxs than 1, end. 
  %%%
    if Plot
    disp_msg(sprintf('No usable frequencies: %s-%s\n', ...
                     timestr(PARAMS.ltsa.dvecStart(1), 6), ...
                     timestr(PARAMS.ltsa.dvecEnd(end), 4)));
    else
      disp(sprintf('No usable frequencies: %s-%s\n', ...
                     timestr(PARAMS.ltsa.dvecStart(1), 6), ...
                     timestr(PARAMS.ltsa.dvecEnd(end), 4)));
  end
end
  
