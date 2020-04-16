function lt_lEdit_mod_chLabels(labType)

global PARAMS HANDLES REMORA

plotFreq = PARAMS.freq1 *.9;

% find in-window detections
startWV = PARAMS.plot.dnum;
winLength = HANDLES.subplt.specgram.XLim(2); %get length of window in seconds, used to compute end limit
endWV = startWV + datenum(0,0,0,0,0,winLength);

if REMORA.lt.lVis_det.detection.PlotLabels
    yPos = plotFreq*1;
    if REMORA.lt.lEdit.ychSt<=yPos & yPos<=REMORA.lt.lEdit.ychEd
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
    if REMORA.lt.lEdit.ychSt<=yPos & yPos<=REMORA.lt.lEdit.ychEd
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
    if REMORA.lt.lEdit.ychSt<=yPos & yPos<=REMORA.lt.lEdit.ychEd
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
    if REMORA.lt.lEdit.ychSt<=yPos & yPos<=REMORA.lt.lEdit.ychEd
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

%%add to existing changed labels
if strcmp(oldLabel,'one')
    if strcmp(newLabel,'false')
        newAdd = setdiff(timechST,REMORA.lt.lEdit.detection.chLabFalse,'rows');
        REMORA.lt.lEdit.detection.chLabFalse = [REMORA.lt.lEdit.detection.chLabFalse;newAdd];
    elseif strcmp(newLabel,'one')
        newAdd = setdiff(timechST,REMORA.lt.lEdit.detection.chLab1,'rows');
        REMORA.lt.lEdit.detection.chLab1 = [REMORA.lt.lEdit.detection.chLab1;newAdd];
    elseif strcmp(newLabel,'two')
        newAdd = setdiff(timechST,REMORA.lt.lEdit.detection.chLab2,'rows');
        REMORA.lt.lEdit.detection.chLab2 = [REMORA.lt.lEdit.detection.chLab2;newAdd];
    elseif strcmp(newLabel,'three')
        newAdd = setdiff(timechST,REMORA.lt.lEdit.detection.chLab3,'rows');
        REMORA.lt.lEdit.detection.chLab3 = [REMORA.lt.lEdit.detection.chLab3;newAdd];
    elseif strcmp(newLabel,'four')
        newAdd = setdiff(timechST,REMORA.lt.lEdit.detection.chLab4,'rows');
        REMORA.lt.lEdit.detection.chLab4 = [REMORA.lt.lEdit.detection.chLab4;newAdd];
    end
elseif strcmp(oldLabel,'two')
    if strcmp(newLabel,'false')
        newAdd = setdiff(timechST,REMORA.lt.lEdit.detection2.chLabFalse,'rows');
        REMORA.lt.lEdit.detection2.chLabFalse = [REMORA.lt.lEdit.detection2.chLabFalse;newAdd];
    elseif strcmp(newLabel,'one')
        newAdd = setdiff(timechST,REMORA.lt.lEdit.detection2.chLab1,'rows');
        REMORA.lt.lEdit.detection2.chLab1 = [REMORA.lt.lEdit.detection2.chLab1;newAdd];
    elseif strcmp(newLabel,'two')
        newAdd = setdiff(timechST,REMORA.lt.lEdit.detection2.chLab2,'rows');
        REMORA.lt.lEdit.detection2.chLab2 = [REMORA.lt.lEdit.detection2.chLab2;newAdd];
    elseif strcmp(newLabel,'three')
        newAdd = setdiff(timechST,REMORA.lt.lEdit.detection2.chLab3,'rows');
        REMORA.lt.lEdit.detection2.chLab3 = [REMORA.lt.lEdit.detection2.chLab3;newAdd];
    elseif strcmp(newLabel,'four')
        newAdd = setdiff(timechST,REMORA.lt.lEdit.detection2.chLab4,'rows');
        REMORA.lt.lEdit.detection2.chLab4 = [REMORA.lt.lEdit.detection2.chLab4;newAdd];
    end
elseif strcmp(oldLabel,'three')
    if strcmp(newLabel,'false')
        newAdd = setdiff(timechST,REMORA.lt.lEdit.detection3.chLabFalse,'rows');
        REMORA.lt.lEdit.detection3.chLabFalse = [REMORA.lt.lEdit.detection3.chLabFalse;newAdd];
    elseif strcmp(newLabel,'one')
        newAdd = setdiff(timechST,REMORA.lt.lEdit.detection3.chLab1,'rows');
        REMORA.lt.lEdit.detection3.chLab1 = [REMORA.lt.lEdit.detection3.chLab1;newAdd];
    elseif strcmp(newLabel,'two')
        newAdd = setdiff(timechST,REMORA.lt.lEdit.detection3.chLab2,'rows');
        REMORA.lt.lEdit.detection3.chLab2 = [REMORA.lt.lEdit.detection3.chLab2;newAdd];
    elseif strcmp(newLabel,'three')
        newAdd = setdiff(timechST,REMORA.lt.lEdit.detection3.chLab3,'rows');
        REMORA.lt.lEdit.detection3.chLab3 = [REMORA.lt.lEdit.detection3.chLab3;newAdd];
    elseif strcmp(newLabel,'four')
        newAdd = setdiff(timechST,REMORA.lt.lEdit.detection3.chLab4,'rows');
        REMORA.lt.lEdit.detection3.chLab4 = [REMORA.lt.lEdit.detection3.chLab4;newAdd];
    end
elseif strcmp(oldLabel,'four')
    if strcmp(newLabel,'false')
        newAdd = setdiff(timechST,REMORA.lt.lEdit.detection4.chLabFalse,'rows');
        REMORA.lt.lEdit.detection4.chLabFalse = [REMORA.lt.lEdit.detection4.chLabFalse;newAdd];
    elseif strcmp(newLabel,'one')
        newAdd = setdiff(timechST,REMORA.lt.lEdit.detection4.chLab1,'rows');
        REMORA.lt.lEdit.detection4.chLab1 = [REMORA.lt.lEdit.detection4.chLab1;newAdd];
    elseif strcmp(newLabel,'two')
        newAdd = setdiff(timechST,REMORA.lt.lEdit.detection4.chLab2,'rows');
        REMORA.lt.lEdit.detection4.chLab2 = [REMORA.lt.lEdit.detection4.chLab2;newAdd];
    elseif strcmp(newLabel,'three')
        newAdd = setdiff(timechST,REMORA.lt.lEdit.detection4.chLab3,'rows');
        REMORA.lt.lEdit.detection4.chLab3 = [REMORA.lt.lEdit.detection4.chLab3;newAdd];
    elseif strcmp(newLabel,'four')
        newAdd = setdiff(timechST,REMORA.lt.lEdit.detection4.chLab4,'rows');
        REMORA.lt.lEdit.detection4.chLab4 = [REMORA.lt.lEdit.detection4.chLab4;newAdd];
    end
end

