function lt_lVis_plot_WAV_labels

global REMORA PARAMS HANDLES


%create start and end times of window
startWV = PARAMS.plot.dnum;
winLength = HANDLES.subplt.specgram.XLim(2); %get length of window in seconds, used to compute end limit
endWV = startWV + datenum(0,0,0,0,0,winLength);

plotFreq = PARAMS.freq1 *.9;
colF = [1 0 0];
colors = [
    1.0 1.0 1.0
    0.8 0.4 0.8
    1.0 0.6 0.0
    0.8 0.6 1.0
    0.8 1.0 1.0
    1.0 0.0 0.4
    1.0 0.6 0.6
    1.0 0.6 0.2
    ];

% detection groups
labels = {'', '2', '3', '4', '5', '6', '7', '8'};

% position for lines and labels
yPos = plotFreq;
labelPos = yPos*1.05;
ydelta = plotFreq * .10;  % Move plot down for each group
for labidx = 1:length(labels);
    detfld = sprintf('detection%s', labels{labidx});
    if REMORA.lt.lVis_det.(detfld).PlotLabels
        labl = REMORA.lt.lVis_det.(detfld).labels(1);
        
        % This ignores anything that has a start before the LTSA window
        % and a stop after the LTSA window.
        % We could check for this explicitly, but we'll just ignore it
        % as it would be slower.  We might want to pad the window a bit
        % before searching e.g. by .5 *(ltsaE - ltsaS)
        
        % Find detections that are within the timeseries window
        [Lo, Hi] = lt_lVis_get_range(startWV, endWV, ...
            REMORA.lt.lVis_det.(detfld).starts, ...
            REMORA.lt.lVis_det.(detfld).stops);
        %get final detection end and pass it into plotting for dotted
        %line
        finalDet = REMORA.lt.lVis_det.(detfld).stops(end);
        
        if ~ isempty(Lo)
            plot_labels_wav(labl,labelPos, ...
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
winLength = HANDLES.subplt.specgram.XLim(2);

%just look for starts for click-level detections
inWin = find(lablFull(:,1)>= startWV & lablFull(:,1)<=endWV);

winDets = lablFull(inWin,:);
detstartOff = winDets(:,1) - startWV;
detXstart = lt_convertDatenum(detstartOff,'seconds'); %convert from datenum to time in SECONDS

detendOff = winDets(:,2) - startWV;
detXend = lt_convertDatenum(detendOff,'seconds');

detDur = detXend - detXstart;

hold(HANDLES.subplt.specgram, 'on');

%%%what kind of plotting are we going to do? Just plot a point if detection
%%%range is shorter than 1 s... using this as a proxy for tlab where
%%%detections are at click level

LineThresh = 1;

for iPlot = 1:size(detXstart,1)
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
    if detDur(iPlot) < LineThresh
        %just plot the start of a given detection
        plot(HANDLES.subplt.specgram, detXstart(iPlot), yPos,'*','Color',color)
        text(HANDLES.subplt.specgram, detXstart(longGap),posRep,...
            labelRep,'Color',color,'FontWeight','normal')
    else
        plot(HANDLES.subplt.specgram, ...
            [detXstart(iPlot) detXend(iPlot)],[yPos yPos],'--','Marker','*',...
            'MarkerSize',2,'Color',color)
        text(HANDLES.subplt.specgram, detXstart(longGap),posRep,...
            labelRep,'Color',color,'FontWeight','normal')
    end
end

%plot a line at the end of the detection file
if ~isempty(winDets)
    if isequal(stopL(end),finalDet)
        plot(HANDLES.subplt.specgram, [detXend(end) detXend(end)], [PARAMS.freq0 PARAMS.freq1],':','LineWidth',2,...
            'Color',color)
    end
end

hold(HANDLES.subplt.specgram, 'off');


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

hold(HANDLES.subplt.specgram, 'on');

%%%what kind of plotting are we going to do? Just plot a point if detection
%%%range is shorter than 1 min... using this as a proxy for tlab where
%%%detections are at click level

LineThresh = 1*60;

for iPlot = 1:size(detXstart,1)
    detDur = detXend - detXstart;
    if detDur < LineThresh
        %just plot the start of a given detection
        plot(HANDLES.subplt.specgram, detXstart(iPlot), yPos,'*','Color',col)
    else
        plot(HANDLES.subplt.specgram, [detXstart(iPlot) detXend(iPlot)],[yPos yPos],'--','Marker','*',...
            'MarkerSize',2,'Color',col)
    end
end

hold(HANDLES.subplt.specgram, 'off');

