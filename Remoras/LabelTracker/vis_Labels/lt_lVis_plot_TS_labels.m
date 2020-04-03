function lt_lVis_plot_TS_labels

disp('what makes the best sauce?');

global REMORA PARAMS HANDLES
%%PARAMS.start.dnum = start of individual wav file! Useful for figuring out
%%what's in window and plotting it. 

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
    yPos1 = plotCen + ybuff;
    col1 = [0 0 0];
    labl1 = REMORA.lt.lVis_det.detection.labels(1);
    label1Pos = plotCen + ybuff*1.5;
    
    plot_labels_wav(labl1,label1Pos,REMORA.lt.lVis_det.detection.starts,REMORA.lt.lVis_det.detection.stops,yPos1,col1,startWV,endWV);
    
end

%%%plot second labels if desired
if REMORA.lt.lVis_det.detection2.PlotLabels
    yPos2 = plotCen;
    col2 = [1 0 0.2];
    labl2 = REMORA.lt.lVis_det.detection2.labels(1);
    label2Pos = plotCen + ybuff*0.5;
    
    plot_labels_wav(labl2,label2Pos,REMORA.lt.lVis_det.detection2.starts,REMORA.lt.lVis_det.detection2.stops,yPos2,col2,startWV,endWV);
    
end

%%%plot third labels if desired
if REMORA.lt.lVis_det.detection3.PlotLabels
    yPos3 = plotCen- ybuff;
    col3 = [1 0.6 0];
    labl3 = REMORA.lt.lVis_det.detection3.labels(1);
    label3Pos = plotCen - ybuff*0.5;
    
    plot_labels_wav(labl3,label3Pos,REMORA.lt.lVis_det.detection3.starts,REMORA.lt.lVis_det.detection3.stops,yPos3,col3,startWV,endWV);
    
end

%%%plot fourth labels if desired
if REMORA.lt.lVis_det.detection4.PlotLabels
    yPos4 = plotCen - 2*ybuff;
    col4 = [0.8 0.2 0.2];
    labl4 = REMORA.lt.lVis_det.detection4.labels(1);
    label4Pos = plotCen + ybuff*1.5;
    
    plot_labels_wav(labl4,label4Pos,REMORA.lt.lVis_det.detection4.starts,REMORA.lt.lVis_det.detection4.stops,yPos4,col4,startWV,endWV);
    
end

function plot_labels_wav(label,labelPos,startL, stopL, yPos, color,startWV,endWV)

global PARAMS HANDLES
lablFull = [startL,stopL];

inWin = find(lablFull(:,1)>= startWV & lablFull(:,2)<=endWV);

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
        plot([detXstart(iPlot) detXend(iPlot)],[yPos yPos],'--','Color',color)
        text(detXstart(1),labelPos,label,'Color',color,'FontWeight','normal')
    end
end

hold off

disp('Worcestershire')