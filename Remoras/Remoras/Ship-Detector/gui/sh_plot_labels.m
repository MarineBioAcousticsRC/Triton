function sh_plot_labels
% sh_plot_labels
% Plot the detection labels for the currently active window.

% CAVEATS:  Broken for duty cycled data


global REMORA PARAMS

freq = PARAMS.ltsa.f(1)+.9*(PARAMS.ltsa.f(end)-PARAMS.ltsa.f(1));
[startDate, stopDate] = sh_get_ltsa_range;

if REMORA.sh.detection.PlotLabels
    lowPos = .995*freq;
    highPos = 1.01*freq;
    color = [1 1 1];
    plot_times(REMORA.sh.detection.starts,REMORA.sh.detection.stops,...
        REMORA.sh.detection.labels,startDate,stopDate,color,lowPos,highPos)
end

if REMORA.sh.detection2.PlotLabels
    lowPos = 1.035*freq;
    highPos = 1.05*freq;
    color = [1 .6 .6];
    plot_times(REMORA.sh.detection2.starts,REMORA.sh.detection2.stops,...
        REMORA.sh.detection2.labels,startDate,stopDate,color,lowPos,highPos)
end

function plot_times(startDet,stopDet,labDet,StartDate,StopDate,color,lowPos,highPos)

global HANDLES

% find labels that lie within plot region
StartIndices = find(startDet > StartDate & startDet < StopDate);
StopIndices = find(stopDet > StartDate & stopDet < StopDate);
FullPlotIndex = find(startDet < StartDate & stopDet > StopDate);

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
    PlotInfo = [startDet(StartOnly), StopDate * ones(length(StartOnly), 1), ...
        StartOnly, ones(size(StartOnly))*TruncStop];
end

if Complete
    PlotInfo = [PlotInfo; startDet(Complete), stopDet(Complete), Complete, ...
        ones(size(Complete))*TruncNone];
end

if StopOnly
    PlotInfo = [PlotInfo; StartDate*ones(length(StopOnly), 1), ...
        stopDet(StopOnly), StopOnly, ones(size(StopOnly))*TruncStart];
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
    
%     holding = ishold;
%     hold on
    axes(HANDLES.subplt.ltsa)
    hold on
    
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
            text(PlotTime(idx, MidPt), lowPos, ...
                labDet(PlotInfo(idx, DetectIdx)), ...
                'HorizontalAlignment', 'Center', 'Color', color, ...
                'HitTest', 'off','FontWeight','Bold');
        end
        % draw a line if detection area is large enough, otherwise plot point
        if PlotTime(idx, Duration) > LineThresh
            plot([PlotTime(idx, Start), PlotTime(idx, Stop)], ...
                [highPos, highPos], '-', 'HitTest', 'off','Color',color)
            % plot line endings of appropriate type.  Only bother updating the
            % left/right end types if they differ from the last one plotted.
            if LastSpanType ~= PlotInfo(idx, SpanType)
                LastSpanType = PlotInfo(idx, SpanType);
                switch LastSpanType
                    case TruncNone
                        LeftEnd = 's';
                        RightEnd = 's';
                    case TruncStart
                        LeftEnd = '<';
                        RightEnd = 's';
                    case TruncStop
                        LeftEnd = 's';
                        RightEnd = '>';
                    case TruncBoth
                        LeftEnd = '<';
                        RightEnd = '>';
                end
            end
            plot(PlotTime(idx, Start), highPos, LeftEnd, 'HitTest', 'off',...
                'Color',color,'MarkerFaceColor',color);
            plot(PlotTime(idx, Stop), highPos, RightEnd, 'HitTest', 'off',...
                'Color',color,'MarkerFaceColor',color);
            
        else
            plot(PlotTime(idx, MidPt), highPos, 's', 'HitTest', 'off',...
                'Color',color,'MarkerFaceColor',color);
        end
    end
    hold off

end

