function [delFlag] = sp_dt_postproc(outFileName,clickTimes,p,hdr,encounterTimes)

% Step through vector of click times, looking forward and back to throw out
% solo clicks, and pairs of clicks, if they are too far away from a cluster
% of clicks with >2 members.
% outputs a vector of pruned times, and a vector flagging which members
% should be removed from other variables.
% Writes pruned times to .pTg file.

delFlag = ones(size(clickTimes(:,1))); % t/f vector of click deletion flags. 
% starts as all 1 to keep all clicks. Elements switch to zero as clicks are
% flagged for deletion.

%%% Get rid of lone clicks %%%
if p.rmLonerClicks
   
    % Step through deleting clicks that are too far from their preceeding
    % and following click    
    if size(clickTimes,1) > 2
        for itr1 = 1:size(clickTimes,1)
            if itr1 == 1
                if clickTimes(itr1+2,1)-clickTimes(itr1,1)>p.maxNeighbor
                    delFlag(itr1) = 0;
                end
            elseif itr1 >= size(clickTimes,1)-1
                [I,~] = find(delFlag(1:itr1-1)==1);
                prevClick = max(I);
                if isempty(prevClick)
                    delFlag(itr1) = 0;
                elseif clickTimes(itr1,1) - clickTimes(prevClick,1)>p.maxNeighbor
                    delFlag(itr1) = 0;
                end
            else
                [I,~] = find(delFlag(1:itr1-1)==1);
                prevClick = max(I);
                if isempty(prevClick)
                    if clickTimes(itr1+2,1) - clickTimes(itr1,1)>p.maxNeighbor
                        delFlag(itr1) = 0;
                    end
                elseif clickTimes(itr1,1)- clickTimes(prevClick,1)>p.maxNeighbor &&...
                        clickTimes(itr1+2,1)-clickTimes(itr1,1)>p.maxNeighbor
                    delFlag(itr1) = 0;
                end
            end
        end
    else
        delFlag = zeros(size(clickTimes(:,1)));
    end
end
% TODO: Get rid of pulsed calls

% get rid of duplicate times:
if size(clickTimes,1)>1
    dtimes = diff(clickTimes(:,1));
    closeStarts = find(dtimes<.00002);
    delFlag(closeStarts+1,:) = 0;
end

if p.rmEchos
    % Added 150318 KPM - remove echoes from captive recordings.  Lock out
    % period N seconds from first click detection of set. 

    iCT = 1;
    while iCT <= size(clickTimes,1)
        thisClickTime = clickTimes(iCT(:,1));
        tDiff = clickTimes(:,1) - thisClickTime;
        echoes = find(tDiff <= p.lockOut & tDiff > 0);
        delFlag(echoes,1) = 0; % flag close clicks in time for deletion.
        if isempty(echoes) % advance to next detection
            iCT = iCT +1;
        else % or if some were flagged, advance to next true detection
            iCT = echoes(end)+1;
        end
    end
end

%%%% Remove times outside desired times, for guided detector case
if p.guidedDetector
    if ~isempty(encounterTimes)
        % Convert all clickTimes to "real" datenums, re baby jesus
        sec2dnum = 60*60*24; % conversion factor to get from seconds to matlab datenum
        clickDnum = (clickTimes./sec2dnum) + hdr.start.dnum + datenum([2000,0,0]);
        for itr2 = 1:size(clickDnum,1)
            thisStart = clickDnum(itr2,1);
            thisEnd = clickDnum(itr2,2);
            afterStarts = find(encounterTimes(:,1)> thisStart);
            firstAfterStart = min(afterStarts); % this is the start of the guided period it should be in
            beforeEnd = find(encounterTimes(:,2)> thisEnd);
            firstBeforeEnd = min(beforeEnd);
            if firstAfterStart ~= firstBeforeEnd
                % Then this click does not fall within an encounter, chuck it
                delFlag(itr2) = 0;
            end
        end
    else
        fprintf('No times to prune.\n')
    end
end

clickTimesPruned = clickTimes(delFlag==1,:); % apply deletions

if ~isempty(outFileName)
fidOut = fopen(outFileName,'w+');

if ~isempty(clickTimesPruned)
    for itr3 = 1:size(clickTimesPruned,1)
        % Write post-processed click annotations to .cHR file
        fprintf(fidOut, '%f %f\n', clickTimesPruned(itr3,1),clickTimesPruned(itr3,2));
    end
else
    fprintf(fidOut, 'No clicks detected.');
end

fclose(fidOut);
else
    % fprintf('No output file written in gui mode.');
end 