function lt_lVis_plot_LTSA_labels

global REMORA PARAMS

%% get LTSA range times
%pull start and end times of window
[ltsaS,ltsaE] = lt_lVis_get_ltsa_range;
plotFreq = PARAMS.ltsa.f(end) *.9;

colF = [1 0 0];
col1 = [1 1 1];
col2 = [0.8 0.4 0.8];
col3 = [1 0.6 0];
col4 = [0.8 0.6 1];
col5 = [0.8 1.0 1.0];
col6 = [1.0 0 0.4];
col7 = [1.0 0.6 0.6];
col8 = [1.0 0.6 0.2];

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
        plot_chLabels_ltsa(ltsaS,ltsaE,falseCh,colF,yPos)
    end
    if ~isempty(oneCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,oneCh,col1,yPos)
    end
    if ~isempty(twoCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,twoCh,col2,yPos)
    end
    if ~isempty(threeCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,threeCh,col3,yPos)
    end
    if ~isempty(fourCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,fourCh,col4,yPos)
    end
    if ~isempty(fiveCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,fiveCh,col5,yPos)
    end
    if ~isempty(sixCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,sixCh,col6,yPos)
    end
    if ~isempty(sevCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,sevCh,col7,yPos)
    end
    if ~isempty(eightCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,eightCh,col8,yPos)
    end
    
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
        plot_chLabels_ltsa(ltsaS,ltsaE,falseCh,colF,yPos2)
    end
    if ~isempty(oneCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,oneCh,col1,yPos2)
    end
    if ~isempty(twoCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,twoCh,col2,yPos2)
    end
    if ~isempty(threeCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,threeCh,col3,yPos2)
    end
    if ~isempty(fourCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,fourCh,col4,yPos2)
    end
    if ~isempty(fiveCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,fiveCh,col5,yPos2)
    end
    if ~isempty(sixCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,sixCh,col6,yPos2)
    end
    if ~isempty(sevCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,sevCh,col7,yPos2)
    end
    if ~isempty(eightCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,eightCh,col8,yPos2)
    end
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
        plot_chLabels_ltsa(ltsaS,ltsaE,falseCh,colF,yPos3)
    end
    if ~isempty(oneCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,oneCh,col1,yPos3)
    end
    if ~isempty(twoCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,twoCh,col2,yPos3)
    end
    if ~isempty(threeCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,threeCh,col3,yPos3)
    end
    if ~isempty(fourCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,fourCh,col4,yPos3)
    end
    if ~isempty(fiveCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,fiveCh,col5,yPos3)
    end
    if ~isempty(sixCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,sixCh,col6,yPos3)
    end
    if ~isempty(sevCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,sevCh,col7,yPos3)
    end
    if ~isempty(eightCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,eightCh,col8,yPos3)
    end
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
        plot_chLabels_ltsa(ltsaS,ltsaE,falseCh,colF,yPos4)
    end
    if ~isempty(oneCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,oneCh,col1,yPos4)
    end
    if ~isempty(twoCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,twoCh,col2,yPos4)
    end
    if ~isempty(threeCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,threeCh,col3,yPos4)
    end
    if ~isempty(fourCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,fourCh,col4,yPos4)
    end
    if ~isempty(fiveCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,fiveCh,col5,yPos4)
    end
    if ~isempty(sixCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,sixCh,col6,yPos4)
    end
    if ~isempty(sevCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,sevCh,col7,yPos4)
    end
    if ~isempty(eightCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,eightCh,col8,yPos4)
    end
end

%%%plot fifth labels if desired
if REMORA.lt.lVis_det.detection5.PlotLabels
    yPos5 = plotFreq*.5;
    labl5 = REMORA.lt.lVis_det.detection5.labels(1);
    label5Pos = plotFreq*.55;
    
    %%% shorten detections to bout-level
    boutGap = datenum(0,0,0,0,0,15); %if spacing between start of detections...
    %is less than this, combine into a bout
    [startBouts,endBouts] = lt_lVis_defineBouts(REMORA.lt.lVis_det.detection5.starts,REMORA.lt.lVis_det.detection5.stops,...
        boutGap);
    
    plot_labels_ltsa(labl5,label5Pos,startBouts,endBouts,yPos5,col5,ltsaS,ltsaE);
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
        plot_chLabels_ltsa(ltsaS,ltsaE,falseCh,colF,yPos5)
    end
    if ~isempty(oneCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,oneCh,col1,yPos5)
    end
    if ~isempty(twoCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,twoCh,col2,yPos5)
    end
    if ~isempty(threeCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,threeCh,col3,yPos5)
    end
    if ~isempty(fourCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,fourCh,col4,yPos5)
    end
    if ~isempty(fiveCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,fiveCh,col5,yPos5)
    end
    if ~isempty(sixCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,sixCh,col6,yPos5)
    end
    if ~isempty(sevCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,sevCh,col7,yPos5)
    end
    if ~isempty(eightCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,eightCh,col8,yPos5)
    end
end

%%%plot sixth labels if desired
if REMORA.lt.lVis_det.detection6.PlotLabels
    yPos6 = plotFreq*.4;
    labl6 = REMORA.lt.lVis_det.detection6.labels(1);
    label6Pos = plotFreq*.45;
    
    %%% shorten detections to bout-level
    boutGap = datenum(0,0,0,0,0,15); %if spacing between start of detections...
    %is less than this, combine into a bout
    [startBouts,endBouts] = lt_lVis_defineBouts(REMORA.lt.lVis_det.detection6.starts,REMORA.lt.lVis_det.detection6.stops,...
        boutGap);
    
    plot_labels_ltsa(labl6,label6Pos,startBouts,endBouts,yPos6,col6,ltsaS,ltsaE);
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
        plot_chLabels_ltsa(ltsaS,ltsaE,falseCh,colF,yPos6)
    end
    if ~isempty(oneCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,oneCh,col1,yPos6)
    end
    if ~isempty(twoCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,twoCh,col2,yPos6)
    end
    if ~isempty(threeCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,threeCh,col3,yPos6)
    end
    if ~isempty(fourCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,fourCh,col4,yPos6)
    end
    if ~isempty(fiveCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,fiveCh,col5,yPos6)
    end
    if ~isempty(sixCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,sixCh,col6,yPos6)
    end
    if ~isempty(sevCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,sevCh,col7,yPos6)
    end
    if ~isempty(eightCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,eightCh,col8,yPos6)
    end
end

%%%plot seventh labels if desired
if REMORA.lt.lVis_det.detection7.PlotLabels
    yPos7 = plotFreq*.3;
    labl7 = REMORA.lt.lVis_det.detection7.labels(1);
    label7Pos = plotFreq*.35;
    
    %%% shorten detections to bout-level
    boutGap = datenum(0,0,0,0,0,15); %if spacing between start of detections...
    %is less than this, combine into a bout
    [startBouts,endBouts] = lt_lVis_defineBouts(REMORA.lt.lVis_det.detection7.starts,REMORA.lt.lVis_det.detection7.stops,...
        boutGap);
    
    plot_labels_ltsa(labl7,label7Pos,startBouts,endBouts,yPos7,col7,ltsaS,ltsaE);
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
        plot_chLabels_ltsa(ltsaS,ltsaE,falseCh,colF,yPos7)
    end
    if ~isempty(oneCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,oneCh,col1,yPos7)
    end
    if ~isempty(twoCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,twoCh,col2,yPos7)
    end
    if ~isempty(threeCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,threeCh,col3,yPos7)
    end
    if ~isempty(fourCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,fourCh,col4,yPos7)
    end
    if ~isempty(fiveCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,fiveCh,col5,yPos7)
    end
    if ~isempty(sixCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,sixCh,col6,yPos7)
    end
    if ~isempty(sevCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,sevCh,col7,yPos7)
    end
    if ~isempty(eightCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,eightCh,col8,yPos7)
    end
end

%%%plot eighth labels if desired
if REMORA.lt.lVis_det.detection8.PlotLabels
    yPos8 = plotFreq*.2;
    labl8 = REMORA.lt.lVis_det.detection8.labels(1);
    label8Pos = plotFreq*.25;
    
    %%% shorten detections to bout-level
    boutGap = datenum(0,0,0,0,0,15); %if spacing between start of detections...
    %is less than this, combine into a bout
    [startBouts,endBouts] = lt_lVis_defineBouts(REMORA.lt.lVis_det.detection8.starts,REMORA.lt.lVis_det.detection8.stops,...
        boutGap);
    
    plot_labels_ltsa(labl8,label8Pos,startBouts,endBouts,yPos8,col8,ltsaS,ltsaE);
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
        plot_chLabels_ltsa(ltsaS,ltsaE,falseCh,colF,yPos8)
    end
    if ~isempty(oneCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,oneCh,col1,yPos8)
    end
    if ~isempty(twoCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,twoCh,col2,yPos8)
    end
    if ~isempty(threeCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,threeCh,col3,yPos8)
    end
    if ~isempty(fourCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,fourCh,col4,yPos8)
    end
    if ~isempty(fiveCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,fiveCh,col5,yPos8)
    end
    if ~isempty(sixCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,sixCh,col6,yPos8)
    end
    if ~isempty(sevCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,sevCh,col7,yPos8)
    end
    if ~isempty(eightCh)
        plot_chLabels_ltsa(ltsaS,ltsaE,eightCh,col8,yPos8)
    end
end
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
    detXstart = lt_lVis_get_LTSA_Offset(winDetsFull,'starts',ltsaS);
    detXend = lt_lVis_get_LTSA_Offset(winDetsFull,'stops',ltsaS);
    
    
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
    detXstart = lt_lVis_get_LTSA_Offset(winDetsStarts,'starts',ltsaS);
    detXend = lt_lVis_get_LTSA_Offset(winDetsStarts,'stops',ltsaS);
    
    
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
    detXstart = lt_lVis_get_LTSA_Offset(winDetsStops,'starts',ltsaS);
    detXend = lt_lVis_get_LTSA_Offset(winDetsStops,'stops',ltsaS);
    
    
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
end

function plot_chLabels_ltsa(ltsaS,ltsaE,chLab,color,yPos)

global PARAMS HANDLES REMORA
winDetsFull = [];

lablFull = chLab(:,1:2);
fullDet = find(lablFull(:,1)>= ltsaS & lablFull(:,2)<=ltsaE);
winDetsFull = lablFull(fullDet,:);

if ~isempty(winDetsFull)
    %find which raw file each detection in winDet is in
    detXstart = lt_lVis_get_LTSA_Offset(winDetsFull,'starts',ltsaS);
    detXend = lt_lVis_get_LTSA_Offset(winDetsFull,'stops',ltsaS);
    
    
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
        else
            plot([detXstart(iPlot) detXend(iPlot)],[yPos yPos],'-','LineWidth',2,'Marker','*',...
                'MarkerSize',5,'Color',color)
        end
    end
    
    %plot a line at the end of the detection file
    if isequal(ltsaE(end),winDetsFull(end,2))
        plot([detXend(end) detXend(end)], [PARAMS.ltsa.f(1) PARAMS.ltsa.f(end)],'-','LineWidth',2,...
            'Color',color)
    end
    
    hold off
    
end
end
