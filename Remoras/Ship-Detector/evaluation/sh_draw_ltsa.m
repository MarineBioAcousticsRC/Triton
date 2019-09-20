function sh_draw_ltsa(handles)
%
% sh_eval_draw_ltsa.m
%
% Plot ltsa sessions using detections to define sessions  

bin2hr = handles.ltsa.tave/(60*60);
boxcolor{1}='r'; % 1 is red
boxcolor{2}='g'; % 2 is green

% Change plot frequency axis

[~,low] = min(abs(handles.ltsa.freq-handles.StartFreqVal));
[~,high] = min(abs(handles.ltsa.freq-handles.EndFreqVal));

c = (100/100) .* handles.ltsaData + 40;
t = (1:size(handles.ltsaData,2))*bin2hr;
image(t,handles.ltsa.f,c)

axis xy
set(gca,'TickDir','out')
for iDilim = 1:length(handles.markers)-1
    hold on
    plot([handles.markers(iDilim)*bin2hr,handles.markers(iDilim)*bin2hr],...
        [0,handles.EndFreqVal],'w');
    
    % plot rectangles 
    boxnumber = strcmp(handles.shipLabels{handles.ViewStart+iDilim},'ship')+1;
    
    rectangle('Position',[handles.markers(iDilim)*bin2hr,...
        handles.EndFreqVal - round(.015*(handles.EndFreqVal-handles.StartFreqVal)),...
        handles.markers(iDilim+1)*bin2hr-handles.markers(iDilim)*bin2hr,...
        round(.015*(handles.EndFreqVal-handles.StartFreqVal))],...
        'FaceColor',boxcolor{boxnumber});
  
end

hold off




