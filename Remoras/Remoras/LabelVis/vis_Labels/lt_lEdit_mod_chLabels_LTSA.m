function lt_lEdit_mod_chLabels_LTSA(labType)

global PARAMS REMORA 

%work for LTSA window
% get LTSA range times
%pull start and end times of window
[ltsaS,ltsaE] = lt_lVis_get_ltsa_range;
plotFreq = PARAMS.ltsa.f(end) *.9;


if REMORA.lt.lVis_det.detection.PlotLabels
    yPos = plotFreq*1;
    if (REMORA.lt.lEdit.ychSt<=yPos && yPos<=REMORA.lt.lEdit.ychEd)
        lablFull = [REMORA.lt.lVis_det.detection.starts,REMORA.lt.lVis_det.detection.stops];
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
            winDets = lablFull(winDetsIdx,:);
            
        if ~isempty(winDets)
            detXstart = lt_lVis_get_LTSA_Offset(winDets,'starts');
            detXend = lt_lVis_get_LTSA_Offset(winDets,'stops');
            
            ch_Labels(detXstart,detXend,'one',labType,winDets)
        end
    end
end

if REMORA.lt.lVis_det.detection2.PlotLabels
    yPos = plotFreq*.9;
    if (REMORA.lt.lEdit.ychSt<=yPos && yPos<=REMORA.lt.lEdit.ychEd)
        lablFull = [REMORA.lt.lVis_det.detection2.starts,REMORA.lt.lVis_det.detection2.stops];
        winDets = lablFull(lablFull(:,1)>= ltsaS & lablFull(:,2)<=ltsaE,:);
        
        if ~isempty(winDets)
            detXstart = lt_lVis_get_LTSA_Offset(winDets,'starts');
            detXend = lt_lVis_get_LTSA_Offset(winDets,'stops');
            
            ch_Labels(detXstart,detXend,'two',labType,winDets)
        end
    end
end
if REMORA.lt.lVis_det.detection3.PlotLabels
    yPos = plotFreq*.7;
    if (REMORA.lt.lEdit.ychSt<=yPos && yPos<=REMORA.lt.lEdit.ychEd)
        lablFull = [REMORA.lt.lVis_det.detection3.starts,REMORA.lt.lVis_det.detection3.stops];
        winDets = lablFull(lablFull(:,1)>= ltsaS & lablFull(:,2)<=ltsaE,:);
        
        if ~isempty(winDets)
            detXstart = lt_lVis_get_LTSA_Offset(winDets,'starts');
            detXend = lt_lVis_get_LTSA_Offset(winDets,'stops');
            
            ch_Labels(detXstart,detXend,'three',labType,winDets)
        end
    end
end
if REMORA.lt.lVis_det.detection4.PlotLabels
    yPos = plotFreq*.6;
    if (REMORA.lt.lEdit.ychSt<=yPos && yPos<=REMORA.lt.lEdit.ychEd)
        lablFull = [REMORA.lt.lVis_det.detection4.starts,REMORA.lt.lVis_det.detection4.stops];
        winDets = lablFull(lablFull(:,1)>= ltsaS & lablFull(:,2)<=ltsaE,:);
        
        if ~isempty(winDets)
            detXstart = lt_lVis_get_LTSA_Offset(winDets,'starts');
            detXend = lt_lVis_get_LTSA_Offset(winDets,'stops');
            
            ch_Labels(detXstart,detXend,'four',labType,winDets)
        end
    end
end
if REMORA.lt.lVis_det.detection5.PlotLabels
    yPos = plotFreq*.5;
    if (REMORA.lt.lEdit.ychSt<=yPos && yPos<=REMORA.lt.lEdit.ychEd)
        lablFull = [REMORA.lt.lVis_det.detection5.starts,REMORA.lt.lVis_det.detection5.stops];
        winDets = lablFull(lablFull(:,1)>= ltsaS & lablFull(:,2)<=ltsaE,:);
        
        if ~isempty(winDets)
            detXstart = lt_lVis_get_LTSA_Offset(winDets,'starts');
            detXend = lt_lVis_get_LTSA_Offset(winDets,'stops');
            
            ch_Labels(detXstart,detXend,'five',labType,winDets)
        end
    end
end
if REMORA.lt.lVis_det.detection6.PlotLabels
    yPos = plotFreq*.4;
    if (REMORA.lt.lEdit.ychSt<=yPos && yPos<=REMORA.lt.lEdit.ychEd)
        lablFull = [REMORA.lt.lVis_det.detection6.starts,REMORA.lt.lVis_det.detection6.stops];
        winDets = lablFull(lablFull(:,1)>= ltsaS & lablFull(:,2)<=ltsaE,:);
        
        if ~isempty(winDets)
            detXstart = lt_lVis_get_LTSA_Offset(winDets,'starts');
            detXend = lt_lVis_get_LTSA_Offset(winDets,'stops');
            
            ch_Labels(detXstart,detXend,'six',labType,winDets)
        end
    end
end
if REMORA.lt.lVis_det.detection7.PlotLabels
    yPos = plotFreq*.3;
    if (REMORA.lt.lEdit.ychSt<=yPos && yPos<=REMORA.lt.lEdit.ychEd)
        lablFull = [REMORA.lt.lVis_det.detection7.starts,REMORA.lt.lVis_det.detection7.stops];
        winDets = lablFull(lablFull(:,1)>= ltsaS & lablFull(:,2)<=ltsaE,:);
        
        if ~isempty(winDets)
            detXstart = lt_lVis_get_LTSA_Offset(winDets,'starts');
            detXend = lt_lVis_get_LTSA_Offset(winDets,'stops');
            ch_Labels(detXstart,detXend,'sev',labType,winDets)
        end
    end
end
if REMORA.lt.lVis_det.detection8.PlotLabels
    yPos = plotFreq*.2;
    if (REMORA.lt.lEdit.ychSt<=yPos && yPos<=REMORA.lt.lEdit.ychEd)
        lablFull = [REMORA.lt.lVis_det.detection8.starts,REMORA.lt.lVis_det.detection8.stops];
        winDets = lablFull(lablFull(:,1)>= ltsaS & lablFull(:,2)<=ltsaE,:);
        
        if ~isempty(winDets)
            detXstart = lt_lVis_get_LTSA_Offset(winDets,'starts');
            detXend = lt_lVis_get_LTSA_Offset(winDets,'stops');
            
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

%plot everything again
global HANDLES
    %which labels to display
    if HANDLES.display.ltsa.Value
        lt_lVis_plot_LTSA_labels
    end
    
    if HANDLES.display.specgram.Value
        lt_lVis_plot_WAV_labels
    end
    
    if HANDLES.display.timeseries.Value
        lt_lVis_plot_TS_labels
    end
