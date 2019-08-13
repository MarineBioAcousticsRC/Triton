function sh_plot_labels(freq)
% sh_plot_labels(freq)
% Plot the class labels for the currently active window.

% CAVEATS:  Broken for duty cycled data


global REMORA

[StartDate, StopDate] = sh_get_ltsa_range;

% find labels that lie within plot region
StartIndices = find(REMORA.sh.class.starts > StartDate & ...
                    REMORA.sh.class.starts < StopDate);
StopIndices = find(REMORA.sh.class.stops > StartDate & ...
                   REMORA.sh.class.stops < StopDate);
FullPlotIndex = find(REMORA.sh.class.starts < StartDate & ...
                    REMORA.sh.class.stops > StopDate);

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
  PlotInfo = [REMORA.sh.class.starts(StartOnly),  StopDate * ...
              ones(length(StartOnly), 1), StartOnly, ...
              ones(size(StartOnly))*TruncStop];
end

if Complete
  PlotInfo = [PlotInfo;
              REMORA.sh.class.starts(Complete),  REMORA.sh.class.stops(Complete), ...
              Complete, ones(size(Complete))*TruncNone];
end

if StopOnly
PlotInfo = [PlotInfo;
            StartDate*ones(length(StopOnly), 1), REMORA.sh.class.stops(StopOnly), ...
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
  Offsets = sh_date_to_xaxis([StartDate; StopDate]);
  PlotTime = sh_date_to_xaxis(PlotInfo(:,[Start Stop]));
  
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

  LowFreq = .97*freq;
  HighFreq = 1.01*freq;
  
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
           REMORA.sh.class.labels(PlotInfo(idx, DetectIdx)), ...
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
