function mod_chLabels

global PARAMS HANDLES REMORA

% find in-window detections
startWV = PARAMS.plot.dnum;
winLength = HANDLES.subplt.specgram.XLim(2); %get length of window in seconds, used to compute end limit
endWV = startWV + datenum(0,0,0,0,0,winLength); 

lablFull = [REMORA.lt.lVis_det.detection.starts,REMORA.lt.lVis_det.detection.stops];
inWin = find(lablFull(:,1)>= startWV & lablFull(:,1)<=endWV);

winDets = lablFull(inWin,:);
detstartOff = winDets(:,1) - startWV;
detXstart = lt_convertDatenum(detstartOff,'seconds'); %convert from datenum to time in SECONDS

detendOff = winDets(:,2) - startWV;
detXend = lt_convertDatenum(detendOff,'seconds');

%find new additions to changed label file 
       h = get(brush); %color for updated thing
       col = h.Color;
       red= [1 0 0];
       white = [0 0 0];
       orange = [0.93 0.69 0.13];
       maroon = [0.65 0.08 0.18];

        changeID = find(detXstart>=REMORA.lt.lVis_det.chSt & detXend <= REMORA.lt.lVis_det.chEd);
        detXchST = detXstart(changeID);
        
        %%add to existing changes
        if col = red
             newAdd = setdiff(changeID,REMORA.lt.lVis_det.detection.chLabRed);
        REMORA.lt.lVis_det.detection.chLabRed = [REMORA.lt.lVis_det.detection.chLabRed;newAdd];
        elseif col = white
                     newAdd = setdiff(changeID,REMORA.lt.lVis_det.detection.chLabWhite);
        REMORA.lt.lVis_det.detection.chLabWhite = [REMORA.lt.lVis_det.detection.chLabWhite;newAdd];
        elseif col = orange
             newAdd = setdiff(changeID,REMORA.lt.lVis_det.detection.chLabOrange);
        REMORA.lt.lVis_det.detection.chLabOrange = [REMORA.lt.lVis_det.detection.chLabOrange;newAdd];
        elseif col = maroon
             newAdd = setdiff(changeID,REMORA.lt.lVis_det.detection.chLabMaroon);
        REMORA.lt.lVis_det.detection.chLabMaroon = [REMORA.lt.lVis_det.detection.chLabMaroon;newAdd];
        end 
        
        for iPlot = 1:size(detXchST,1)
            detDur = detXchED - detXchST;
            if detDur < LineThresh
                %just plot the start of a given detection
                plot(detXchST(iPlot), yPos,'*','Color',h.Color)
            else
                plot([detXchST(iPlot) detXchED(iPlot)],[yPos yPos],'-','LineWidth',2,'Marker','*',...
                    'MarkerSize',5,'Color',h.Color)
            end
        end