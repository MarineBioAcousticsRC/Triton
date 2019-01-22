function [segList] = plotSegments(fitFile)
% plot segments on top of each other, 
% acts on smoothed_whistle output from dtRootFit, or on 
% reloaded smoothed whistle file, imported using loadFitFile.

segList = cell(fitFile.size,1); % make a cell array to hold all the segments

for k = 0:length(segList)-1    % for each whistle in the 
    thisFreq = []; %initialize/ empty from previous round
    thisTime = [];
    thisRoots = [];
    
    thisFreq = (fitFile.get(k).getThisTonal.get_freq); % pull in the time and freq info for this whistle
    
    thisTime = (fitFile.get(k).getThisTonal.get_time);
    if (fitFile.get(k).getRoots)~=0
    % thisRoots = vertcat(thisTime(1),fitFile.get(k).getRoots,thisTime(end));
    thisRoots = vertcat(thisTime(1),fitFile.get(k).getRoots,thisTime(end));
    else
    thisRoots = vertcat(thisTime(1),thisTime(end)); % in case of no roots
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
            thisSegFreq_log = log(thisSegFreq);
            segList{k+1}.(num2str(name)) = {thisSegTime, thisSegTime_t0, thisSegFreq, thisSegFreq_log};
    end

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

% Plot whistles with positive slope
figure
subplot(3,1,1);
hold on
for k = 1:length(segList)
    segNum = numel(fieldnames(segList{k}));
    thisMeanSlope = (fitFile.get(k-1).getMeanSlope);
    thisBandWidth = (fitFile.get(k-1).getBandWidth);
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
        sizeMeanSlope = length(thisMeanSlope);
        if sizeMeanSlope>= j
            if thisMeanSlope(j)<0 && (thisBandWidth(j) > 200)
                name = sprintf('Segments%d', j);
                plot(segList{k}.(name){1,2},segList{k}.(name){1,4},color);  
            end
        end
    end
    segNum=[];
end
title('whistles with negative slope');
xlabel('sec');
ylabel('Hz');
hold off


% Plot whistles with positive slope, not freq normalized
% figure
subplot(3,1,2);
hold on
for k = 1:length(segList)
    segNum = numel(fieldnames(segList{k}));
    thisMeanSlope = (fitFile.get(k-1).getMeanSlope);
    thisBandWidth = (fitFile.get(k-1).getBandWidth);
    for j = 1:segNum
        if j==1
            color = '-r';
        elseif j==2
            color = '-b';
        elseif j==3
            color = '-c';
        elseif j==4
            color = '-g';
        elseif j >= 5
            color = '-k';
        end
            
        sizeMeanSlope = length(thisMeanSlope);
        if sizeMeanSlope>= j
            if (thisMeanSlope(j)>0) && (thisBandWidth(j) > 200)
                name = sprintf('Segments%d', j);
                plot(segList{k}.(name){1,2},segList{k}.(name){1,4},color);  
            end
        end
    end
    segNum=[];
end
title('whistles with positive slope');
xlabel('sec');
ylabel('Hz');
hold off


% plot flat whistles
% figure
subplot(3,1,3);
hold on
for k = 1:length(segList)
    segNum = numel(fieldnames(segList{k}));
    thisMeanSlope = (fitFile.get(k-1).getMeanSlope);
    thisBandWidth = (fitFile.get(k-1).getBandWidth);
    for j = 1:segNum
        if j==1
            color = '-r';
        elseif j==2
            color = '-b';
        elseif j==3
            color = '-c';
        elseif j==4
            color = '-g';
        elseif j >= 5
            color = '-k';
        end
            
        sizeMeanSlope = length(thisMeanSlope);
        if sizeMeanSlope>= j
            if (thisBandWidth(j) < 200)
                name = sprintf('Segments%d', j);
                plot(segList{k}.(name){1,2},segList{k}.(name){1,4},color);  
            end
        end
    end
    segNum=[];
end
title('flat whistles');
xlabel('sec');
ylabel('Hz');
hold off

