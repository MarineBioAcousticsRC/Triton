function sh_draw_ltsa(handles)
%
% sh_eval_draw_ltsa.m
%
% Plot ltsa sessions using detections to define sessions  

bin2hr = handles.ltsa.tave/(60*60);
boxcolor{1}='r'; % 1 is red
boxcolor{2}='g'; % 2 is green

if ~handles.eval
    shipLabels = handles.shipLabels;
    detNum = handles.ViewStart:(handles.ViewStart+length(handles.markers)-2);
else
    shipLabels = handles.shipLabelsEval;
    idxDetNum = handles.ViewStart:(handles.ViewStart+length(handles.markers)-2);
    detNum = handles.idxRandSamples(idxDetNum);
end

% Change plot frequency axis

[~,low] = min(abs(handles.ltsa.freq-handles.StartFreqVal));
[~,high] = min(abs(handles.ltsa.freq-handles.EndFreqVal));

handles.ltsaData = handles.ltsaData(low:high,:);

c = (100/100) .* handles.ltsaData + handles.brightness*100;
t = (1:size(handles.ltsaData,2))*bin2hr;
image(t,handles.ltsa.f(low:high),c)

axis xy
set(gca,'TickDir','out')

for iDilim = 1:length(handles.markers)-1
    hold on
    plot([handles.markers(iDilim)*bin2hr,handles.markers(iDilim)*bin2hr],...
        [0,handles.EndFreqVal],'w');
    
    % plot rectangles 
    boxnumber = strcmp(shipLabels{handles.ViewStart+iDilim-1},'ship')+1;
    
    rectangle('Position',[handles.markers(iDilim)*bin2hr,...
        handles.EndFreqVal - round(.015*(handles.EndFreqVal-handles.StartFreqVal)),...
        handles.markers(iDilim+1)*bin2hr-handles.markers(iDilim)*bin2hr,...
        round(.015*(handles.EndFreqVal-handles.StartFreqVal))],...
        'FaceColor',boxcolor{boxnumber});
    
    lenNum = length(num2str(detNum(iDilim)));
    if lenNum == 2; buff = 0.99;
    elseif lenNum == 3; buff = 0.98;
    elseif lenNum > 3; buff = 0.97;
    else; buff = 1; 
    end
    midPos = ((handles.markers(iDilim+1)*bin2hr+handles.markers(iDilim)*bin2hr)/2)*buff;
    if midPos < handles.PlotLengthVal
    text(midPos,...
        handles.EndFreqVal*1.02,...
        num2str(detNum(iDilim)),'FontSize',10,'FontWeight','bold');
    else 
        continue
    end
  
end

hold off




