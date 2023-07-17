function lt_lVis_plot_LTSA_labels

global REMORA PARAMS

% get LTSA range times
% pull start and end times of window
[ltsaS,ltsaE] = lt_lVis_get_ltsa_range;
plotFreq = PARAMS.ltsa.f(end) *.9;

% plot colors
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

for labidx = 1:length(labels)
    detfld = sprintf('detection%s', labels{labidx});
    if REMORA.lt.lVis_det.(detfld).PlotLabels
        labl = REMORA.lt.lVis_det.(detfld).labels(1);
        
        
        % This ignores anything that has a start before the LTSA window
        % and a stop after the LTSA window.
        % We could check for this explicitly, but we'll just ignore it
        % as it would be slower.  We might want to pad the window a bit
        % before searching e.g. by .5 *(ltsaE - ltsaS)
        
        % Find detections that are within the LTSA window
        [Lo, Hi] = lt_lVis_get_range(ltsaS, ltsaE, ...
            REMORA.lt.lVis_det.(detfld).starts, ...
            REMORA.lt.lVis_det.(detfld).stops);
        
        %see if any detections that are long exist
        longDet = find(REMORA.lt.lVis_det.(detfld).starts<= ltsaS & ...
            REMORA.lt.lVis_det.(detfld).stops>=ltsaE);
        
        if ~isempty(longDet)
            global HANDLES
            
            %find which raw file each detection in winDet is in
            inWindowD = [ltsaS,ltsaE];
            detXstart = lt_lVis_get_LTSA_Offset(inWindowD,'starts');
            detXend = lt_lVis_get_LTSA_Offset(inWindowD,'stops');
            
            
            hold(HANDLES.subplt.ltsa, 'on')
            
            plot(HANDLES.subplt.ltsa, [detXstart detXend],[yPos yPos],'-','LineWidth',2,'Marker','*',...
                'MarkerSize',5,'Color',colors(labidx,:))
            text(HANDLES.subplt.ltsa, detXstart,labelPos,labl,'Color',colors(labidx,:),'FontWeight','normal')
            
            hold(HANDLES.subplt.ltsa, 'off');
        end
        
        if ~ isempty(Lo)
            %%% shorten detections to bout-level
            boutGap = datenum(0,0,0,0,0,15); %if spacing between start of detections...
            %is less than this, combine into a bout
            [startBouts,endBouts] = lt_lVis_defineBouts(...
                REMORA.lt.lVis_det.(detfld).starts(Lo:Hi), ...
                REMORA.lt.lVis_det.(detfld).stops(Lo:Hi), ...
                boutGap);
            
            %get final detection end and pass it into plotting for dotted
            %line
            finalDet = REMORA.lt.lVis_det.(detfld).stops(end);
            
            plot_labels_ltsa(labl, labelPos, startBouts,endBouts, ...
                yPos, colors(labidx, :), ltsaS, ltsaE,finalDet);
            
            %plot changed labels
            changedLab = REMORA.lt.lEdit.(detfld);
            for cidx = 0:8
                ch = changedLab(changedLab(:,3) == cidx, :);
                if ~ isempty(ch)
                    if cidx == 0
                        % special case not in colors matrix
                        plot_chLabels_ltsa(ltsaS, ltsaE, ch, colF, yPos);
                    else
                        plot_chLabels_ltsa(ltsaS, ltsaE, ch, colors(cidx,:), yPos);
                    end
                end
            end
        end
        
        yPos = yPos - .1*plotFreq;
        labelPos = labelPos - .1*plotFreq;
    end
end
end

function plot_labels_ltsa(label,labelPos,startL, stopL, yPos, color,ltsaS,ltsaE,finalDet)

global PARAMS HANDLES REMORA
lablFull = [startL,stopL];
winLength = HANDLES.subplt.ltsa.XLim(2);

startWin = find(startL >= ltsaS & startL <= ltsaE);
endWin = find(stopL >= ltsaS & stopL <= ltsaE);
fullDet = find(lablFull(:,1)>= ltsaS & lablFull(:,2)<=ltsaE);
% stretchDet = find(lablFull(:,1)<= ltsaS & lablFull(:,2)>=ltsaE);

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
    
    
    % Specify axes in plot/hold command rather than using
    % axes to set a default set of axes as this is much faster.
    hold(HANDLES.subplt.ltsa, 'on')
    
    %%%what kind of plotting are we going to do? Just plot a point if detection
    %%%range is shorter than 1 min... using this to simplify plotting if tlab
    %%%detections are at click level
    
    LineThresh = 1/600;
    
    for iPlot = 1:size(detXstart,1)
        detDur = detXend - detXstart;
        detXNext = [detXstart(2:end);detXstart(end)];
        %     avgDetGap = mean(detXNext - detXstart);
        detGap = detXNext - detXstart;
        longGap = [];
        %get locations to plot label text based on how far apart detections
        %are
        longGap = [1;find(detGap>=0.33*winLength)+1];
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
            plot(HANDLES.subplt.ltsa, detXstart(iPlot), yPos,'*','Color',color)
            text(HANDLES.subplt.ltsa, detXstart(longGap),posRep,...
                labelRep,'Color',color,'FontWeight','normal')
        else
            plot(HANDLES.subplt.ltsa, [detXstart(iPlot) detXend(iPlot)],[yPos yPos],'-','LineWidth',2,'Marker','*',...
                'MarkerSize',5,'Color',color)
            text(HANDLES.subplt.ltsa, detXstart(longGap),posRep,...
                labelRep,'Color',color,'FontWeight','normal')
        end
    end
    
    %plot a line at the end of the detection file
    if isequal(stopL(end),finalDet)
        plot(HANDLES.subplt.ltsa, [detXend(end) detXend(end)], ...
            [PARAMS.ltsa.f(1) PARAMS.ltsa.f(end)],':','LineWidth',2,...
            'Color',color)
    end
    
    hold(HANDLES.subplt.ltsa, 'off');
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
        detXNext = [detXstart(2:end);detXstart(end)];
        %     avgDetGap = mean(detXNext - detXstart);
        detGap = detXNext - detXstart;
        longGap = [];
        %get locations to plot label text based on how far apart detections
        %are
        longGap = [1;find(detGap>=0.33*winLength)+1];
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
            plot(detXstart(iPlot), yPos,'*','Color',color)
            text(HANDLES.subplt.ltsa, detXstart(longGap),posRep,...
                labelRep,'Color',color,'FontWeight','normal')
        else
            plot([detXstart(iPlot) detXend(iPlot)],[yPos yPos],'-','LineWidth',2,'Marker','*',...
                'MarkerSize',5,'Color',color)
            text(HANDLES.subplt.ltsa, detXstart(longGap),posRep,...
                labelRep,'Color',color,'FontWeight','normal')
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
        detXNext = [detXstart(2:end);detXstart(end)];
        %     avgDetGap = mean(detXNext - detXstart);
        detGap = detXNext - detXstart;
        longGap = [];
        %get locations to plot label text based on how far apart detections
        %are
        longGap = [1;find(detGap>=0.33*winLength)+1];
        if ~isempty(longGap)
            labelRep = repmat(label,1,length(longGap));
            posRep = repmat(labelPos,1,length(longGap));
        else
            labelRep = label;
            posRep = labelPos;
            %if no longGaps, just plot on first detection
            longGap = 1:length(1);
        end
        if abs(detDur) < LineThresh
            %just plot the start of a given detection
            plot(detXstart(iPlot), yPos,'*','Color',color)
            text(HANDLES.subplt.ltsa, detXstart(longGap),posRep,...
                labelRep,'Color',color,'FontWeight','normal')
        else
            plot([detXstart(iPlot) detXend(iPlot)],[yPos yPos],'-','LineWidth',2,'Marker','*',...
                'MarkerSize',5,'Color',color)
            text(HANDLES.subplt.ltsa, detXstart(longGap),posRep,...
                labelRep,'Color',color,'FontWeight','normal')
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

%%% shorten detections to bout-level
boutGap = datenum(0,0,0,0,0,15); %if spacing between start of detections...
%is less than this, combine into a bout
[startBouts,endBouts] = lt_lVis_defineBouts(chLab(:,1),chLab(:,2),boutGap);
lablFull = [startBouts,endBouts];

winDetsIdx = find(lablFull(:,1)>= ltsaS & lablFull(:,2)<=ltsaE);
%deal with floating-point issues. If first detection is on cusp of
%ltsaS,include anyway
if ~isempty(winDetsIdx)
    firstdet = winDetsIdx(1);
    if firstdet ~= 1 && abs(lablFull(firstdet-1,1) - ltsaS) <= 0.0001
        %include this detection in the window
        winDetsIdx = [firstdet-1;winDetsIdx];
    end
    %if last detection end is close to ltsaE, include detection
    lastdet = winDetsIdx(end);
    if lastdet ~= size(lablFull,1) && abs(lablFull(lastdet+1,2) - ltsaE) <= 0.0001
        winDetsIdx = [winDetsIdx;lastdet+1];
    end
    %if windets is empty, check if ltsaS value very close to any of labl values
elseif min(abs(lablFull(:,1) - ltsaS)) <= 0.0001
    [~,winDetsIdx] = min(abs(lablFull(:,1) - ltsaS));
else
    winDetsIdx = [];
end
winDetsFull = lablFull(winDetsIdx,:);


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
        else
            plot([detXstart(iPlot) detXend(iPlot)],[yPos yPos],'-','LineWidth',2,'Marker','*',...
                'MarkerSize',5,'Color',color)
        end
    end
    
    hold off
    
end
end
