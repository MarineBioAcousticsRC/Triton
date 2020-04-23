function lt_lVis_plot_LTSA_labels

global REMORA PARAMS

%% get LTSA range times
%pull start and end times of window
[ltsaS,ltsaE] = lt_lVis_get_ltsa_range;
plotFreq = PARAMS.ltsa.f(end) *.9;
col1 = [1 1 1];
col2 = [1 0.2 0.6];
col3 = [1 0.6 0];
col4 = [0.8 0.6 1];

%find detections in the window
if REMORA.lt.lVis_det.detection.PlotLabels
    yPos1 = plotFreq*1;
    labl1 = REMORA.lt.lVis_det.detection.labels(1);
    label1Pos = plotFreq*1.05;
    
    %%% shorten detections to bout-level
    boutGap = datenum(0,0,0,0,0,15); %if spacing between start of detections...
    %is less than this, combine into a bout
    [startBouts,endBouts] = lt_lVis_defineBouts(REMORA.lt.lVis_det.detection.starts,REMORA.lt.lVis_det.detection.stops,...
        boutGap);
    
    plot_labels_ltsa(labl1,label1Pos,startBouts,endBouts,yPos1,col1,ltsaS,ltsaE);
    
end

%%%plot second labels if desired
if REMORA.lt.lVis_det.detection2.PlotLabels
    yPos2 = plotFreq*.9;
    labl2 = REMORA.lt.lVis_det.detection2.labels(1);
    label2Pos = plotFreq*.95;
    
    %%% shorten detections to bout-level
    boutGap = datenum(0,0,0,0,0,15); %if spacing between start of detections...
    %is less than this, combine into a bout
    [startBouts,endBouts] = lt_lVis_defineBouts(REMORA.lt.lVis_det.detection2.starts,REMORA.lt.lVis_det.detection2.stops,...
        boutGap);
    
    plot_labels_ltsa(labl2,label2Pos,startBouts,endBouts,yPos2,col2,ltsaS,ltsaE);
    
end

%%%plot third labels if desired
if REMORA.lt.lVis_det.detection3.PlotLabels
    yPos3 = plotFreq*.7;
    labl3 = REMORA.lt.lVis_det.detection3.labels(1);
    label3Pos = plotFreq*.75;
    
    %%% shorten detections to bout-level
    boutGap = datenum(0,0,0,0,0,15); %if spacing between start of detections...
    %is less than this, combine into a bout
    [startBouts,endBouts] = lt_lVis_defineBouts(REMORA.lt.lVis_det.detection3.starts,REMORA.lt.lVis_det.detection3.stops,...
        boutGap);
    
    plot_labels_ltsa(labl3,label3Pos,startBouts,endBouts,yPos3,col3,ltsaS,ltsaE);
    
end

%%%plot fourth labels if desired
if REMORA.lt.lVis_det.detection4.PlotLabels
    yPos4 = plotFreq*.6;
    labl4 = REMORA.lt.lVis_det.detection4.labels(1);
    label4Pos = plotFreq*.65;
    
    %%% shorten detections to bout-level
    boutGap = datenum(0,0,0,0,0,15); %if spacing between start of detections...
    %is less than this, combine into a bout
    [startBouts,endBouts] = lt_lVis_defineBouts(REMORA.lt.lVis_det.detection4.starts,REMORA.lt.lVis_det.detection4.stops,...
        boutGap);
    
    plot_labels_ltsa(labl4,label4Pos,startBouts,endBouts,yPos4,col4,ltsaS,ltsaE);
    
end


function plot_labels_ltsa(label,labelPos,startL, stopL, yPos, color,ltsaS,ltsaE)

global PARAMS HANDLES REMORA
lablFull = [startL,stopL];

startWin = find(startL >= ltsaS & startL <= ltsaE);
endWin = find(stopL >= ltsaS & stopL <= ltsaE);
fullDet = find(lablFull(:,1)>= ltsaS & lablFull(:,2)<=ltsaE);

startOnly = setdiff(startWin,endWin);
endOnly = setdiff(endWin,startWin);
winDetsStarts = [];
winDetsStops = [];
winDetsFull = [];

if startOnly
    winDetsStarts = [lablFull(startOnly,1),ones(size(lablFull(startOnly,1),1)).*ltsaE];
end

if endOnly
    winDetsStops = [ones(size(lablFull(endOnly,2),1)).*ltsaS,lablFull(endOnly,2)];
end

if fullDet
    winDetsFull = lablFull(fullDet,:);
end

if ~isempty(winDetsFull)
    %find which raw file each detection in winDet is in
    detXstart = lt_lVis_get_LTSA_Offset(winDetsFull,'starts');
    detXend = lt_lVis_get_LTSA_Offset(winDetsFull,'stops');
    
    
    axes (HANDLES.subplt.ltsa)
    hold on
    
    %%%what kind of plotting are we going to do? Just plot a point if detection
    %%%range is shorter than 1 min... using this to simplify plotting if tlab
    %%%detections are at click level
    
    LineThresh = 1/600;
    
    for iPlot = 1:size(detXstart,1)
        detDur = detXend - detXstart;
        if detDur < LineThresh
            %just plot the start of a given detection
            plot(detXstart(iPlot), yPos,'*','Color',color)
            text(detXstart(1),labelPos,label,'Color',color,'FontWeight','normal')
        else
            plot([detXstart(iPlot) detXend(iPlot)],[yPos yPos],'-','LineWidth',2,'Marker','*',...
                'MarkerSize',5,'Color',color)
            text(detXstart(1),labelPos,label,'Color',color,'FontWeight','normal')
        end
    end
    
    %plot a line at the end of the detection file
    if isequal(stopL(end),winDetsFull(end,2))
        plot([detXend(end) detXend(end)], [PARAMS.ltsa.f(1) PARAMS.ltsa.f(end)],'-','LineWidth',2,...
            'Color',color)
    end
    
    hold off
end

if ~isempty(winDetsStarts)
    %find which raw file each detection in winDet is in
    detXstart = lt_lVis_get_LTSA_Offset(winDetsStarts,'starts');
    detXend = lt_lVis_get_LTSA_Offset(winDetsStarts,'stops');
    
    
    axes (HANDLES.subplt.ltsa)
    hold on
    
    %%%what kind of plotting are we going to do? Just plot a point if detection
    %%%range is shorter than 1 min... using this to simplify plotting if tlab
    %%%detections are at click level
    
    LineThresh = 1/600;
    
    for iPlot = 1:size(detXstart,1)
        detDur = detXend - detXstart;
        if detDur < LineThresh
            %just plot the start of a given detection
            plot(detXstart(iPlot), yPos,'*','Color',color)
            text(detXstart(1),labelPos,label,'Color',color,'FontWeight','normal')
        else
            plot([detXstart(iPlot) detXend(iPlot)],[yPos yPos],'-','LineWidth',2,'Marker','*',...
                'MarkerSize',5,'Color',color)
            text(detXstart(1),labelPos,label,'Color',color,'FontWeight','normal')
        end
    end
    
    %plot a line at the end of the detection file
    if isequal(stopL(end),winDetsStarts(end,2))
        plot([detXend(end) detXend(end)], [PARAMS.ltsa.f(1) PARAMS.ltsa.f(end)],'-','LineWidth',2,...
            'Color',color)
    end
    
    hold off
end

if ~isempty(winDetsStops)
    %find which raw file each detection in winDet is in
    detXstart = lt_lVis_get_LTSA_Offset(winDetsStops,'starts');
    detXend = lt_lVis_get_LTSA_Offset(winDetsStops,'stops');
    
    
    axes (HANDLES.subplt.ltsa)
    hold on
    
    %%%what kind of plotting are we going to do? Just plot a point if detection
    %%%range is shorter than 1 min... using this to simplify plotting if tlab
    %%%detections are at click level
    
    LineThresh = 1/600;
    
    for iPlot = 1:size(detXstart,1)
        detDur = detXend - detXstart;
        if detDur < LineThresh
            %just plot the start of a given detection
            plot(detXstart(iPlot), yPos,'*','Color',color)
            text(detXstart(1),labelPos,label,'Color',color,'FontWeight','normal')
        else
            plot([detXstart(iPlot) detXend(iPlot)],[yPos yPos],'-','LineWidth',2,'Marker','*',...
                'MarkerSize',5,'Color',color)
            text(detXstart(1),labelPos,label,'Color',color,'FontWeight','normal')
        end
    end
    
    %plot a line at the end of the detection file
    if isequal(stopL(end),winDetsStops(end,2))
        plot([detXend(end) detXend(end)], [PARAMS.ltsa.f(1) PARAMS.ltsa.f(end)],'-','LineWidth',2,...
            'Color',color)
    end
    
    hold off
end


