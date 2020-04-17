function lt_lEdit_mod_chLabels(labType)

global PARAMS HANDLES REMORA

%work for either WAV or TIMESERIES window
plotFreq = PARAMS.freq1 *.9;

%for TS
if HANDLES.display.timeseries.Value
    plotMin = HANDLES.subplt.timeseries.YLim(1);
    plotMax = HANDLES.subplt.timeseries.YLim(2);
else 
    plotMin = 0;
    plotMax = 0;
end
plotCen = (plotMax+plotMin)./2;
ybuff = (plotMax-plotCen)./7;
    
% find in-window detections
startWV = PARAMS.plot.dnum;
winLength = HANDLES.subplt.specgram.XLim(2); %get length of wcindow in seconds, used to compute end limit
endWV = startWV + datenum(0,0,0,0,0,winLength);

if REMORA.lt.lVis_det.detection.PlotLabels
    yPos = plotFreq*1;
    yPos1 = plotCen + ybuff;
    if (REMORA.lt.lEdit.ychSt<=yPos && yPos<=REMORA.lt.lEdit.ychEd) || (REMORA.lt.lEdit.ychSt<=yPos1&& REMORA.lt.lEdit.ychEd>=yPos1)
        lablFull = [REMORA.lt.lVis_det.detection.starts,REMORA.lt.lVis_det.detection.stops];
        inWin = find(lablFull(:,1)>= startWV & lablFull(:,1)<=endWV);
        
        winDets = lablFull(inWin,:);
        detstartOff = winDets(:,1) - startWV;
        detXstart = lt_convertDatenum(detstartOff,'seconds'); %convert from datenum to time in SECONDS
 
        detendOff = winDets(:,2) - startWV;
        detXend = lt_convertDatenum(detendOff,'seconds');
        
        ch_Labels(detXstart,detXend,'one',labType,winDets)
    end
end

if REMORA.lt.lVis_det.detection2.PlotLabels
    yPos = plotFreq*.9;
    yPos1 = plotCen;
    if (REMORA.lt.lEdit.ychSt<=yPos && yPos<=REMORA.lt.lEdit.ychEd) || (REMORA.lt.lEdit.ychSt<=yPos1&& REMORA.lt.lEdit.ychEd>=yPos1)
        lablFull = [REMORA.lt.lVis_det.detection2.starts,REMORA.lt.lVis_det.detection2.stops];
        inWin = find(lablFull(:,1)>= startWV & lablFull(:,1)<=endWV);
        
        winDets = lablFull(inWin,:);
        detstartOff = winDets(:,1) - startWV;
        detXstart = lt_convertDatenum(detstartOff,'seconds'); %convert from datenum to time in SECONDS
        
        detendOff = winDets(:,2) - startWV;
        detXend = lt_convertDatenum(detendOff,'seconds');
        
        ch_Labels(detXstart,detXend,'two',labType,winDets)
    end
end
if REMORA.lt.lVis_det.detection3.PlotLabels
    yPos = plotFreq*.7;
    yPos1 = plotCen- ybuff;
    if (REMORA.lt.lEdit.ychSt<=yPos && yPos<=REMORA.lt.lEdit.ychEd) || (REMORA.lt.lEdit.ychSt<=yPos1&& REMORA.lt.lEdit.ychEd>=yPos1)
        lablFull = [REMORA.lt.lVis_det.detection3.starts,REMORA.lt.lVis_det.detection3.stops];
        inWin = find(lablFull(:,1)>= startWV & lablFull(:,1)<=endWV);
        
        winDets = lablFull(inWin,:);
        detstartOff = winDets(:,1) - startWV;
        detXstart = lt_convertDatenum(detstartOff,'seconds'); %convert from datenum to time in SECONDS
        
        detendOff = winDets(:,2) - startWV;
        detXend = lt_convertDatenum(detendOff,'seconds');
        
        ch_Labels(detXstart,detXend,'three',labType,winDets)
    end
end
if REMORA.lt.lVis_det.detection4.PlotLabels
    yPos = plotFreq*.6;
    yPos1 = plotCen - 2*ybuff;
    if (REMORA.lt.lEdit.ychSt<=yPos && yPos<=REMORA.lt.lEdit.ychEd) || (REMORA.lt.lEdit.ychSt<=yPos1&& REMORA.lt.lEdit.ychEd>=yPos1)
        lablFull = [REMORA.lt.lVis_det.detection4.starts,REMORA.lt.lVis_det.detection4.stops];
        inWin = find(lablFull(:,1)>= startWV & lablFull(:,1)<=endWV);
        
        winDets = lablFull(inWin,:);
        detstartOff = winDets(:,1) - startWV;
        detXstart = lt_convertDatenum(detstartOff,'seconds'); %convert from datenum to time in SECONDS
        
        detendOff = winDets(:,2) - startWV;
        detXend = lt_convertDatenum(detendOff,'seconds');
        
        ch_Labels(detXstart,detXend,'one',labType,winDets)
    end
end




function ch_Labels(starts,ends,oldLabel,newLabel,winDets)
%find new additions to changed label file

global REMORA

%find times within selected window
changeID = find(starts >=REMORA.lt.lEdit.xchSt & ends <= REMORA.lt.lEdit.xchEd);
timechST = winDets(changeID,:);

%get labels for use
labF = 'false';
if isfield(REMORA.lt.lVis_det.detection,'labels')
    lab1 = REMORA.lt.lVis_det.detection.labels(1);
end
if isfield(REMORA.lt.lVis_det.detection2,'labels')
    lab2 = REMORA.lt.lVis_det.detection2.labels(1);
end
if isfield(REMORA.lt.lVis_det.detection3,'labels')
    lab3 = REMORA.lt.lVis_det.detection3.labels(1);
end
if isfield(REMORA.lt.lVis_det.detection4,'labels')
    lab4 = REMORA.lt.lVis_det.detection4.labels(1);
end

%%add to existing changed labels
if strcmp(oldLabel,'one')
    %check if labels already present as something else
    [~,oldID]= intersect(REMORA.lt.lEdit.detection(:,1),timechST(:,1));
    if ~isempty(oldID)
        %remove whatever they were before
        REMORA.lt.lEdit.detection(oldID,:) = [];
        REMORA.lt.lEdit.detectionLab(oldID,:) = [];
    end
    if strcmp(newLabel,'false')
        newAdd = [timechST,ones(size(timechST,1),1).*0]; %save color index for plotting
        REMORA.lt.lEdit.detectionLab = [REMORA.lt.lEdit.detectionLab;repmat({labF},size(timechST,1),1)];
        REMORA.lt.lEdit.detection = [REMORA.lt.lEdit.detection;newAdd];
    elseif strcmp(newLabel,'one')
        newAdd = [timechST,ones(size(timechST,1),1).*1]; %save color index for plotting
        REMORA.lt.lEdit.detectionLab = [REMORA.lt.lEdit.detectionLab;repmat({lab1},size(timechST,1),1)];
        REMORA.lt.lEdit.detection = [REMORA.lt.lEdit.detection;newAdd];
    elseif strcmp(newLabel,'two')
        newAdd = [timechST,ones(size(timechST,1),1).*2]; %save color index for plotting
        REMORA.lt.lEdit.detectionLab = [REMORA.lt.lEdit.detectionLab;repmat({lab2},size(timechST,1),1)];
        REMORA.lt.lEdit.detection = [REMORA.lt.lEdit.detection;newAdd];
    elseif strcmp(newLabel,'three')
        newAdd = [timechST,ones(size(timechST,1),1).*3]; %save color index for plotting
        REMORA.lt.lEdit.detectionLab = [REMORA.lt.lEdit.detectionLab;repmat({lab3},size(timechST,1),1)];
        REMORA.lt.lEdit.detection = [REMORA.lt.lEdit.detection;newAdd];
    elseif strcmp(newLabel,'four')
        newAdd = [timechST,ones(size(timechST,1),1).*4]; %save color index for plotting
        REMORA.lt.lEdit.detectionLab = [REMORA.lt.lEdit.detectionLab;repmat({lab4},size(timechST,1),1)];
        REMORA.lt.lEdit.detection = [REMORA.lt.lEdit.detection;newAdd];
    end
elseif strcmp(oldLabel,'two')
    %check if labels already present as something else
    [~,oldID]= intersect(REMORA.lt.lEdit.detection2(:,1),timechST(:,1));
    if ~isempty(oldID)
        %remove whatever they were before
        REMORA.lt.lEdit.detection2(oldID,:) = [];
        REMORA.lt.lEdit.detection2Lab(oldID,:) = [];
    end
    if strcmp(newLabel,'false')
        newAdd = [timechST,ones(size(timechST,1),1).*0]; %save color index for plotting
        REMORA.lt.lEdit.detection2Lab = [REMORA.lt.lEdit.detection2Lab;repmat({labF},size(timechST,1),1)];
        REMORA.lt.lEdit.detection2 = [REMORA.lt.lEdit.detection2;newAdd];
    elseif strcmp(newLabel,'one')
        newAdd = [timechST,ones(size(timechST,1),1).*1]; %save color index for plotting
        REMORA.lt.lEdit.detection2Lab = [REMORA.lt.lEdit.detection2Lab;repmat({lab1},size(timechST,1),1)];
        REMORA.lt.lEdit.detection2 = [REMORA.lt.lEdit.detection2;newAdd];
    elseif strcmp(newLabel,'two')
        newAdd = [timechST,ones(size(timechST,1),1).*2]; %save color index for plotting
        REMORA.lt.lEdit.detection2Lab = [REMORA.lt.lEdit.detection2Lab;repmat({lab2},size(timechST,1),1)];
        REMORA.lt.lEdit.detection2 = [REMORA.lt.lEdit.detection2;newAdd];
    elseif strcmp(newLabel,'three')
        newAdd = [timechST,ones(size(timechST,1),1).*3]; %save color index for plotting
        REMORA.lt.lEdit.detection2Lab = [REMORA.lt.lEdit.detection2Lab;repmat({lab3},size(timechST,1),1)];
        REMORA.lt.lEdit.detection2 = [REMORA.lt.lEdit.detection2;newAdd];
    elseif strcmp(newLabel,'four')
        newAdd = [timechST,ones(size(timechST,1),1).*4]; %save color index for plotting
        REMORA.lt.lEdit.detection2Lab = [REMORA.lt.lEdit.detection2Lab;repmat({lab4},size(timechST,1),1)];
        REMORA.lt.lEdit.detection2 = [REMORA.lt.lEdit.detection2;newAdd];
    end
elseif strcmp(oldLabel,'three')
    %check if labels already present as something else
    [~,oldID]= intersect(REMORA.lt.lEdit.detection3(:,1),timechST(:,1));
    if ~isempty(oldID)
        %remove whatever they were before
        REMORA.lt.lEdit.detection3(oldID,:) = [];
        REMORA.lt.lEdit.detection3Lab(oldID,:) = [];
    end
    if strcmp(newLabel,'false')
        newAdd = [timechST,ones(size(timechST,1),1).*0]; %save color index for plotting
        REMORA.lt.lEdit.detection3Lab = [REMORA.lt.lEdit.detection3Lab;repmat({labF},size(timechST,1),1)];
        REMORA.lt.lEdit.detection3 = [REMORA.lt.lEdit.detection3;newAdd];
    elseif strcmp(newLabel,'one')
        newAdd = [timechST,ones(size(timechST,1),1).*1]; %save color index for plotting
        REMORA.lt.lEdit.detection3Lab = [REMORA.lt.lEdit.detection3Lab;repmat({lab1},size(timechST,1),1)];
        REMORA.lt.lEdit.detection3 = [REMORA.lt.lEdit.detection3;newAdd];
    elseif strcmp(newLabel,'two')
        newAdd = [timechST,ones(size(timechST,1),1).*2]; %save color index for plotting
        REMORA.lt.lEdit.detection3Lab = [REMORA.lt.lEdit.detection3Lab;repmat({lab2},size(timechST,1),1)];
        REMORA.lt.lEdit.detection3 = [REMORA.lt.lEdit.detection3;newAdd];
    elseif strcmp(newLabel,'three')
        newAdd = [timechST,ones(size(timechST,1),1).*3]; %save color index for plotting
        REMORA.lt.lEdit.detection3Lab = [REMORA.lt.lEdit.detection3Lab;repmat({lab3},size(timechST,1),1)];
        REMORA.lt.lEdit.detection3 = [REMORA.lt.lEdit.detection3;newAdd];
    elseif strcmp(newLabel,'four')
        newAdd = [timechST,ones(size(timechST,1),1).*4]; %save color index for plotting
        REMORA.lt.lEdit.detection3Lab = [REMORA.lt.lEdit.detection3Lab;repmat({lab4},size(timechST,1),1)];
        REMORA.lt.lEdit.detection3 = [REMORA.lt.lEdit.detection3;newAdd];
    end
elseif strcmp(oldLabel,'four')
    %check if labels already present as something else
    [~,oldID]= intersect(REMORA.lt.lEdit.detection4(:,1),timechST(:,1));
    if ~isempty(oldID)
        %remove whatever they were before
        REMORA.lt.lEdit.detection4(oldID,:) = [];
        REMORA.lt.lEdit.detection4Lab(oldID,:) = [];
    end
    if strcmp(newLabel,'false')
        newAdd = [timechST,ones(size(timechST,1),1).*0]; %save color index for plotting
        REMORA.lt.lEdit.detection4Lab = [REMORA.lt.lEdit.detection4Lab;repmat({labF},size(timechST,1),1)];
        REMORA.lt.lEdit.detection4 = [REMORA.lt.lEdit.detection4;newAdd];
    elseif strcmp(newLabel,'one')
        newAdd = [timechST,ones(size(timechST,1),1).*1]; %save color index for plotting
        REMORA.lt.lEdit.detection4Lab = [REMORA.lt.lEdit.detection4Lab;repmat({lab1},size(timechST,1),1)];
        REMORA.lt.lEdit.detection4 = [REMORA.lt.lEdit.detection4;newAdd];
    elseif strcmp(newLabel,'two')
        newAdd = [timechST,ones(size(timechST,1),1).*2]; %save color index for plotting
        REMORA.lt.lEdit.detection4Lab = [REMORA.lt.lEdit.detection4Lab;repmat({lab2},size(timechST,1),1)];
        REMORA.lt.lEdit.detection4 = [REMORA.lt.lEdit.detection4;newAdd];
    elseif strcmp(newLabel,'three')
        newAdd = [timechST,ones(size(timechST,1),1).*3]; %save color index for plotting
        REMORA.lt.lEdit.detection4Lab = [REMORA.lt.lEdit.detection4Lab;repmat({lab3},size(timechST,1),1)];
        REMORA.lt.lEdit.detection4 = [REMORA.lt.lEdit.detection4;newAdd];
    elseif strcmp(newLabel,'four')
        newAdd = [timechST,ones(size(timechST,1),1).*4]; %save color index for plotting
        REMORA.lt.lEdit.detection4Lab = [REMORA.lt.lEdit.detection4Lab;repmat({lab4},size(timechST,1),1)];
        REMORA.lt.lEdit.detection4 = [REMORA.lt.lEdit.detection4;newAdd];
    end
end

