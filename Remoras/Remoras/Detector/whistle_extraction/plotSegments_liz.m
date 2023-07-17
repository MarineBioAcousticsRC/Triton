function [segList] = plotSegments(fitFile)
% plot segments on top of each other, 
% acts on smoothed_whistle output from dtRootFit, or on 
% reloaded smoothed whistle file, imported using loadFitFile.
close all

segList = cell(fitFile.size,1); % make a cell array to hold all the segments
a = 1; c = 1;
for k = 0:length(segList)-1    % for each whistle in the 
    thisFreq = []; %initialize/ empty from previous round
    thisTime = [];
    thisRoots = [];
    thisBandwidth = [];
    thisMeanSlope = [];
    
    thisFreq = (fitFile.get(k).getThisTonal.get_freq); % pull in the time and freq info for this whistle
    thisTime = (fitFile.get(k).getThisTonal.get_time);
    thisBandwidth = (fitFile.get(k).getBandWidth);
    thisMeanSlope = (fitFile.get(k).getMeanSlope);
    
    if (fitFile.get(k).getRoots)~=0
    % thisRoots = vertcat(thisTime(1),fitFile.get(k).getRoots,thisTime(end));
        thisRoots = vertcat(thisTime(1),fitFile.get(k).getRoots,thisTime(end));
    else
        thisRoots = vertcat(thisTime(1),thisTime(end)); % in case of no roots
        thisTonalTime_t0 = thisTime(:) - thisTime(1); %adjust whistle time to zero
        TonalSlope(k+1) = thisMeanSlope;
   
        % plot whistles with order of 1 (ie no segments)
        if thisBandwidth < 200
            figure(1)
            hold on
            subplot(3,2,1)
            plot(thisTonalTime_t0,thisFreq,'LineWidth',2)
            title('Plot of all flat whistles')
            xlabel('Time (s)')
            ylabel('Freq (kHz)')
            axis([0 1.5 5000 50000])
            hold on
        elseif thisMeanSlope > 0
            subplot(3,2,3)
            plot(thisTonalTime_t0,thisFreq,'LineWidth',2)
            title('Plot of all upsweep whistles')
            xlabel('Time (s)')
            ylabel('Freq (kHz)')
            axis([0 1.5 5000 50000])
            hold on
        elseif thisMeanSlope < 0
            subplot(3,2,5)
            plot(thisTonalTime_t0,thisFreq,'LineWidth',2)
            title('Plot of all downsweep whistles')
            xlabel('Time (s)')
            ylabel('Freq (kHz)')
            axis([0 1.5 5000 50000])
            hold on
        end
        
    end
    for i=1: length(thisRoots)-1 % figure out where to cut the segments - depends on position within whistle
        if i == 1
            segStart = 1;
            [segEnd, m] = find(thisTime <= thisRoots(i+1));
            segEnd = segEnd(end);
        elseif i == length(thisRoots)-1
            [segStart, m] = find(thisTime >= thisRoots(i));
            segStart = segStart(1);
            segEnd = length(thisTime);
        else
            [segStart, m] = find(thisTime >= thisRoots(i));
            segStart = segStart(1);
            [segEnd, m] = find(thisTime <= thisRoots(i+1));
            segEnd = segEnd(end);
        end
            name = sprintf('Segments%d', i);
            thisSegTime = thisTime(segStart:segEnd);
            thisSegTime_t0 = thisSegTime - thisSegTime(1);
            thisSegFreq = thisFreq(segStart:segEnd);
            meanThisSegFreq = mean(thisSegFreq);
            thisSegFreq_norm = thisSegFreq - meanThisSegFreq;
            segList{k+1}.(num2str(name)) = {thisSegTime, thisSegTime_t0, thisSegFreq, thisSegFreq_norm};
    end

    TonalDur(k+1) = thisTime(end) - thisTime(1);
    SegmentDur(k+1) = thisTime(segEnd) - thisTime(segStart);
    
end
    
    
% plot whistle segments, all beginning at t = 0

% figure
% hold on
% for k = 1:length(segList)
%     segNum = numel(fieldnames(segList{k}));
%     for j = 1:segNum
%         name = sprintf('Segments%d', j);
%         plot(segList{k}.(name){1,2},segList{k}.(name){1,3});  
%     end
% 
% end
% hold off
% 
% % plot freq normalized whistle segments (mean freq removed)
% figure
% hold on
% for k = 1:length(segList)
%     segNum = numel(fieldnames(segList{k}));
%     for j = 1:segNum
%         name = sprintf('Segments%d', j);
%         plot(segList{k}.(name){1,2},segList{k}.(name){1,4});  
%     end
% 
% end
% % title
% hold off


b = 1;
for k = 1:length(segList)
    segNum = numel(fieldnames(segList{k}));
    thisMeanSlope1 = (fitFile.get(k-1).getMeanSlope);
    thisBandWidth1 = (fitFile.get(k-1).getBandWidth);
    for j = 1:segNum
        if j==1
            color= '-r';
        elseif j==2
            color= '-b';
        elseif j==3
            color= '-c';
        elseif j==4
            color = '-g';
        else 
            color = '-k';
        end
        sizeMeanSlope = length(thisMeanSlope1);
        if sizeMeanSlope>= j
            if thisMeanSlope1(j)<0 && (thisBandWidth1(j) > 200)&& (segNum>1)
                % plot segments with negative slope, not freq normalized
                name = sprintf('Segments%d', j);
                subplot(3,2,2);
                title('Segments with negative slope');
                xlabel('Time (s)')
                ylabel('Freq (kHz)')
                axis([0 1.5 5000 50000])
                hold on
                plot(segList{k}.(name){1,2},segList{k}.(name){1,3},color,'LineWidth',2); 
                NegSlope(k) = thisMeanSlope1(j);
            elseif (thisMeanSlope1(j)>0) && (thisBandWidth1(j) > 200) && (segNum>1)
                % Plot segments with positive slope, not freq normalized
                name = sprintf('Segments%d', j);
                subplot(3,2,4);
                hold on
                plot(segList{k}.(name){1,2},segList{k}.(name){1,3},color,'LineWidth',2);  
                title('Segments with positive slope');
                xlabel('Time (s)')
                ylabel('Freq (kHz)')
                axis([0 1.5 5000 50000])
                PosSlope(k) = thisMeanSlope1(j);
            elseif (thisBandWidth1(j) < 200)
                % Plot segments with flat slopes, not freq normalized
                name = sprintf('Segments%d', j);
                subplot(3,2,6);
                hold on
                plot(segList{k}.(name){1,2},segList{k}.(name){1,3},color,'LineWidth',2);  
                title('flat segments');
                xlabel('Time (s)')
                ylabel('Freq (kHz)')
                axis([0 1.5 5000 50000])

            end
          end
    end
       segCount(b) = max(segNum);
       segNum=[]; b = b+1;
end

hold off

%Plot histograms of number of segments, tonal duration, segment duration,
%and slope

figure(2)
subplot(3,2,1)
hist(segCount)
title('Histogram of segments per whistle')
xlabel('number of segments')

subplot(3,2,2)
hist(TonalDur)
title('Histogram of overall tonal duration')
xlabel('duration (s)')

subplot(3,2,3)
hist(SegmentDur)
title('Histogram of segment duration')
xlabel('duration (s)')

subplot(3,2,4)
hist(TonalSlope)
title('Histogram of single tonal slope')

subplot(3,2,5)
hist(NegSlope)
title('Histogramp of segments with negative slope')

subplot(3,2,6)
hist(PosSlope)
title('Histogram of segments with positive slope')

end