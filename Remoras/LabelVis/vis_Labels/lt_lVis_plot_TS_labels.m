function lt_lVis_plot_TS_labels

global REMORA PARAMS HANDLES

colF = [1 0 0];
colors = [
    0.0 0.0 0.0
    0.8 0.4 0.8
    1.0 0.6 0.0
    0.8 0.6 1.0
    0.8 1.0 1.0
    1.0 0.0 0.4
    1.0 0.6 0.6
    1.0 0.6 0.2
    ];


% determine start and end times of plot window
startWV = PARAMS.plot.dnum;
winLength = HANDLES.subplt.specgram.XLim(2); %get length of window in seconds, used to compute end limit
endWV = startWV + datenum(0,0,0,0,0,winLength);

plotMin = HANDLES.subplt.timeseries.YLim(1);
plotMax = HANDLES.subplt.timeseries.YLim(2);
plotCen = (plotMax+plotMin)./2;
ybuff = (plotMax-plotCen)./7;



%find detections in the window
if REMORA.lt.lVis_det.detection.PlotLabels
    yPos1 = plotCen + 3*ybuff;
    labl1 = REMORA.lt.lVis_det.detection.labels(1);
    label1Pos = plotCen + ybuff*3.5;
    
    plot_labels_wav(labl1,label1Pos,REMORA.lt.lVis_det.detection.starts,REMORA.lt.lVis_det.detection.stops,yPos1,col1,startWV,endWV);
    
    %plot changed labels
    changedLab = REMORA.lt.lEdit.detection;
    falseCh = changedLab(changedLab(:,3) == 0,:);
    oneCh = changedLab(changedLab(:,3) == 1,:);
    twoCh = changedLab(changedLab(:,3) == 2,:);
    threeCh = changedLab(changedLab(:,3) == 3,:);
    fourCh = changedLab(changedLab(:,3) == 4,:);
    fiveCh = changedLab(changedLab(:,3) == 5,:);
    sixCh = changedLab(changedLab(:,3) == 6,:);
    sevCh = changedLab(changedLab(:,3) == 7,:);
    eightCh = changedLab(changedLab(:,3) == 8,:);
    
    if ~isempty(falseCh)
        plot_chLab_wav(startWV,endWV,falseCh,colF,yPos1)
    end
    if ~isempty(oneCh)
        plot_chLab_wav(startWV,endWV,oneCh,col1,yPos1)
    end
    if ~isempty(twoCh)
        plot_chLab_wav(startWV,endWV,twoCh,col2,yPos1)
    end
    if ~isempty(threeCh)
        plot_chLab_wav(startWV,endWV,threeCh,col3,yPos1)
    end
    if ~isempty(fourCh)
        plot_chLab_wav(startWV,endWV,fourCh,col4,yPos1)
    end
     if ~isempty(fiveCh)
        plot_chLab_wav(startWV,endWV,fiveCh,col5,yPos1)
    end
    if ~isempty(sixCh)
        plot_chLab_wav(startWV,endWV,sixCh,col6,yPos1)
    end
    if ~isempty(sevCh)
        plot_chLab_wav(startWV,endWV,sevCh,col7,yPos1)
    end
    if ~isempty(eightCh)
        plot_chLab_wav(startWV,endWV,eightCh,col8,yPos1)
    end
end

%%%plot second labels if desired
if REMORA.lt.lVis_det.detection2.PlotLabels
    yPos2 = plotCen + 2*ybuff;
    labl2 = REMORA.lt.lVis_det.detection2.labels(1);
    label2Pos = plotCen + ybuff*2.5;
    
    plot_labels_wav(labl2,label2Pos,REMORA.lt.lVis_det.detection2.starts,REMORA.lt.lVis_det.detection2.stops,yPos2,col2,startWV,endWV);
    
    %plot changed labels
    changedLab = REMORA.lt.lEdit.detection2;
    falseCh = changedLab(changedLab(:,3) == 0,:);
    oneCh = changedLab(changedLab(:,3) == 1,:);
    twoCh = changedLab(changedLab(:,3) == 2,:);
    threeCh = changedLab(changedLab(:,3) == 3,:);
    fourCh = changedLab(changedLab(:,3) == 4,:);
    fiveCh = changedLab(changedLab(:,3) == 5,:);
    sixCh = changedLab(changedLab(:,3) == 6,:);
    sevCh = changedLab(changedLab(:,3) == 7,:);
    eightCh = changedLab(changedLab(:,3) == 8,:);
    
    if ~isempty(falseCh)
        plot_chLab_wav(startWV,endWV,falseCh,colF,yPos2)
    end
    if ~isempty(oneCh)
        plot_chLab_wav(startWV,endWV,oneCh,col1,yPos2)
    end
    if ~isempty(twoCh)
        plot_chLab_wav(startWV,endWV,twoCh,col2,yPos2)
    end
    if ~isempty(threeCh)
        plot_chLab_wav(startWV,endWV,threeCh,col3,yPos2)
    end
    if ~isempty(fourCh)
        plot_chLab_wav(startWV,endWV,fourCh,col4,yPos2)
    end
     if ~isempty(fiveCh)
        plot_chLab_wav(startWV,endWV,fiveCh,col5,yPos2)
    end
    if ~isempty(sixCh)
        plot_chLab_wav(startWV,endWV,sixCh,col6,yPos2)
    end
    if ~isempty(sevCh)
        plot_chLab_wav(startWV,endWV,sevCh,col7,yPos2)
    end
    if ~isempty(eightCh)
        plot_chLab_wav(startWV,endWV,eightCh,col8,yPos2)
    end
end

%%%plot third labels if desired
if REMORA.lt.lVis_det.detection3.PlotLabels
    yPos3 = plotCen+ybuff;
    labl3 = REMORA.lt.lVis_det.detection3.labels(1);
    label3Pos = plotCen + ybuff*1.5;
    
    plot_labels_wav(labl3,label3Pos,REMORA.lt.lVis_det.detection3.starts,REMORA.lt.lVis_det.detection3.stops,yPos3,col3,startWV,endWV);
    
    %plot changed labels
    changedLab = REMORA.lt.lEdit.detection3;
    falseCh = changedLab(changedLab(:,3) == 0,:);
    oneCh = changedLab(changedLab(:,3) == 1,:);
    twoCh = changedLab(changedLab(:,3) == 2,:);
    threeCh = changedLab(changedLab(:,3) == 3,:);
    fourCh = changedLab(changedLab(:,3) == 4,:);
    fiveCh = changedLab(changedLab(:,3) == 5,:);
    sixCh = changedLab(changedLab(:,3) == 6,:);
    sevCh = changedLab(changedLab(:,3) == 7,:);
    eightCh = changedLab(changedLab(:,3) == 8,:);
    
    if ~isempty(falseCh)
        plot_chLab_wav(startWV,endWV,falseCh,colF,yPos3)
    end
    if ~isempty(oneCh)
        plot_chLab_wav(startWV,endWV,oneCh,col1,yPos3)
    end
    if ~isempty(twoCh)
        plot_chLab_wav(startWV,endWV,twoCh,col2,yPos3)
    end
    if ~isempty(threeCh)
        plot_chLab_wav(startWV,endWV,threeCh,col3,yPos3)
    end
    if ~isempty(fourCh)
        plot_chLab_wav(startWV,endWV,fourCh,col4,yPos3)
    end
     if ~isempty(fiveCh)
        plot_chLab_wav(startWV,endWV,fiveCh,col5,yPos3)
    end
    if ~isempty(sixCh)
        plot_chLab_wav(startWV,endWV,sixCh,col6,yPos3)
    end
    if ~isempty(sevCh)
        plot_chLab_wav(startWV,endWV,sevCh,col7,yPos3)
    end
    if ~isempty(eightCh)
        plot_chLab_wav(startWV,endWV,eightCh,col8,yPos3)
    end
end

%%%plot fourth labels if desired
if REMORA.lt.lVis_det.detection4.PlotLabels
    yPos4 = plotCen;
    labl4 = REMORA.lt.lVis_det.detection4.labels(1);

    label4Pos = plotCen + ybuff*1.5;

    label4Pos = plotCen + ybuff*0.5;

    
    plot_labels_wav(labl4,label4Pos,REMORA.lt.lVis_det.detection4.starts,REMORA.lt.lVis_det.detection4.stops,yPos4,col4,startWV,endWV);
    
    %plot changed labels
    changedLab = REMORA.lt.lEdit.detection4;
    falseCh = changedLab(changedLab(:,3) == 0,:);
    oneCh = changedLab(changedLab(:,3) == 1,:);
    twoCh = changedLab(changedLab(:,3) == 2,:);
    threeCh = changedLab(changedLab(:,3) == 3,:);
    fourCh = changedLab(changedLab(:,3) == 4,:);
    fiveCh = changedLab(changedLab(:,3) == 5,:);
    sixCh = changedLab(changedLab(:,3) == 6,:);
    sevCh = changedLab(changedLab(:,3) == 7,:);
    eightCh = changedLab(changedLab(:,3) == 8,:);
    
    if ~isempty(falseCh)
        plot_chLab_wav(startWV,endWV,falseCh,colF,yPos4)
    end
    if ~isempty(oneCh)
        plot_chLab_wav(startWV,endWV,oneCh,col1,yPos4)
    end
    if ~isempty(twoCh)
        plot_chLab_wav(startWV,endWV,twoCh,col2,yPos4)
    end
    if ~isempty(threeCh)
        plot_chLab_wav(startWV,endWV,threeCh,col3,yPos4)
    end
    if ~isempty(fourCh)
        plot_chLab_wav(startWV,endWV,fourCh,col4,yPos4)
    end
     if ~isempty(fiveCh)
        plot_chLab_wav(startWV,endWV,fiveCh,col5,yPos4)
    end
    if ~isempty(sixCh)
        plot_chLab_wav(startWV,endWV,sixCh,col6,yPos4)
    end
    if ~isempty(sevCh)
        plot_chLab_wav(startWV,endWV,sevCh,col7,yPos4)
    end
    if ~isempty(eightCh)
        plot_chLab_wav(startWV,endWV,eightCh,col8,yPos4)
    end
end

%%%plot fifth labels if desired
if REMORA.lt.lVis_det.detection5.PlotLabels
    yPos5 = plotCen - ybuff;
    labl5 = REMORA.lt.lVis_det.detection5.labels(1);
    label5Pos = plotCen - ybuff*0.5;
    
    plot_labels_wav(labl5,label5Pos,REMORA.lt.lVis_det.detection5.starts,REMORA.lt.lVis_det.detection5.stops,yPos5,col5,startWV,endWV);
    
    %plot changed labels
    changedLab = REMORA.lt.lEdit.detection5;
    falseCh = changedLab(changedLab(:,3) == 0,:);
    oneCh = changedLab(changedLab(:,3) == 1,:);
    twoCh = changedLab(changedLab(:,3) == 2,:);
    threeCh = changedLab(changedLab(:,3) == 3,:);
    fourCh = changedLab(changedLab(:,3) == 4,:);
    fiveCh = changedLab(changedLab(:,3) == 5,:);
    sixCh = changedLab(changedLab(:,3) == 6,:);
    sevCh = changedLab(changedLab(:,3) == 7,:);
    eightCh = changedLab(changedLab(:,3) == 8,:);
    
    if ~isempty(falseCh)
        plot_chLab_wav(startWV,endWV,falseCh,colF,yPos5)
    end
    if ~isempty(oneCh)
        plot_chLab_wav(startWV,endWV,oneCh,col1,yPos5)
    end
    if ~isempty(twoCh)
        plot_chLab_wav(startWV,endWV,twoCh,col2,yPos5)
    end
    if ~isempty(threeCh)
        plot_chLab_wav(startWV,endWV,threeCh,col3,yPos5)
    end
    if ~isempty(fourCh)
        plot_chLab_wav(startWV,endWV,fourCh,col4,yPos5)
    end
    if ~isempty(fiveCh)
        plot_chLab_wav(startWV,endWV,fiveCh,col5,yPos5)
    end
    if ~isempty(sixCh)
        plot_chLab_wav(startWV,endWV,sixCh,col6,yPos5)
    end
    if ~isempty(sevCh)
        plot_chLab_wav(startWV,endWV,sevCh,col7,yPos5)
    end
    if ~isempty(eightCh)
        plot_chLab_wav(startWV,endWV,eightCh,col8,yPos5)
    end
end

%%%plot sixth labels if desired
if REMORA.lt.lVis_det.detection6.PlotLabels
    yPos6 = plotCen - 2*ybuff;
    labl6 = REMORA.lt.lVis_det.detection6.labels(1);
    label6Pos = plotCen - ybuff*1.5;
    
    plot_labels_wav(labl6,label6Pos,REMORA.lt.lVis_det.detection6.starts,REMORA.lt.lVis_det.detection6.stops,yPos6,col6,startWV,endWV);
    
    %plot changed labels
    changedLab = REMORA.lt.lEdit.detection6;
    falseCh = changedLab(changedLab(:,3) == 0,:);
    oneCh = changedLab(changedLab(:,3) == 1,:);
    twoCh = changedLab(changedLab(:,3) == 2,:);
    threeCh = changedLab(changedLab(:,3) == 3,:);
    fourCh = changedLab(changedLab(:,3) == 4,:);
    fiveCh = changedLab(changedLab(:,3) == 5,:);
    sixCh = changedLab(changedLab(:,3) == 6,:);
    sevCh = changedLab(changedLab(:,3) == 7,:);
    eightCh = changedLab(changedLab(:,3) == 8,:);
    
    if ~isempty(falseCh)
        plot_chLab_wav(startWV,endWV,falseCh,colF,yPos6)
    end
    if ~isempty(oneCh)
        plot_chLab_wav(startWV,endWV,oneCh,col1,yPos6)
    end
    if ~isempty(twoCh)
        plot_chLab_wav(startWV,endWV,twoCh,col2,yPos6)
    end
    if ~isempty(threeCh)
        plot_chLab_wav(startWV,endWV,threeCh,col3,yPos6)
    end
    if ~isempty(fourCh)
        plot_chLab_wav(startWV,endWV,fourCh,col4,yPos6)
    end
    if ~isempty(fiveCh)
        plot_chLab_wav(startWV,endWV,fiveCh,col5,yPos6)
    end
    if ~isempty(sixCh)
        plot_chLab_wav(startWV,endWV,sixCh,col6,yPos6)
    end
    if ~isempty(sevCh)
        plot_chLab_wav(startWV,endWV,sevCh,col7,yPos6)
    end
    if ~isempty(eightCh)
        plot_chLab_wav(startWV,endWV,eightCh,col8,yPos6)
    end
end

yPos = plotCen + 3*ybuff;
labelPos = plotCen + ybuff*3.5;
ydelta = ybuff;  % Lower plot line/labels for each group by this amount

% detection groups
labels = {'', '2', '3', '4', '5', '6', '7', '8'};

for labidx = 1:length(labels)
    detfld = sprintf('detection%s', labels{labidx});
    if REMORA.lt.lVis_det.(detfld).PlotLabels
        label = REMORA.lt.lVis_det.(detfld).labels(1);
        
        % This ignores anything that has a start before the window
        % and a stop after the window.
        % We could check for this explicitly, but we'll just ignore it
        % as it would be slower.  We might want to pad the window a bit
        % before searching
        
        % Find detections that are within the timeseries window
        % Assumes time are ordered from earliest to latest
        [Lo, Hi] = lt_lVis_get_range(startWV, endWV, ...
            REMORA.lt.lVis_det.(detfld).starts, ...
            REMORA.lt.lVis_det.(detfld).stops);
        %get final detection end and pass it into plotting for dotted
        %line
        finalDet = REMORA.lt.lVis_det.(detfld).stops(end);
        
        if ~ isempty(Lo)
            plot_labels_wav(label, labelPos, ...
                REMORA.lt.lVis_det.(detfld).starts(Lo:Hi), ...
                REMORA.lt.lVis_det.(detfld).stops(Lo:Hi), ...
                yPos, colors(labidx, :),startWV,endWV,finalDet);
            
            
            %plot changed labels
            changedLab = REMORA.lt.lEdit.(detfld);
            for cidx = 0:8
                ch = changedLab(changedLab(:,3) == cidx, :);
                if ~ isempty(ch)
                    if cidx == 0
                        % special case not in colors matrix
                        plot_chLab_wav(startWV, endWV, ch, colF, yPos);
                    else
                        plot_chLab_wav(startWV, endWV, ch, colors(cidx,:), yPos);
                    end
                end
            end
        end
        
    end
    yPos = yPos - ydelta;
    labelPos = labelPos - ydelta;

    
end

function plot_labels_wav(label,labelPos,startL, stopL, yPos, color,startWV,endWV,finalDet)

global PARAMS HANDLES
lablFull = [startL,stopL];
winLength = HANDLES.subplt.timeseries.XLim(2);

%just look for start time for plotting at click level
inWin = find(lablFull(:,1)>= startWV & lablFull(:,1)<=endWV);

winDets = lablFull(inWin,:);
detstartOff = winDets(:,1) - startWV;
detXstart = lt_convertDatenum(detstartOff,'seconds'); %convert from datenum to time in SECONDS

detendOff = winDets(:,2) - startWV;
detXend = lt_convertDatenum(detendOff,'seconds');

hold(HANDLES.subplt.timeseries, 'on')

%%%what kind of plotting are we going to do? Just plot a point if detection
%%%range is shorter than 1 min... using this as a proxy for tlab where
%%%detections are at click level

LineThresh = 1*60;

for iPlot = 1:size(detXstart,1)
    detDur = detXend - detXstart;
    detXNext = [detXstart(2:end);detXstart(end)];
    %     avgDetGap = mean(detXNext - detXstart);
    detGap = detXNext - detXstart;
    longGap = [];
    %get locations to plot label text based on how far apart detections
    %are
    longGap = [1;find(detGap>=0.1*winLength)+1];
    if ~isempty(longGap)
        labelRep = repmat(label,1,length(longGap));
        posRep = repmat(labelPos,1,length(longGap));
    else
        labelRep = label;
        posRep = labelPos;
        %if no longGaps, just plot on first detection
        longGap = 1:length(1);
    end
    if detDur < LineThresh
        %just plot the start of a given detection
        plot(HANDLES.subplt.timeseries, detXstart(iPlot), ...
            yPos,'*','Color',color)
        text(HANDLES.subplt.timeseries, detXstart(longGap),posRep,...
            labelRep,'Color',color,'FontWeight','normal')
    else
        plot(HANDLES.subplt.timeseries, ...
            [detXstart(iPlot) detXend(iPlot)],[yPos yPos],...
            '-','Marker','*','MarkerSize',2,'Color',color)
        text(HANDLES.subplt.timeseries, detXstart(longGap),posRep,...
            labelRep,'Color',color,'FontWeight','normal')
    end
end

if ~isempty(winDets)
    if isequal(stopL(end),finalDet)
        plot(HANDLES.subplt.timeseries, [detXend(end) detXend(end)], ...
            [HANDLES.subplt.timeseries.YLim(1) HANDLES.subplt.timeseries.YLim(2)],...
            ':','LineWidth',2,'Color',color)
    end
end

hold(HANDLES.subplt.timeseries, 'off');

function plot_chLab_wav(startWV,endWV,chLab,col,yPos)

global PARAMS HANDLES REMORA

lablFull = chLab(:,1:2);

%just look for starts for click-level detections
inWin = find(lablFull(:,1)>= startWV & lablFull(:,1)<=endWV);

winDets = lablFull(inWin,:);
detstartOff = winDets(:,1) - startWV;
detXstart = lt_convertDatenum(detstartOff,'seconds'); %convert from datenum to time in SECONDS

detendOff = winDets(:,2) - startWV;
detXend = lt_convertDatenum(detendOff,'seconds');

hold(HANDLES.subplt.timeseries, 'on');

%%%what kind of plotting are we going to do? Just plot a point if detection
%%%range is shorter than 1 min... using this as a proxy for tlab where
%%%detections are at click level

LineThresh = 1*60;

for iPlot = 1:size(detXstart,1)
    detDur = detXend - detXstart;
    if detDur < LineThresh
        %just plot the start of a given detection
        plot(HANDLES.subplt.timeseries, detXstart(iPlot), yPos,'*','Color',col)
    else
        plot(HANDLES.subplt.timeseries, ...
            [detXstart(iPlot) detXend(iPlot)],[yPos yPos],...
            '--','Marker','*','MarkerSize',2,'Color',col)
    end
end

hold(HANDLES.subplt.timeseries, 'off')


