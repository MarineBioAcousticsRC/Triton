function lt_lVis_plot_WAV_labels

global REMORA PARAMS HANDLES
%%PARAMS.start.dnum = start of individual wav file! Useful for figuring out
%%what's in window and plotting it. 


%% get range times
%create start and end times of window
startWV = PARAMS.plot.dnum;
winLength = HANDLES.subplt.specgram.XLim(2); %get length of window in seconds, used to compute end limit
endWV = startWV + datenum(0,0,0,0,0,winLength); 

plotFreq = PARAMS.freq1 *.9;
col1 = [1 1 1];
col2 = [1 0.2 0.6];
col3 = [1 0.6 0];
col4 = [0.8 0.6 1];
colF = [1 0 0];
        
%find detections in the window
if REMORA.lt.lVis_det.detection.PlotLabels
    yPos1 = plotFreq*1;
    labl1 = REMORA.lt.lVis_det.detection.labels(1);
    label1Pos = plotFreq*1.05;
    
    plot_labels_wav(labl1,label1Pos,REMORA.lt.lVis_det.detection.starts,REMORA.lt.lVis_det.detection.stops,yPos1,col1,startWV,endWV);
    
    %plot changed labels 
    if ~isempty(REMORA.lt.lEdit.detection.chLabFalse)
        plot_chLab_wav(startWV,endWV,REMORA.lt.lEdit.detection.chLabFalse,colF,yPos1)
    end
    if ~isempty(REMORA.lt.lEdit.detection.chLab1)
        plot_chLab_wav(startWV,endWV,REMORA.lt.lEdit.detection.chLab1,col1,yPos1)
    end
    if ~isempty(REMORA.lt.lEdit.detection.chLab2)
        plot_chLab_wav(startWV,endWV,REMORA.lt.lEdit.detection.chLab2,col2,yPos1)
    end
    if ~isempty(REMORA.lt.lEdit.detection.chLab3)
        plot_chLab_wav(startWV,endWV,REMORA.lt.lEdit.detection.chLab3,col3,yPos1)
    end
    if ~isempty(REMORA.lt.lEdit.detection.chLab4)
        plot_chLab_wav(startWV,endWV,REMORA.lt.lEdit.detection.chLab4,col4,yPos1)
    end
end

%%%plot second labels if desired
if REMORA.lt.lVis_det.detection2.PlotLabels
    yPos2 = plotFreq*.9;
    labl2 = REMORA.lt.lVis_det.detection2.labels(1);
    label2Pos = plotFreq*.95;
    
    plot_labels_wav(labl2,label2Pos,REMORA.lt.lVis_det.detection2.starts,REMORA.lt.lVis_det.detection2.stops,yPos2,col2,startWV,endWV);
    
        
    %plot changed labels 
    if ~isempty(REMORA.lt.lEdit.detection2.chLabFalse)
        plot_chLab_wav(startWV,endWV,REMORA.lt.lEdit.detection2.chLabFalse,colF,yPos2)
    end
    if ~isempty(REMORA.lt.lEdit.detection2.chLab1)
        plot_chLab_wav(startWV,endWV,REMORA.lt.lEdit.detection2.chLab1,col1,yPos2)
    end
    if ~isempty(REMORA.lt.lEdit.detection2.chLab2)
        plot_chLab_wav(startWV,endWV,REMORA.lt.lEdit.detection2.chLab2,col2,yPos2)
    end
    if ~isempty(REMORA.lt.lEdit.detection2.chLab3)
        plot_chLab_wav(startWV,endWV,REMORA.lt.lEdit.detection2.chLab3,col3,yPos2)
    end
    if ~isempty(REMORA.lt.lEdit.detection2.chLab4)
        plot_chLab_wav(startWV,endWV,REMORA.lt.lEdit.detection2.chLab4,col4,yPos2)
    end
end

%%%plot third labels if desired
if REMORA.lt.lVis_det.detection3.PlotLabels
    yPos3 = plotFreq*.7;

    labl3 = REMORA.lt.lVis_det.detection3.labels(1);
    label3Pos = plotFreq*.75;
    
    plot_labels_wav(labl3,label3Pos,REMORA.lt.lVis_det.detection3.starts,REMORA.lt.lVis_det.detection3.stops,yPos3,col3,startWV,endWV);
        
    %plot changed labels 
    if ~isempty(REMORA.lt.lEdit.detection3.chLabFalse)
        plot_chLab_wav(startWV,endWV,REMORA.lt.lEdit.detection3.chLabFalse,colF,yPos3)
    end
    if ~isempty(REMORA.lt.lEdit.detection3.chLab1)
        plot_chLab_wav(startWV,endWV,REMORA.lt.lEdit.detection3.chLab1,col1,yPos3)
    end
    if ~isempty(REMORA.lt.lEdit.detection3.chLab2)
        plot_chLab_wav(startWV,endWV,REMORA.lt.lEdit.detection3.chLab2,col2,yPos3)
    end
    if ~isempty(REMORA.lt.lEdit.detection3.chLab3)
        plot_chLab_wav(startWV,endWV,REMORA.lt.lEdit.detection3.chLab3,col3,yPos3)
    end
    if ~isempty(REMORA.lt.lEdit.detection3.chLab4)
        plot_chLab_wav(startWV,endWV,REMORA.lt.lEdit.detection3.chLab4,col4,yPos3)
    end
end

%%%plot fourth labels if desired
if REMORA.lt.lVis_det.detection4.PlotLabels
    yPos4 = plotFreq*.6;

    labl4 = REMORA.lt.lVis_det.detection4.labels(1);
    label4Pos = plotFreq*.65;
    
    plot_labels_wav(labl4,label4Pos,REMORA.lt.lVis_det.detection4.starts,REMORA.lt.lVis_det.detection4.stops,yPos4,col4,startWV,endWV);
        
    %plot changed labels 
    if ~isempty(REMORA.lt.lEdit.detection4.chLabFalse)
        plot_chLab_wav(startWV,endWV,REMORA.lt.lEdit.detection4.chLabFalse,colF,yPos4)
    end
    if ~isempty(REMORA.lt.lEdit.detection4.chLab1)
        plot_chLab_wav(startWV,endWV,REMORA.lt.lEdit.detection4.chLab1,col1,yPos4)
    end
    if ~isempty(REMORA.lt.lEdit.detection4.chLab2)
        plot_chLab_wav(startWV,endWV,REMORA.lt.lEdit.detection4.chLab2,col2,yPos4)
    end
    if ~isempty(REMORA.lt.lEdit.detection4.chLab3)
        plot_chLab_wav(startWV,endWV,REMORA.lt.lEdit.detection4.chLab3,col3,yPos4)
    end
    if ~isempty(REMORA.lt.lEdit.detection4.chLab4)
        plot_chLab_wav(startWV,endWV,REMORA.lt.lEdit.detection4.chLab4,col4,yPos4)
    end
end

function plot_labels_wav(label,labelPos,startL, stopL, yPos, color,startWV,endWV)

global PARAMS HANDLES
lablFull = [startL,stopL];

%just look for starts for click-level detections
inWin = find(lablFull(:,1)>= startWV & lablFull(:,1)<=endWV);

winDets = lablFull(inWin,:);
detstartOff = winDets(:,1) - startWV;
detXstart = lt_convertDatenum(detstartOff,'seconds'); %convert from datenum to time in SECONDS

detendOff = winDets(:,2) - startWV;
detXend = lt_convertDatenum(detendOff,'seconds');

axes (HANDLES.subplt.specgram)
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
        plot([detXstart(iPlot) detXend(iPlot)],[yPos yPos],'--','Marker','*',...
            'MarkerSize',2,'Color',color)
        text(detXstart(1),labelPos,label,'Color',color,'FontWeight','normal')
    end
end

%plot a line at the end of the detection file
if ~isempty(winDets)
    if isequal(stopL(end),winDets(end,2))
        plot([detXend(end) detXend(end)], [PARAMS.freq0 PARAMS.freq1],'-','LineWidth',2,...
            'Color',color)
    end
end

hold off


function plot_chLab_wav(startWV,endWV,chLab,col,yPos)

global PARAMS HANDLES REMORA

lablFull = chLab;

%just look for starts for click-level detections
inWin = find(lablFull(:,1)>= startWV & lablFull(:,1)<=endWV);

winDets = lablFull(inWin,:);
detstartOff = winDets(:,1) - startWV;
detXstart = lt_convertDatenum(detstartOff,'seconds'); %convert from datenum to time in SECONDS

detendOff = winDets(:,2) - startWV;
detXend = lt_convertDatenum(detendOff,'seconds');

axes (HANDLES.subplt.specgram)
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

