function dt_plotLabels
% dtPlotLabels(plot_type, Freq)
% Plot the class labels for the currently active window.
%

% start time of the window where plots are desired.  Duration_s
% is the amount of time displayed in the window, measured in s.
%
% Detections are plotted at the designated frequency Freq.
%
% The labels themselves are stored in the detection section
% of the global PARAMS structure.
%
% Do not modify the following line, maintained by CVS
% $Id: dtPlotLabels.m,v 1.4 2007/09/14 18:42:28 mroch Exp $

% CAVEATS:  Broken for duty cycled data


global PARAMS REMORA


TBinWidth_d = PARAMS.ltsa.tave / (60*60*24);  % time bin width measured in days
Freq = PARAMS.ltsa.f(1)+.9*(PARAMS.ltsa.f(end)-PARAMS.ltsa.f(1));

% Get start and end of the plot in hours
dnums = zeros(2,1);
dnumIdx = 1;
for idx=[1, length(PARAMS.ltsa.t)]
    % Find the associated raw file and the time bin index into it
    [RawIdx, TBin] = getIndexBin(PARAMS.ltsa.t(idx));
    % Set time to start of current raw file + delta for each time bin.
    % Subtract off 1/2 bin as done in pickxzy, most likely the calculated
    % time is the center of the bin, so subtracing off a half bin
    % would give us the start.
    dnums(dnumIdx) = PARAMS.ltsa.dnumStart(RawIdx) + ...
        datenum([0 0 TBin*TBinWidth_d - TBinWidth_d/2]);
    dnumIdx = dnumIdx + 1;
end
dums(2) = dnums(2) + TBinWidth_d;
% datestr(dnums, 'mmm.dd.yyyy HH:MM:SS.FFF')  % debug

StartDate = dnums(1);
StopDate = dnums(2);

% find labels that lie within plot region
StartIndices = find(REMORA.ship_dt.class.starts > StartDate & ...
                    REMORA.ship_dt.class.starts < StopDate);
StopIndices = find(REMORA.ship_dt.class.stops > StartDate & ...
                   REMORA.ship_dt.class.stops < StopDate);
FullPlotIndex = find(REMORA.ship_dt.class.starts < StartDate & ...
                    REMORA.ship_dt.class.stops > StopDate);

Complete = intersect(StartIndices, StopIndices);
StartOnly = setdiff(StartIndices, StopIndices);
StopOnly = setdiff(StopIndices, StartIndices);

% Build PlotInfo
% Each row contains:   [Start, Stop, DetectIdx, SpanType]
PlotInfo = [];
Start = 1;      % serial date of start time within plot range
Stop = 2;       % serial date of stop time within plot range
DetectIdx = 3;  % index into StartIndices/StopIndices
% How does the data span the plot range?
% TruncNone - completely contained in the range
% TruncStart - Start time was truncated
% TruncStop - Stop time was truncated
% TruncBoth - plot range entirely inside start/stop  
SpanType = 4;   % column for span type
TruncNone = 0;
TruncStart = 1;
TruncStop = 2;
TruncBoth = 3;

if StartOnly
  PlotInfo = [REMORA.ship_dt.class.starts(StartOnly),  StopDate * ...
              ones(length(StartOnly), 1), StartOnly, ...
              ones(size(StartOnly))*TruncStop];
end

if Complete
  PlotInfo = [PlotInfo;
              REMORA.ship_dt.class.starts(Complete),  REMORA.ship_dt.class.stops(Complete), ...
              Complete, ones(size(Complete))*TruncNone];
end

if StopOnly
PlotInfo = [PlotInfo;
            StartDate*ones(length(StopOnly), 1), REMORA.ship_dt.class.stops(StopOnly), ...
            StopOnly, ones(size(StopOnly))*TruncStart];

end

if FullPlotIndex
    PlotInfo=[PlotInfo; 
              StartDate*ones(length(FullPlotIndex), 1), ...
              StopDate * ones(length(FullPlotIndex), 1), FullPlotIndex, ...
              ones(size(FullPlotIndex))*TruncBoth];
end

if ~isempty(PlotInfo)
  % convert dates to offset from starting time in units appropriate for plot.
  Offsets = date_to_xaxis(plot_type, [StartDate; StopDate]);
  PlotTime = date_to_xaxis(plot_type, PlotInfo(:,[Start Stop]));
  
  % Extend PlotTime to contain the following information
  MidPt = 3;    % midpoint between start & stop
  Duration = 4; % Normalized (0,1) duration of token
  Previous = 5; % Normalized distance to stopping point of previous
  Next = 6;     % Normalized distance to starting point of next
  
  RelativePosn = PlotTime(:, [Start, Stop]) ./ Offsets(2);
  
  % Compute midpt and duration (duration as a % of the time plotted)
  PlotTime(:, [MidPt, Duration]) = ...
      [mean(PlotTime(:, [Start,Stop]), 2), ...
       RelativePosn(:,Stop) - RelativePosn(:,Start)];
  PlotTime(:, Previous) = ...
      [1; RelativePosn(1:end-1, Stop) - RelativePosn(2:end, Start)];
  PlotTime(:, Next) = ...
      [RelativePosn(2:end, Start) - RelativePosn(1:end-1, Stop); 1];

  holding = ishold;
  hold on

  LowFreq = .97*Freq;
  HighFreq = 1.01*Freq;
  
  % Plot the labels.  Labels will have a line drawn between the start and
  % ending time if the interval is larger than LineThresh percent of the
  % display.  Text for the label is displayed when either a line is drawn
  % or the nearest neighbors are > TextThresh units away.
  LineThresh = .02;
  TextThresh = .02;
  LastSpanType = NaN;       % for efficiency, see below
  for idx = 1:size(PlotInfo, 1)
    if PlotTime(idx, Duration) > LineThresh || ...
          (PlotTime(idx, Previous) > TextThresh && ...
           PlotTime(idx, Next) > TextThresh)
      text(PlotTime(idx, MidPt), LowFreq, ...
           REMORA.ship_dt.class.labels(PlotInfo(idx, DetectIdx)), ...
           'Rotation', 90, 'HorizontalAlignment', 'Right', 'Color', 'w', ...
           'HitTest', 'off');
    end
    % draw a line if detection area is large enough, otherwise plot point
    if PlotTime(idx, Duration) > LineThresh
      plot([PlotTime(idx, Start), PlotTime(idx, Stop)], ...
           [HighFreq, HighFreq], 'w-', 'HitTest', 'off')
      % plot line endings of appropriate type.  Only bother updating the
      % left/right end types if they differ from the last one plotted.
      if LastSpanType ~= PlotInfo(idx, SpanType)
        LastSpanType = PlotInfo(idx, SpanType);
        switch LastSpanType
         case TruncNone
          LeftEnd = 'ws';
          RightEnd = 'ws';
         case TruncStart
          LeftEnd = 'w<';
          RightEnd = 'ws';
         case TruncStop
          LeftEnd = 'ws';
          RightEnd = 'w>';
         case TruncBoth
          LeftEnd = 'w<';
          RightEnd = 'w>';
        end
      end
      plot(PlotTime(idx, Start), HighFreq, LeftEnd, 'HitTest', 'off');
      plot(PlotTime(idx, Stop), HighFreq, RightEnd, 'HitTest', 'off');
      
    else
      plot(PlotTime(idx, MidPt), HighFreq, 'ws', 'HitTest', 'off');
    end
  end
  
  if ~ holding
    hold off
  end
end
