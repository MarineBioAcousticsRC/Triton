function [clkStart,clkEnd]= sp_dt_processValidClicks(clicks,clickDets,startsK,hdr)
% Write click times to .ctg label file

clkStart = nan(length(clickDets.clickInd),1);
clkEnd = nan(length(clickDets.clickInd),1);

for c = 1:length(clickDets.clickInd)
    cI = clickDets.clickInd(c);
    currentClickStart = startsK + clicks(cI,1)/hdr.fs; % start time
    currentClickEnd = startsK + clicks(cI,2)/hdr.fs;
    
    % Compute parameters of click frames
    clkStart(c,1) = currentClickStart;
    clkEnd(c,1) = currentClickEnd;
end
