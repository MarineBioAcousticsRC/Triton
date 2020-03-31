function [abstime] = bm_writecalls_soundtrap2(halfblock,startTime,peakS,score)

% Adapted from Shyam's BatchClassifyBlueCalls
% Updated to write detection times into one table.
% smk 100713
% ak 200206

totalCalls = size(peakS,1); %total number of detections
abstime={};

if totalCalls>0
    abstime = peakS*datenum([0 0 0 0 0 1]) + startTime; %dateoffset was removed, because it gave strange dates.
end
end