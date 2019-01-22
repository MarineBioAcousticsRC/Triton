function [segList,allFreq] = kmeans_batch(HTKTonalList)
for ii=0:(HTKTonalList.size)-1
 fitFile = HTKTonalList.get(ii);
   
 segListtemp = cell(fitFile.size,1);


  
for k = 0:length(segListtemp)-1    % for each whistle in the
    thisFreq = []; %initialize/ empty from previous round
    thisTime = [];
    thisRoots = [];
    
    thisFreq = (fitFile.get(k).getThisTonal.get_freq); % pull in the time
    %and freq info for this whistle
    thisTime = (fitFile.get(k).getThisTonal.get_time);
    if k == 0
        allfreq = {thisFreq};
    else
        allfreq = cat(2,allfreq,thisFreq);
    end
    if (fitFile.get(k).getRoots)~=0
        % thisRoots = vertcat(thisTime(1),fitFile.get(k).getRoots,thisTime(end));
        thisRoots = vertcat(thisTime(1),fitFile.get(k).getRoots,thisTime(end));
    else
        thisRoots = vertcat(thisTime(1),thisTime(end)); % in case of no roots
    end
    for i=1:length(thisRoots)-1 % figure out where to cut the segments -
        %depends on position within whistle
        if length(thisRoots) == 2;
            segStart = 1;
            segEnd = length(thisTime);
            
        elseif length(thisRoots) > 2;
            if i == 1;
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
        end
        name = sprintf('Segments%d', i);
        thisSegTime = thisTime(segStart:segEnd);
        thisSegFreq = thisFreq(segStart:segEnd);
        thisSegDur = thisSegTime(end)-thisSegTime(1);
        thisBandWidth = (fitFile.get(k).getBandWidth);
        thisMeanSlope = (fitFile.get(k).getMeanSlope);
        segListtemp{k+1}.(num2str(name)) = {thisSegTime,thisSegFreq,thisSegDur};
    end
    segNum = numel(fieldnames(segListtemp{k+1}));
    for j = 1:segNum
        thisBandWidth = (fitFile.get(k).getBandWidth);
        thisMeanSlope = (fitFile.get(k).getMeanSlope);
        name = sprintf('Segments%d', j);
        segListtemp{k+1}.(name){1,4} = thisBandWidth(j);
        segListtemp{k+1}.(name){1,5} = thisMeanSlope(j);
    end
end

    if ii == 0
        segList = segListtemp;
        clear segListtemp
        allFreq = allfreq;
    else
        segList = cat(1,segList,segListtemp);
        clear segListtemp
        allFreq = cat(2,allFreq,allfreq);
    end
end

d=1;e=1;f=1;
for k=1:length(segList)
%     thisFreq = (fitFile.get(k-1).getThisTonal.get_freq); % import freq
%     info
%     thisBandWidth = (fitFile.get(k-1).getBandWidth);
%     thisMeanSlope = (fitFile.get(k-1).getMeanSlope);
    segNum = numel(fieldnames(segList{k})); % figure out # of segments to deal with
    
%      q = 1;
    % keep adding up length of segments to keep track of what their
    % indices will be in the masterVector.
    for j = 1:segNum
      
        name = sprintf('Segments%d', j);
        segSize = length(segList{k}.(name){1,2});
%         segEndIdx(q,1)= segStartIdx(q,1)+ segSize - 1;
         segSlope = segList{k}.(name){1,5};
         segBW = segList{k}.(name){1,4};
        if segBW<=(200) 
%             meanslope_flat(d) = segSlope(q);
            dur_flat{d,1} = {segList{k}.(name){1,3}};
            w_namef = sprintf('flat%d',d);
            dur_flat{d,2} = {w_namef};
%             band_flat(d) = segBW(q);
            
            segList{k}.(name){1,6} = {w_namef};
            d=d+1;
        elseif segSlope>0 && segBW>(200)
%              meanslope_up(e) = segSlope(q,1);
             dur_up{e,1} = {segList{k}.(name){1,3}};
             w_nameu = sprintf('up%d',e);
             dur_up{e,2} = {w_nameu };
%              band_up(e) = segBW(q,1);
             
             segList{k}.(name){1,6} = {w_nameu };
             e = e+1;
        elseif segSlope<0 && segBW>(200)
%             meanslope_down(f) = segSlope(q,1);
            dur_down{f,1} = {segList{k}.(name){1,3}};
            w_named = sprintf('down%d',f);
            dur_down{f,2} = {w_named};
%             band_down(f) = segBW(q,1);
            
            segList{k}.(name){1,6} = {sprintf(w_named)};
            f=f+1;
        end 
%         if j < segNum % as long as there's another segment, the first index
%             %             %of that segment will be the last index +1
% %             q = q+1;
%         end
    end
end  
 m = 3;
% [IDXflat_slope,Cflat_slope] = kmeans(meanslope_flat,m,'emptyaction','drop','replicates',10);
[IDXflat_dur,Cflat_dur] = kmeans(cell2mat(cat(1,dur_flat{:,1})),m,'emptyaction','drop','replicates',10);
% [IDXflat_band,Cflat_band] = kmeans(band_flat,m,'emptyaction','drop','replicates',10);

% [IDXup_slope,Cup_slope] = kmeans(meanslope_up,m,'emptyaction','drop','replicates',10);
[IDXup_dur,Cup_dur] = kmeans(cell2mat(cat(1,dur_up{:,1})),m,'emptyaction','drop','replicates',10);
% [IDXup_band,Cup_band] = kmeans(band_up,m,'emptyaction','drop','replicates',10);

% [IDXdown_slope,Cdown_slope] = kmeans(meanslope_down,m,'emptyaction','drop','replicates',10);
[IDXdown_dur,Cdown_dur] = kmeans(cell2mat(cat(1,dur_down{:,1})),m,'emptyaction','drop','replicates',10);
% [IDXdown_band,Cdown_band] = kmeans(band_down,m,'emptyaction','drop','replicates',10);

 for k=1:length(segList)
   segNum = numel(fieldnames(segList{k}));
   for j = 1:segNum
      name = sprintf('Segments%d', j);
      
     for a = 1:length(dur_flat)
      tf1 = isequal(segList{k}.(name){1,6},dur_flat{a,2});
      if tf1 ==1;
       
        if IDXflat_dur(a) == 1;
            segList{k}.(name){1,7} = {'flat_1'};
            figure(1)
            subplot(3,3,1)
            title('Flat segments separated by duration')
            plot(segList{k}.(name){1,2})
            hold on
            break
        elseif IDXflat_dur(a) == 2;
            segList{k}.(name){1,7} = {'flat_2'};
            figure(1)
            subplot(3,3,4)
            plot(segList{k}.(name){1,2})
            hold on
            break
        elseif IDXflat_dur(a) == 3;
            segList{k}.(name){1,7} = {'flat_3'};
            figure(1)
            subplot(3,3,7)
            plot(segList{k}.(name){1,2})
            hold on
            break
        end
      end
    end
     for b = 1:length(dur_up)
       tf2 = isequal(segList{k}.(name){1,6},dur_up{b,2});
       if tf2 == 1
         if IDXup_dur(b) ==1;
            segList{k}.(name){1,7} = {'up_1'};
            figure(1)
            subplot(3,3,2)
            title('Upsweep segments separated by duration')
            plot(segList{k}.(name){1,2})
            hold on
            break
        elseif IDXup_dur(b) == 2;
            segList{k}.(name){1,7} = {'up_2'};
            figure(1)
            subplot(3,3,5)
            plot(segList{k}.(name){1,2})
            hold on
            break
        elseif IDXup_dur(b) == 3;
            segList{k}.(name){1,7} = {'up_3'};
            figure(1)
            subplot(3,3,8)
            plot(segList{k}.(name){1,2})
            hold on
            break
         end
       end
     end
     for c = 1:length(dur_down)
       tf3 = isequal(segList{k}.(name){1,6},dur_down{c,2});
       if tf3 == 1
        if IDXdown_dur(c) == 1;
            segList{k}.(name){1,7}  = {'down_1'};
            figure(1)
            subplot(3,3,3)
            title('Downsweep segments separated by duration')
            plot(segList{k}.(name){1,2})
            hold on
            break
        elseif IDXdown_dur(c) == 2;
            segList{k}.(name){1,7}  = {'down_2'};
            figure(1)
            subplot(3,3,6)
            plot(segList{k}.(name){1,2})
            hold on
            break
        elseif IDXdown_dur(c) == 3;
            segList{k}.(name){1,7}  = {'down_3'};
            figure(1)
            subplot(3,3,9)
            plot(segList{k}.(name){1,2})
            hold on
            break
        end
       end
     end

 end
 
 end 
%  pause
%  save('segList.mat',segList)
