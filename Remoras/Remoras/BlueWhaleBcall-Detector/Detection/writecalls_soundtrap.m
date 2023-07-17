function writecalls_soundtrap (I,block,halfblock, blockIdx, startTime, offset, peakS, score, out_fid)

% Adapted from Shyam's BatchClassifyBlueCalls
% Updated to write score after start time
% smk 100713

totalCalls = size(peakS, 1); %total number of detections

% window = startTime+halfblock; %total number of seconds at start of window
% numraw = window/75; %# raw files up to this point - must be integer

if totalCalls > 0
    saveList = peakS(find(peakS(:, 1) <= halfblock), :); %why is this?
    savedCalls = size(saveList, 1);
           
    if savedCalls > 0
        for m = 1:length(saveList)
            %put detections into raw file bins and add offset
            
            %whichraw = ceil((saveList(m)+startTime)/I.Duration); %Changed the number 75 to I.Duration, to account for the different file size of the sound traps. Not sure if this equation is calculating the right thing.
           
            RealSec(m) = offset + saveList(m)+block*(blockIdx-1); %This step seems like adding the same thing twice, so I removed "+ whichraw+startTime"           
            
            abstime = dateoffset + datenum([0 0 0 0 0 RealSec(m)])+ startTime(1); %dateoffset ensures that the date corresponds to the one stored in Triton.
            
            dvec = datevec(abstime(1));
            fraction = num2str(dvec(6) - floor(dvec(6)));
            fraction = fraction(2:end);
            thisScore = score(m);
            fprintf(out_fid, '%s%s\t%f\n', datestr(abstime(1), 31), fraction, thisScore);
           
        end
        
    end
end


