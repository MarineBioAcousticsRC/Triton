function [nEventsPerBout,startBoutIdx,startBoutTime,endBoutIdx,endBoutTime,binMembers] = ...
    nn_fn_findBouts(eventTimes,minGapTimeDnum)
% assume event times are sorted, or if they aren't it's intentional.
nEventsPerBout = [];
startBoutIdx = [];
startBoutTime = [];
endBoutIdx = [];
endBoutTime = [];

diffTimes = diff(eventTimes); % calculate time between detections in seconds
boutIdx = find(round(diffTimes)>minGapTimeDnum);  % find start of gaps

if isempty(eventTimes)
    warning('No events found in this file');
    return
elseif isempty(boutIdx) % only one bout
    startBoutIdx = 1;
    endBoutIdx = length(eventTimes);
    
    startBoutTime = eventTimes(1);
    endBoutTime = eventTimes(end);
   
    nEventsPerBout = length(eventTimes);
else % multiple bouts
    startBoutIdx = [1;boutIdx+1];
    endBoutIdx = [boutIdx;length(eventTimes)];
    
    startBoutTime = [eventTimes(1);eventTimes(boutIdx+1)];   % start time of bout
    endBoutTime = [eventTimes(boutIdx);eventTimes(end)];   % end time of bout
    
    nEventsPerBout = diff([0;boutIdx;length(eventTimes)]);   
end

binMembers = {};
for iBin = 1:length(startBoutTime)
    binMembers{iBin} = find(eventTimes>=startBoutTime(iBin)&eventTimes<=endBoutTime(iBin));
end