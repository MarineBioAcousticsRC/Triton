function [abstime] = bw_writecalls_soundtrap (halfblock, startTime, peakS, score)

% Adapted from Shyam's BatchClassifyBlueCalls
% Updated to write score after start time
% smk 100713

totalCalls = size(peakS, 1); %total number of detections
abstime = {};
% window = startTime+halfblock; %total number of seconds at start of window
% numraw = window/75; %# raw files up to this point - must be integer

if totalCalls > 0
   % saveList = peakS(find(peakS(:, 1) <= halfblock), :); %why is this?
  %  savedCalls = size(saveList, 1);
   saveList = peakS;        
    %if savedCalls > 0
        %res = zeros(1,length(saveList));
        %doubles = zeros(1,length(saveList));
        abstime = saveList*datenum([0 0 0 0 0 1]) + dateoffset+startTime;
end
end
%dvec = datevec(abstime);
        %file = repmat(filename,length(saveList),1); 
        %detcalls = table(abstime,dvec,score,file);
        %fraction = num2str(dvec(:,6)-floor(dvec(:,6)));
        %fraction = fraction
       % for m = 1:length(saveList)
            %put detections into raw file bins and add offset
            
            %whichraw = ceil((saveList(m)+startTime)/I.Duration); %Changed the number 75 to I.Duration, to account for the different file size of the sound traps. Not sure if this equation is calculating the right thing.
           
            %RealSec(m) = offset + saveList(m)+block*(blockIdx-1); %This step seems like adding the same thing twice, so I removed "+ whichraw+startTime"           
            %abstime = dateoffset + datenum([0 0 0 0 0 saveList(m)])+ startTime(1); %dateoffset ensures that the date corresponds to the one stored in Triton.
        %    res(m) = abstime(1);
            
         %   if  m>1 && res(m)-res(m-1)<(1.1574e-05*60) % check if time difference between calls is smaller than 5 seconds.
          %      doubles(m) = 1;
%end
 %           dvec = datevec(abstime(1));
  %          fraction = num2str(dvec(6) - floor(dvec(6)));
   %         fraction = fraction(2:end);
   %         thisScore = score(m);
            
    %        fprintf(out_fid, '%s%s\t%f\t%s\t%\f\n', datestr(abstime(1), 31), fraction, filename, doubles);
    %else
        
    %end
   
%end
%else
%abstime = '';




