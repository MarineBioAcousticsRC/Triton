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
if HANDLES.display.specgram.Value==1
    winLength = HANDLES.subplt.specgram.XLim(2); %get length of wcindow in seconds, used to compute end limit
else
    winLength = HANDLES.subplt.timeseries.XLim(2);
end
endWV = startWV + datenum(0,0,0,0,0,winLength);

if REMORA.lt.lVis_det.detection.PlotLabels
    yPos = plotFreq*1;
    yPos1 = plotCen + 3*ybuff;
    if (REMORA.lt.lEdit.ychSt<=yPos && yPos<=REMORA.lt.lEdit.ychEd) || (REMORA.lt.lEdit.ychSt<=yPos1&& REMORA.lt.lEdit.ychEd>=yPos1)
        lablFull = [REMORA.lt.lVis_det.detection.starts,REMORA.lt.lVis_det.detection.stops];
        inWin = find(lablFull(:,1)>= startWV & lablFull(:,1)<=endWV);
        
        winDets = lablFull(inWin,:);
        if ~isempty(winDets)
            detstartOff = winDets(:,1) - startWV;
            detXstart = lt_convertDatenum(detstartOff,'seconds'); %convert from datenum to time in SECONDS
            
            detendOff = winDets(:,2) - startWV;
            detXend = lt_convertDatenum(detendOff,'seconds');
            
            ch_Labels(detXstart,detXend,'one',labType,winDets)
        end
    end
end

if REMORA.lt.lVis_det.detection2.PlotLabels
    yPos = plotFreq*.9;
    yPos1 = plotCen+2*ybuff;
    if (REMORA.lt.lEdit.ychSt<=yPos && yPos<=REMORA.lt.lEdit.ychEd) || (REMORA.lt.lEdit.ychSt<=yPos1&& REMORA.lt.lEdit.ychEd>=yPos1)
        lablFull = [REMORA.lt.lVis_det.detection2.starts,REMORA.lt.lVis_det.detection2.stops];
        inWin = find(lablFull(:,1)>= startWV & lablFull(:,1)<=endWV);
        
        winDets = lablFull(inWin,:);
        if ~isempty(winDets)
            detstartOff = winDets(:,1) - startWV;
            detXstart = lt_convertDatenum(detstartOff,'seconds'); %convert from datenum to time in SECONDS
            
            detendOff = winDets(:,2) - startWV;
            detXend = lt_convertDatenum(detendOff,'seconds');
            
            ch_Labels(detXstart,detXend,'two',labType,winDets)
        end
    end
end
if REMORA.lt.lVis_det.detection3.PlotLabels
    yPos = plotFreq*.7;
    yPos1 = plotCen+ybuff;
    if (REMORA.lt.lEdit.ychSt<=yPos && yPos<=REMORA.lt.lEdit.ychEd) || (REMORA.lt.lEdit.ychSt<=yPos1&& REMORA.lt.lEdit.ychEd>=yPos1)
        lablFull = [REMORA.lt.lVis_det.detection3.starts,REMORA.lt.lVis_det.detection3.stops];
        inWin = find(lablFull(:,1)>= startWV & lablFull(:,1)<=endWV);
        
        winDets = lablFull(inWin,:);
        if ~isempty(winDets)
            detstartOff = winDets(:,1) - startWV;
            detXstart = lt_convertDatenum(detstartOff,'seconds'); %convert from datenum to time in SECONDS
            
            detendOff = winDets(:,2) - startWV;
            detXend = lt_convertDatenum(detendOff,'seconds');
            
            ch_Labels(detXstart,detXend,'three',labType,winDets)
        end
    end
end
if REMORA.lt.lVis_det.detection4.PlotLabels
    yPos = plotFreq*.6;
    yPos1 = plotCen;
    if (REMORA.lt.lEdit.ychSt<=yPos && yPos<=REMORA.lt.lEdit.ychEd) || (REMORA.lt.lEdit.ychSt<=yPos1&& REMORA.lt.lEdit.ychEd>=yPos1)
        lablFull = [REMORA.lt.lVis_det.detection4.starts,REMORA.lt.lVis_det.detection4.stops];
        inWin = find(lablFull(:,1)>= startWV & lablFull(:,1)<=endWV);
        
        winDets = lablFull(inWin,:);
        if ~isempty(winDets)
            detstartOff = winDets(:,1) - startWV;
            detXstart = lt_convertDatenum(detstartOff,'seconds'); %convert from datenum to time in SECONDS
            
            detendOff = winDets(:,2) - startWV;
            detXend = lt_convertDatenum(detendOff,'seconds');
            
            ch_Labels(detXstart,detXend,'four',labType,winDets)
        end
    end
end
if REMORA.lt.lVis_det.detection5.PlotLabels
    yPos = plotFreq*.5;
    yPos1 = plotCen - ybuff;
    if (REMORA.lt.lEdit.ychSt<=yPos && yPos<=REMORA.lt.lEdit.ychEd) || (REMORA.lt.lEdit.ychSt<=yPos1&& REMORA.lt.lEdit.ychEd>=yPos1)
        lablFull = [REMORA.lt.lVis_det.detection5.starts,REMORA.lt.lVis_det.detection5.stops];
        inWin = lablFull(lablFull(:,1)>= startWV & lablFull(:,1)<=endWV);
        
        winDets = lablFull(inWin,:);
        if ~isempty(winDets)
            detstartOff = winDets(:,1) - startWV;
            detXstart = lt_convertDatenum(detstartOff,'seconds'); %convert from datenum to time in SECONDS
            
            detendOff = winDets(:,2) - startWV;
            detXend = lt_convertDatenum(detendOff,'seconds');
            
            ch_Labels(detXstart,detXend,'five',labType,winDets)
        end
    end
end
if REMORA.lt.lVis_det.detection6.PlotLabels
    yPos = plotFreq*.4;
    yPos1 = plotCen - 2*ybuff;
    if (REMORA.lt.lEdit.ychSt<=yPos && yPos<=REMORA.lt.lEdit.ychEd) || (REMORA.lt.lEdit.ychSt<=yPos1&& REMORA.lt.lEdit.ychEd>=yPos1)
        lablFull = [REMORA.lt.lVis_det.detection6.starts,REMORA.lt.lVis_det.detection6.stops];
        inWin = find(lablFull(:,1)>= startWV & lablFull(:,1)<=endWV);
        
        winDets = lablFull(inWin,:);
        if ~isempty(winDets)
            detstartOff = winDets(:,1) - startWV;
            detXstart = lt_convertDatenum(detstartOff,'seconds'); %convert from datenum to time in SECONDS
            
            detendOff = winDets(:,2) - startWV;
            detXend = lt_convertDatenum(detendOff,'seconds');
            
            ch_Labels(detXstart,detXend,'six',labType,winDets)
        end
    end
end
if REMORA.lt.lVis_det.detection7.PlotLabels
    yPos = plotFreq*.3;
    yPos1 = plotCen - 3*ybuff;
    if (REMORA.lt.lEdit.ychSt<=yPos && yPos<=REMORA.lt.lEdit.ychEd) || (REMORA.lt.lEdit.ychSt<=yPos1&& REMORA.lt.lEdit.ychEd>=yPos1)
        lablFull = [REMORA.lt.lVis_det.detection7.starts,REMORA.lt.lVis_det.detection7.stops];
        inWin = find(lablFull(:,1)>= startWV & lablFull(:,1)<=endWV);
        
        winDets = lablFull(inWin,:);
        if ~isempty(winDets)
            detstartOff = winDets(:,1) - startWV;
            detXstart = lt_convertDatenum(detstartOff,'seconds'); %convert from datenum to time in SECONDS
            
            detendOff = winDets(:,2) - startWV;
            detXend = lt_convertDatenum(detendOff,'seconds');
            
            ch_Labels(detXstart,detXend,'sev',labType,winDets)
        end
    end
end
if REMORA.lt.lVis_det.detection8.PlotLabels
    yPos = plotFreq*.2;
    yPos1 = plotCen - 4*ybuff;
    if (REMORA.lt.lEdit.ychSt<=yPos && yPos<=REMORA.lt.lEdit.ychEd) || (REMORA.lt.lEdit.ychSt<=yPos1&& REMORA.lt.lEdit.ychEd>=yPos1)
        lablFull = [REMORA.lt.lVis_det.detection8.starts,REMORA.lt.lVis_det.detection8.stops];
        inWin = find(lablFull(:,1)>= startWV & lablFull(:,1)<=endWV);
        
        winDets = lablFull(inWin,:);
        if ~isempty(winDets)
            detstartOff = winDets(:,1) - startWV;
            detXstart = lt_convertDatenum(detstartOff,'seconds'); %convert from datenum to time in SECONDS
            
            detendOff = winDets(:,2) - startWV;
            detXend = lt_convertDatenum(detendOff,'seconds');
            
            ch_Labels(detXstart,detXend,'eight',labType,winDets)
        end
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
if isfield(REMORA.lt.lVis_det.detection5,'labels')
    lab5 = REMORA.lt.lVis_det.detection5.labels(1);
end
if isfield(REMORA.lt.lVis_det.detection6,'labels')
    lab6 = REMORA.lt.lVis_det.detection6.labels(1);
end
if isfield(REMORA.lt.lVis_det.detection7,'labels')
    lab7 = REMORA.lt.lVis_det.detection7.labels(1);
end
if isfield(REMORA.lt.lVis_det.detection8,'labels')
    lab8 = REMORA.lt.lVis_det.detection8.labels(1);
end

% add to existing changed labels
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
    elseif strcmp(newLabel,'five')
        newAdd = [timechST,ones(size(timechST,1),1).*4]; %save color index for plotting
        REMORA.lt.lEdit.detectionLab = [REMORA.lt.lEdit.detectionLab;repmat({lab5},size(timechST,1),1)];
        REMORA.lt.lEdit.detection = [REMORA.lt.lEdit.detection;newAdd];
    elseif strcmp(newLabel,'six')
        newAdd = [timechST,ones(size(timechST,1),1).*4]; %save color index for plotting
        REMORA.lt.lEdit.detectionLab = [REMORA.lt.lEdit.detectionLab;repmat({lab6},size(timechST,1),1)];
        REMORA.lt.lEdit.detection = [REMORA.lt.lEdit.detection;newAdd];
    elseif strcmp(newLabel,'sev')
        newAdd = [timechST,ones(size(timechST,1),1).*4]; %save color index for plotting
        REMORA.lt.lEdit.detectionLab = [REMORA.lt.lEdit.detectionLab;repmat({lab7},size(timechST,1),1)];
        REMORA.lt.lEdit.detection = [REMORA.lt.lEdit.detection;newAdd];
    elseif strcmp(newLabel,'eight')
        newAdd = [timechST,ones(size(timechST,1),1).*4]; %save color index for plotting
        REMORA.lt.lEdit.detectionLab = [REMORA.lt.lEdit.detectionLab;repmat({lab8},size(timechST,1),1)];
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
    elseif strcmp(newLabel,'five')
        newAdd = [timechST,ones(size(timechST,1),1).*5]; %save color index for plotting
        REMORA.lt.lEdit.detection2Lab = [REMORA.lt.lEdit.detection2Lab;repmat({lab5},size(timechST,1),1)];
        REMORA.lt.lEdit.detection2 = [REMORA.lt.lEdit.detection2;newAdd];
    elseif strcmp(newLabel,'six')
        newAdd = [timechST,ones(size(timechST,1),1).*6]; %save color index for plotting
        REMORA.lt.lEdit.detection2Lab = [REMORA.lt.lEdit.detection2Lab;repmat({lab6},size(timechST,1),1)];
        REMORA.lt.lEdit.detection2 = [REMORA.lt.lEdit.detection2;newAdd];
    elseif strcmp(newLabel,'sev')
        newAdd = [timechST,ones(size(timechST,1),1).*7]; %save color index for plotting
        REMORA.lt.lEdit.detection2Lab = [REMORA.lt.lEdit.detection2Lab;repmat({lab7},size(timechST,1),1)];
        REMORA.lt.lEdit.detection2 = [REMORA.lt.lEdit.detection2;newAdd];
    elseif strcmp(newLabel,'eight')
        newAdd = [timechST,ones(size(timechST,1),1).*8]; %save color index for plotting
        REMORA.lt.lEdit.detection2Lab = [REMORA.lt.lEdit.detection2Lab;repmat({lab8},size(timechST,1),1)];
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
    elseif strcmp(newLabel,'five')
        newAdd = [timechST,ones(size(timechST,1),1).*5]; %save color index for plotting
        REMORA.lt.lEdit.detection3Lab = [REMORA.lt.lEdit.detection3Lab;repmat({lab5},size(timechST,1),1)];
        REMORA.lt.lEdit.detection3 = [REMORA.lt.lEdit.detection3;newAdd];
    elseif strcmp(newLabel,'six')
        newAdd = [timechST,ones(size(timechST,1),1).*6]; %save color index for plotting
        REMORA.lt.lEdit.detection3Lab = [REMORA.lt.lEdit.detection3Lab;repmat({lab6},size(timechST,1),1)];
        REMORA.lt.lEdit.detection3 = [REMORA.lt.lEdit.detection3;newAdd];
    elseif strcmp(newLabel,'sev')
        newAdd = [timechST,ones(size(timechST,1),1).*7]; %save color index for plotting
        REMORA.lt.lEdit.detection3Lab = [REMORA.lt.lEdit.detection3Lab;repmat({lab7},size(timechST,1),1)];
        REMORA.lt.lEdit.detection3 = [REMORA.lt.lEdit.detection3;newAdd];
    elseif strcmp(newLabel,'eight')
        newAdd = [timechST,ones(size(timechST,1),1).*8]; %save color index for plotting
        REMORA.lt.lEdit.detection3Lab = [REMORA.lt.lEdit.detection3Lab;repmat({lab8},size(timechST,1),1)];
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
    elseif strcmp(newLabel,'five')
        newAdd = [timechST,ones(size(timechST,1),1).*5]; %save color index for plotting
        REMORA.lt.lEdit.detection4Lab = [REMORA.lt.lEdit.detection4Lab;repmat({lab5},size(timechST,1),1)];
        REMORA.lt.lEdit.detection4 = [REMORA.lt.lEdit.detection4;newAdd];
    elseif strcmp(newLabel,'six')
        newAdd = [timechST,ones(size(timechST,1),1).*6]; %save color index for plotting
        REMORA.lt.lEdit.detection4Lab = [REMORA.lt.lEdit.detection4Lab;repmat({lab6},size(timechST,1),1)];
        REMORA.lt.lEdit.detection4 = [REMORA.lt.lEdit.detection4;newAdd];
    elseif strcmp(newLabel,'sev')
        newAdd = [timechST,ones(size(timechST,1),1).*7]; %save color index for plotting
        REMORA.lt.lEdit.detection4Lab = [REMORA.lt.lEdit.detection4Lab;repmat({lab7},size(timechST,1),1)];
        REMORA.lt.lEdit.detection4 = [REMORA.lt.lEdit.detection4;newAdd];
    elseif strcmp(newLabel,'eight')
        newAdd = [timechST,ones(size(timechST,1),1).*8]; %save color index for plotting
        REMORA.lt.lEdit.detection4Lab = [REMORA.lt.lEdit.detection4Lab;repmat({lab8},size(timechST,1),1)];
        REMORA.lt.lEdit.detection4 = [REMORA.lt.lEdit.detection4;newAdd];
    end
    
elseif strcmp(oldLabel,'five')
    %check if labels already present as something else
    [~,oldID]= intersect(REMORA.lt.lEdit.detection5(:,1),timechST(:,1));
    if ~isempty(oldID)
        %remove whatever they were before
        REMORA.lt.lEdit.detection5(oldID,:) = [];
        REMORA.lt.lEdit.detection5Lab(oldID,:) = [];
    end
    if strcmp(newLabel,'false')
        newAdd = [timechST,ones(size(timechST,1),1).*0]; %save color index for plotting
        REMORA.lt.lEdit.detection5Lab = [REMORA.lt.lEdit.detection5Lab;repmat({labF},size(timechST,1),1)];
        REMORA.lt.lEdit.detection5 = [REMORA.lt.lEdit.detection5;newAdd];
    elseif strcmp(newLabel,'one')
        newAdd = [timechST,ones(size(timechST,1),1).*1]; %save color index for plotting
        REMORA.lt.lEdit.detection5Lab = [REMORA.lt.lEdit.detection5Lab;repmat({lab1},size(timechST,1),1)];
        REMORA.lt.lEdit.detection5 = [REMORA.lt.lEdit.detection5;newAdd];
    elseif strcmp(newLabel,'two')
        newAdd = [timechST,ones(size(timechST,1),1).*2]; %save color index for plotting
        REMORA.lt.lEdit.detection5Lab = [REMORA.lt.lEdit.detection5Lab;repmat({lab2},size(timechST,1),1)];
        REMORA.lt.lEdit.detection5 = [REMORA.lt.lEdit.detection5;newAdd];
    elseif strcmp(newLabel,'three')
        newAdd = [timechST,ones(size(timechST,1),1).*3]; %save color index for plotting
        REMORA.lt.lEdit.detection5Lab = [REMORA.lt.lEdit.detection5Lab;repmat({lab3},size(timechST,1),1)];
        REMORA.lt.lEdit.detection5 = [REMORA.lt.lEdit.detection5;newAdd];
    elseif strcmp(newLabel,'four')
        newAdd = [timechST,ones(size(timechST,1),1).*4]; %save color index for plotting
        REMORA.lt.lEdit.detection5Lab = [REMORA.lt.lEdit.detection5Lab;repmat({lab4},size(timechST,1),1)];
        REMORA.lt.lEdit.detection5 = [REMORA.lt.lEdit.detection5;newAdd];
    elseif strcmp(newLabel,'five')
        newAdd = [timechST,ones(size(timechST,1),1).*5]; %save color index for plotting
        REMORA.lt.lEdit.detection5Lab = [REMORA.lt.lEdit.detection5Lab;repmat({lab5},size(timechST,1),1)];
        REMORA.lt.lEdit.detection5 = [REMORA.lt.lEdit.detection5;newAdd];
    elseif strcmp(newLabel,'six')
        newAdd = [timechST,ones(size(timechST,1),1).*6]; %save color index for plotting
        REMORA.lt.lEdit.detection5Lab = [REMORA.lt.lEdit.detection5Lab;repmat({lab6},size(timechST,1),1)];
        REMORA.lt.lEdit.detection5 = [REMORA.lt.lEdit.detection5;newAdd];
    elseif strcmp(newLabel,'sev')
        newAdd = [timechST,ones(size(timechST,1),1).*7]; %save color index for plotting
        REMORA.lt.lEdit.detection5Lab = [REMORA.lt.lEdit.detection5Lab;repmat({lab7},size(timechST,1),1)];
        REMORA.lt.lEdit.detection5 = [REMORA.lt.lEdit.detection5;newAdd];
    elseif strcmp(newLabel,'eight')
        newAdd = [timechST,ones(size(timechST,1),1).*8]; %save color index for plotting
        REMORA.lt.lEdit.detection5Lab = [REMORA.lt.lEdit.detection5Lab;repmat({lab8},size(timechST,1),1)];
        REMORA.lt.lEdit.detection5 = [REMORA.lt.lEdit.detection5;newAdd];
    end
elseif strcmp(oldLabel,'six')
    %check if labels already present as something else
    [~,oldID]= intersect(REMORA.lt.lEdit.detection6(:,1),timechST(:,1));
    if ~isempty(oldID)
        %remove whatever they were before
        REMORA.lt.lEdit.detection6(oldID,:) = [];
        REMORA.lt.lEdit.detection6Lab(oldID,:) = [];
    end
    if strcmp(newLabel,'false')
        newAdd = [timechST,ones(size(timechST,1),1).*0]; %save color index for plotting
        REMORA.lt.lEdit.detection6Lab = [REMORA.lt.lEdit.detection6Lab;repmat({labF},size(timechST,1),1)];
        REMORA.lt.lEdit.detection6 = [REMORA.lt.lEdit.detection6;newAdd];
    elseif strcmp(newLabel,'one')
        newAdd = [timechST,ones(size(timechST,1),1).*1]; %save color index for plotting
        REMORA.lt.lEdit.detection6Lab = [REMORA.lt.lEdit.detection6Lab;repmat({lab1},size(timechST,1),1)];
        REMORA.lt.lEdit.detection6 = [REMORA.lt.lEdit.detection6;newAdd];
    elseif strcmp(newLabel,'two')
        newAdd = [timechST,ones(size(timechST,1),1).*2]; %save color index for plotting
        REMORA.lt.lEdit.detection6Lab = [REMORA.lt.lEdit.detection6Lab;repmat({lab2},size(timechST,1),1)];
        REMORA.lt.lEdit.detection6 = [REMORA.lt.lEdit.detection6;newAdd];
    elseif strcmp(newLabel,'three')
        newAdd = [timechST,ones(size(timechST,1),1).*3]; %save color index for plotting
        REMORA.lt.lEdit.detection6Lab = [REMORA.lt.lEdit.detection6Lab;repmat({lab3},size(timechST,1),1)];
        REMORA.lt.lEdit.detection6 = [REMORA.lt.lEdit.detection6;newAdd];
    elseif strcmp(newLabel,'four')
        newAdd = [timechST,ones(size(timechST,1),1).*4]; %save color index for plotting
        REMORA.lt.lEdit.detection6Lab = [REMORA.lt.lEdit.detection6Lab;repmat({lab4},size(timechST,1),1)];
        REMORA.lt.lEdit.detection6 = [REMORA.lt.lEdit.detection6;newAdd];
    elseif strcmp(newLabel,'five')
        newAdd = [timechST,ones(size(timechST,1),1).*5]; %save color index for plotting
        REMORA.lt.lEdit.detection6Lab = [REMORA.lt.lEdit.detection6Lab;repmat({lab5},size(timechST,1),1)];
        REMORA.lt.lEdit.detection6 = [REMORA.lt.lEdit.detection6;newAdd];
    elseif strcmp(newLabel,'six')
        newAdd = [timechST,ones(size(timechST,1),1).*6]; %save color index for plotting
        REMORA.lt.lEdit.detection6Lab = [REMORA.lt.lEdit.detection6Lab;repmat({lab6},size(timechST,1),1)];
        REMORA.lt.lEdit.detection6 = [REMORA.lt.lEdit.detection6;newAdd];
    elseif strcmp(newLabel,'sev')
        newAdd = [timechST,ones(size(timechST,1),1).*7]; %save color index for plotting
        REMORA.lt.lEdit.detection6Lab = [REMORA.lt.lEdit.detection6Lab;repmat({lab7},size(timechST,1),1)];
        REMORA.lt.lEdit.detection6 = [REMORA.lt.lEdit.detection6;newAdd];
    elseif strcmp(newLabel,'eight')
        newAdd = [timechST,ones(size(timechST,1),1).*8]; %save color index for plotting
        REMORA.lt.lEdit.detection6Lab = [REMORA.lt.lEdit.detection6Lab;repmat({lab8},size(timechST,1),1)];
        REMORA.lt.lEdit.detection6 = [REMORA.lt.lEdit.detection6;newAdd];
    end
elseif strcmp(oldLabel,'sev')
    %check if labels already present as something else
    [~,oldID]= intersect(REMORA.lt.lEdit.detection7(:,1),timechST(:,1));
    if ~isempty(oldID)
        %remove whatever they were before
        REMORA.lt.lEdit.detection7(oldID,:) = [];
        REMORA.lt.lEdit.detection7Lab(oldID,:) = [];
    end
    if strcmp(newLabel,'false')
        newAdd = [timechST,ones(size(timechST,1),1).*0]; %save color index for plotting
        REMORA.lt.lEdit.detection7Lab = [REMORA.lt.lEdit.detection7Lab;repmat({labF},size(timechST,1),1)];
        REMORA.lt.lEdit.detection7 = [REMORA.lt.lEdit.detection7;newAdd];
    elseif strcmp(newLabel,'one')
        newAdd = [timechST,ones(size(timechST,1),1).*1]; %save color index for plotting
        REMORA.lt.lEdit.detection7Lab = [REMORA.lt.lEdit.detection7Lab;repmat({lab1},size(timechST,1),1)];
        REMORA.lt.lEdit.detection7 = [REMORA.lt.lEdit.detection7;newAdd];
    elseif strcmp(newLabel,'two')
        newAdd = [timechST,ones(size(timechST,1),1).*2]; %save color index for plotting
        REMORA.lt.lEdit.detection7Lab = [REMORA.lt.lEdit.detection7Lab;repmat({lab2},size(timechST,1),1)];
        REMORA.lt.lEdit.detection7 = [REMORA.lt.lEdit.detection7;newAdd];
    elseif strcmp(newLabel,'three')
        newAdd = [timechST,ones(size(timechST,1),1).*3]; %save color index for plotting
        REMORA.lt.lEdit.detection7Lab = [REMORA.lt.lEdit.detection7Lab;repmat({lab3},size(timechST,1),1)];
        REMORA.lt.lEdit.detection7 = [REMORA.lt.lEdit.detection7;newAdd];
    elseif strcmp(newLabel,'four')
        newAdd = [timechST,ones(size(timechST,1),1).*4]; %save color index for plotting
        REMORA.lt.lEdit.detection7Lab = [REMORA.lt.lEdit.detection7Lab;repmat({lab4},size(timechST,1),1)];
        REMORA.lt.lEdit.detection7 = [REMORA.lt.lEdit.detection7;newAdd];
    elseif strcmp(newLabel,'five')
        newAdd = [timechST,ones(size(timechST,1),1).*5]; %save color index for plotting
        REMORA.lt.lEdit.detection7Lab = [REMORA.lt.lEdit.detection7Lab;repmat({lab5},size(timechST,1),1)];
        REMORA.lt.lEdit.detection7 = [REMORA.lt.lEdit.detection7;newAdd];
    elseif strcmp(newLabel,'six')
        newAdd = [timechST,ones(size(timechST,1),1).*6]; %save color index for plotting
        REMORA.lt.lEdit.detection7Lab = [REMORA.lt.lEdit.detection7Lab;repmat({lab6},size(timechST,1),1)];
        REMORA.lt.lEdit.detection7 = [REMORA.lt.lEdit.detection7;newAdd];
    elseif strcmp(newLabel,'sev')
        newAdd = [timechST,ones(size(timechST,1),1).*7]; %save color index for plotting
        REMORA.lt.lEdit.detection7Lab = [REMORA.lt.lEdit.detection7Lab;repmat({lab7},size(timechST,1),1)];
        REMORA.lt.lEdit.detection7 = [REMORA.lt.lEdit.detection7;newAdd];
    elseif strcmp(newLabel,'eight')
        newAdd = [timechST,ones(size(timechST,1),1).*8]; %save color index for plotting
        REMORA.lt.lEdit.detection7Lab = [REMORA.lt.lEdit.detection7Lab;repmat({lab8},size(timechST,1),1)];
        REMORA.lt.lEdit.detection7 = [REMORA.lt.lEdit.detection7;newAdd];
    end
elseif strcmp(oldLabel,'eight')
    %check if labels already present as something else
    [~,oldID]= intersect(REMORA.lt.lEdit.detection8(:,1),timechST(:,1));
    if ~isempty(oldID)
        %remove whatever they were before
        REMORA.lt.lEdit.detection8(oldID,:) = [];
        REMORA.lt.lEdit.detection8Lab(oldID,:) = [];
    end
    if strcmp(newLabel,'false')
        newAdd = [timechST,ones(size(timechST,1),1).*0]; %save color index for plotting
        REMORA.lt.lEdit.detection8Lab = [REMORA.lt.lEdit.detection8Lab;repmat({labF},size(timechST,1),1)];
        REMORA.lt.lEdit.detection8 = [REMORA.lt.lEdit.detection8;newAdd];
    elseif strcmp(newLabel,'one')
        newAdd = [timechST,ones(size(timechST,1),1).*1]; %save color index for plotting
        REMORA.lt.lEdit.detection8Lab = [REMORA.lt.lEdit.detection8Lab;repmat({lab1},size(timechST,1),1)];
        REMORA.lt.lEdit.detection8 = [REMORA.lt.lEdit.detection8;newAdd];
    elseif strcmp(newLabel,'two')
        newAdd = [timechST,ones(size(timechST,1),1).*2]; %save color index for plotting
        REMORA.lt.lEdit.detection8Lab = [REMORA.lt.lEdit.detection8Lab;repmat({lab2},size(timechST,1),1)];
        REMORA.lt.lEdit.detection8 = [REMORA.lt.lEdit.detection8;newAdd];
    elseif strcmp(newLabel,'three')
        newAdd = [timechST,ones(size(timechST,1),1).*3]; %save color index for plotting
        REMORA.lt.lEdit.detection8Lab = [REMORA.lt.lEdit.detection8Lab;repmat({lab3},size(timechST,1),1)];
        REMORA.lt.lEdit.detection8 = [REMORA.lt.lEdit.detection8;newAdd];
    elseif strcmp(newLabel,'four')
        newAdd = [timechST,ones(size(timechST,1),1).*4]; %save color index for plotting
        REMORA.lt.lEdit.detection8Lab = [REMORA.lt.lEdit.detection8Lab;repmat({lab4},size(timechST,1),1)];
        REMORA.lt.lEdit.detection8 = [REMORA.lt.lEdit.detection8;newAdd];
    elseif strcmp(newLabel,'five')
        newAdd = [timechST,ones(size(timechST,1),1).*5]; %save color index for plotting
        REMORA.lt.lEdit.detection8Lab = [REMORA.lt.lEdit.detection8Lab;repmat({lab5},size(timechST,1),1)];
        REMORA.lt.lEdit.detection8 = [REMORA.lt.lEdit.detection8;newAdd];
    elseif strcmp(newLabel,'six')
        newAdd = [timechST,ones(size(timechST,1),1).*6]; %save color index for plotting
        REMORA.lt.lEdit.detection8Lab = [REMORA.lt.lEdit.detection8Lab;repmat({lab6},size(timechST,1),1)];
        REMORA.lt.lEdit.detection8 = [REMORA.lt.lEdit.detection8;newAdd];
    elseif strcmp(newLabel,'sev')
        newAdd = [timechST,ones(size(timechST,1),1).*7]; %save color index for plotting
        REMORA.lt.lEdit.detection8Lab = [REMORA.lt.lEdit.detection8Lab;repmat({lab7},size(timechST,1),1)];
        REMORA.lt.lEdit.detection8 = [REMORA.lt.lEdit.detection8;newAdd];
    elseif strcmp(newLabel,'eight')
        newAdd = [timechST,ones(size(timechST,1),1).*8]; %save color index for plotting
        REMORA.lt.lEdit.detection8Lab = [REMORA.lt.lEdit.detection8Lab;repmat({lab8},size(timechST,1),1)];
        REMORA.lt.lEdit.detection8 = [REMORA.lt.lEdit.detection5;newAdd];
    end
end

