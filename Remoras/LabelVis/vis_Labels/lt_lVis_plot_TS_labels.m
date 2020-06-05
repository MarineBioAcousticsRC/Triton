function lt_lVis_plot_TS_labels

global REMORA PARAMS HANDLES

colF = [1 0 0];
col1 = [0 0 0];
col2 = [0.8 0.4 0.8];
col3 = [1 0.6 0];
col4 = [0.8 0.6 1];
col5 = [0.8 1 1];
col6 = [1.0 0 0.4];
col7 = [1.0 0.6 0.6];
col8 = [1.0 0.6 0.2];

%% get range times
%create start and end times of window
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
    
    %%%plot seventh labels if desired
if REMORA.lt.lVis_det.detection7.PlotLabels
    yPos7 = plotCen - 3*ybuff;
    labl7 = REMORA.lt.lVis_det.detection7.labels(1);
    label7Pos = plotCen - ybuff*2.5;
    
    plot_labels_wav(labl7,label7Pos,REMORA.lt.lVis_det.detection7.starts,REMORA.lt.lVis_det.detection7.stops,yPos7,col7,startWV,endWV);
    
    %plot changed labels
    changedLab = REMORA.lt.lEdit.detection7;
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
        plot_chLab_wav(startWV,endWV,falseCh,colF,yPos7)
    end
    if ~isempty(oneCh)
        plot_chLab_wav(startWV,endWV,oneCh,col1,yPos7)
    end
    if ~isempty(twoCh)
        plot_chLab_wav(startWV,endWV,twoCh,col2,yPos7)
    end
    if ~isempty(threeCh)
        plot_chLab_wav(startWV,endWV,threeCh,col3,yPos7)
    end
    if ~isempty(fourCh)
        plot_chLab_wav(startWV,endWV,fourCh,col4,yPos7)
    end
    if ~isempty(fiveCh)
        plot_chLab_wav(startWV,endWV,fiveCh,col5,yPos7)
    end
    if ~isempty(sixCh)
        plot_chLab_wav(startWV,endWV,sixCh,col6,yPos7)
    end
    if ~isempty(sevCh)
        plot_chLab_wav(startWV,endWV,sevCh,col7,yPos7)
    end
    if ~isempty(eightCh)
        plot_chLab_wav(startWV,endWV,eightCh,col8,yPos7)
    end
end

%%%plot eighth labels if desired
if REMORA.lt.lVis_det.detection8.PlotLabels
    yPos8 = plotCen - 4*ybuff;
    labl8 = REMORA.lt.lVis_det.detection8.labels(1);
    label8Pos = plotCen - ybuff*3.5;
    
    plot_labels_wav(labl8,label8Pos,REMORA.lt.lVis_det.detection8.starts,REMORA.lt.lVis_det.detection8.stops,yPos8,col8,startWV,endWV);
    
    %plot changed labels
    changedLab = REMORA.lt.lEdit.detection8;
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
        plot_chLab_wav(startWV,endWV,falseCh,colF,yPos8)
    end
    if ~isempty(oneCh)
        plot_chLab_wav(startWV,endWV,oneCh,col1,yPos8)
    end
    if ~isempty(twoCh)
        plot_chLab_wav(startWV,endWV,twoCh,col2,yPos8)
    end
    if ~isempty(threeCh)
        plot_chLab_wav(startWV,endWV,threeCh,col3,yPos8)
    end
    if ~isempty(fourCh)
        plot_chLab_wav(startWV,endWV,fourCh,col4,yPos8)
    end
    if ~isempty(fiveCh)
        plot_chLab_wav(startWV,endWV,fiveCh,col5,yPos8)
    end
    if ~isempty(sixCh)
        plot_chLab_wav(startWV,endWV,sixCh,col6,yPos8)
    end
    if ~isempty(sevCh)
        plot_chLab_wav(startWV,endWV,sevCh,col7,yPos8)
    end
    if ~isempty(eightCh)
        plot_chLab_wav(startWV,endWV,eightCh,col8,yPos8)
    end
end

function plot_labels_wav(label,labelPos,startL, stopL, yPos, color,startWV,endWV)

global PARAMS HANDLES
lablFull = [startL,stopL];

%just look for start time for plotting at click level 
inWin = find(lablFull(:,1)>= startWV & lablFull(:,1)<=endWV);

winDets = lablFull(inWin,:);
detstartOff = winDets(:,1) - startWV;
detXstart = lt_convertDatenum(detstartOff,'seconds'); %convert from datenum to time in SECONDS

detendOff = winDets(:,2) - startWV;
detXend = lt_convertDatenum(detendOff,'seconds');

axes (HANDLES.subplt.timeseries)
hold on

%%%what kind of plotting are we going to do? Just plot a point if detection
%%%range is shorter than 1 min... using this as a proxy for tlab where
%%%detections are at click level

LineThresh = 1*60;

for iPlot = 1:size(detXstart,1)
    detDur = detXend - detXstart;
    if detDur < LineThresh
        %just plot the start of a given detection
        plot(detXstart(iPlot), yPos,'*','Color',color)
        text(detXstart(1),labelPos,label,'Color',color,'FontWeight','normal')
    else
        plot([detXstart(iPlot) detXend(iPlot)],[yPos yPos],'-','Marker','*',...
            'MarkerSize',2,'Color',color)
        text(detXstart(1),labelPos,label,'Color',color,'FontWeight','normal')
    end
end

if ~isempty(winDets)
    if isequal(stopL(end),winDets(end,2))
        plot([detXend(end) detXend(end)], [HANDLES.subplt.timeseries.YLim(1) HANDLES.subplt.timeseries.YLim(2)],'-','LineWidth',2,...
            'Color',color)
    end
end

hold off

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

axes (HANDLES.subplt.timeseries)
hold on

%%%what kind of plotting are we going to do? Just plot a point if detection
%%%range is shorter than 1 min... using this as a proxy for tlab where
%%%detections are at click level

LineThresh = 1*60;

for iPlot = 1:size(detXstart,1)
    detDur = detXend - detXstart;
    if detDur < LineThresh
        %just plot the start of a given detection
        plot(detXstart(iPlot), yPos,'*','Color',col)
    else
        plot([detXstart(iPlot) detXend(iPlot)],[yPos yPos],'--','Marker','*',...
            'MarkerSize',2,'Color',col)
    end
end

hold off


