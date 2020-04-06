function lt_lVis_plot_LTSA_labels

global REMORA PARAMS

%% get LTSA range times
%pull start and end times of window
[ltsaS,ltsaE] = lt_lVis_get_ltsa_range;
plotFreq = PARAMS.ltsa.f(end) *.9;


%find detections in the window
if REMORA.lt.lVis_det.detection.PlotLabels
    yPos1 = plotFreq*1;
    col1 = [1 1 1];
    labl1 = REMORA.lt.lVis_det.detection.labels(1);
    label1Pos = plotFreq*1.05;
    
    plot_labels_ltsa(labl1,label1Pos,REMORA.lt.lVis_det.detection.starts,REMORA.lt.lVis_det.detection.stops,yPos1,col1,ltsaS,ltsaE);
    
end

%%%plot second labels if desired
if REMORA.lt.lVis_det.detection2.PlotLabels
    yPos2 = plotFreq*.9;
    col2 = [1 0 0.2];
    labl2 = REMORA.lt.lVis_det.detection2.labels(1);
    label2Pos = plotFreq*.95;
    
    plot_labels_ltsa(labl2,label2Pos,REMORA.lt.lVis_det.detection2.starts,REMORA.lt.lVis_det.detection2.stops,yPos2,col2,ltsaS,ltsaE);
    
end

%%%plot third labels if desired
if REMORA.lt.lVis_det.detection3.PlotLabels
    yPos3 = plotFreq*.7;
    col3 = [1 0.6 0];
    labl3 = REMORA.lt.lVis_det.detection3.labels(1);
    label3Pos = .75;
    
    plot_labels_ltsa(labl3,label3Pos,REMORA.lt.lVis_det.detection3.starts,REMORA.lt.lVis_det.detection3.stops,yPos3,col3,ltsaS,ltsaE);
    
end

%%%plot fourth labels if desired
if REMORA.lt.lVis_det.detection4.PlotLabels
    yPos4 = plotFreq*.6;
    col4 = [0.8 0.2 0.2];
    labl4 = REMORA.lt.lVis_det.detection4.labels(1);
    label4Pos = plotFreq*.65;
    
    plot_labels_ltsa(labl4,label4Pos,REMORA.lt.lVis_det.detection4.starts,REMORA.lt.lVis_det.detection4.stops,yPos4,col4,ltsaS,ltsaE);
    
end

function plot_labels_ltsa(label,labelPos,startL, stopL, yPos, color,ltsaS,ltsaE)

global PARAMS HANDLES
lablFull = [startL,stopL];

inWin = find(lablFull(:,1)>= ltsaS & lablFull(:,2)<=ltsaE);

winDets = lablFull(inWin,:);
detstartOff = winDets(:,1) - ltsaS;
detXstart = lt_convertDatenum(detstartOff,'hours'); %convert from datenum to time in hours

detendOff = winDets(:,2) - ltsaS;
detXend = lt_convertDatenum(detendOff,'hours');

axes (HANDLES.subplt.ltsa)
hold on

%%%what kind of plotting are we going to do? Just plot a point if detection
%%%range is shorter than 1 min... using this as a proxy for tlab where
%%%detections are at click level

LineThresh = 1/60;

for iPlot = 1:size(detXstart,1)
    detDur = detXend - detXstart;
    if detDur < LineThresh
        %just plot the start of a given detection
        plot(detXstart(iPlot), yPos,'*','Color',color)
        text(detXstart(1),labelPos,label,'Color',color,'FontWeight','normal')
    else
        plot([detXstart(iPlot) detXend(iPlot)],[yPos yPos],'--','Marker','*',...
            'MarkerSize',2,'Color',color)
        text(detXstart(1),labelPos,label,'Color',color,'FontWeight','normal')
    end
end

hold off


