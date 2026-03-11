function [day, m, originalIndices] = dbDateToOffsets(...
    serdate, resolution_m, varargin)
% [day, m, originalIndices] = dbDateToOffsets(serdate, resolution_m, 
%      OptionalArguments)
% Given one or two columns of serial dates, convert to
% day numbers and resolution_m m bins.  
%
% For one column data, the a second column will be added that
% is resolution_m minutes after the start time.
%
% For two column data, the second column is rounded up to the
% start of the next bin
%
% Returns Nx2 matrices for days and minutes showing the timespan
% of contiguous detections within each day.
% 
% The optional output originalIndices shows which row of serdate
% is associated with each entry in day and m.
%
% Optional arguments
% 'Debug', true|false - Output information about the conversion.  
%                       Default: false
% 'Merge', true|false - Combine adjacent resolution_m periods.
%                       Warning:  Only the first index of original
%                       indices will be reported for merged segments.
%                       Default: true
%
% For row k, time span is from:
%   day(k,1), m(k,1) minutes into the day to day(k,2) m(k,2) 

if isempty(serdate)  % empty input
    day = [];
    m = [];
    return
end

% defaults
Debug = false;
Merge = true;

vidx = 1;
while vidx < length(varargin)
    switch varargin{vidx}
        case 'Debug'
            Debug = varargin{vidx+1}; vidx = vidx + 2;
        case 'Merge'
            Merge = varargin{vidx+1}; vidx = vidx + 2;
        otherwise
            error('Bad optional argument');
    end
end
resolution_d = resolution_m / (24 * 60);

% offset to previous day
onems_d = .001 / (24*3600);  % 1 ms in days

% Verify integrity of serial dates
if ~ issorted(serdate(:,1))
  error('Dates must be sorted');
end


if size(serdate, 2) == 2
    % find any days that cross midnight(s) and break into
    % one detection per day
    
    % Make sure every end time is actually after the start time
    badrows = find(serdate(:,2) - serdate(:, 1) < 0);
    if ~isempty(badrows)
      badrowstr = sprintf('%d ', badrows);
      error('End before start, rows %s', badrowstr);
    end
    
    % Number of calendar days between start of detection and end
    days_since_start = diff(floor(serdate), 1, 2);  % 1st diff across rows
    
    % How many rows must be added?
    newrows = sum(days_since_start);  
    
    if newrows > 0
        newdates = zeros(size(serdate, 1)+newrows, 2);
        originalIndices = zeros(size(newdates,1), 1);
        % segment the dates into chunks where the last row 
        % crosses a day boundary and everything else is in the
        % same day.
        prev_row = 1;  % chunk start
        orig_idx = 1;
        offset = 0;  % Track how many days we have added
        prev_split = 0;
        for split = find(days_since_start >= 1)'
            originalIndices(prev_split+offset+1:split+offset) = orig_idx:split;
            newdates(prev_row+offset:split+offset, :) = ...
                serdate(prev_row:split, :);
            % split the day that cross midnight
            ndays = days_since_start(split);
            nextday = floor(serdate(split, 1))+1;
            while ndays > 0
                % set end of day to midnight - 1 ms
                newdates(split+offset, 2) = nextday - onems_d;
                originalIndices(split+offset) = split;
                % offset moves to next row
                offset = offset + 1;
                newdates(split+offset, 1) = nextday;
                nextday = nextday + 1;
                ndays = ndays - 1;
            end
            newdates(split+offset, 2) = serdate(split, 2);
            originalIndices(split+offset) = split;
            prev_row = split + 1;
            orig_idx = split + 1;
            prev_split = split;
        end
        if split < size(serdate, 1)
            % there additional dates after the last split
            newdates(split+offset+1:end, :) = serdate(split+1:end, :);
        end
        serdate = newdates;
    else
        originalIndices = 1:size(serdate, 1);
    end
else
    originalIndices = 1:length(serdate);
end

% seperate into days and minutes
day = floor(serdate);
m = serdate - day;

% map start times to earliest resolution_d block
correction = resolution_d * .01;  % rounding correction
m(:,1) = floor(m(:,1)/resolution_d+correction)*resolution_d;

if size(serdate,2) == 2
    % map end times to next resolution_d block
    m(:,2) = ceil(m(:,2)/resolution_d)*resolution_d;
else
    % no end time, span to beginning of next block
    m = [m(:,1), m(:,1)+resolution_d];
end

% merge contiguous segments
if size(m, 1) > 1 && Merge == true
    % End of current block goes into start of next
    mergeP = m(1:end-1, 2) - m(2:end, 1) > -1e-10;  % >0 w/ rounding error
    if size(day, 2) == 1
        mergeP = mergeP & day(1:end-1,1) == day(2:end, 1);
    else
        mergeP = mergeP & day(1:end-1,2) == day(2:end,1);
    end

    if Debug
        fprintf('Dates broken down into day/minute offsets\n');
        fprintf('Breaks should occur at midnight\n');
        for k=1:size(m,1);
            if k < size(m,1)
                fprintf('%2d %d\t%s\t%s\n', k, mergeP(k), ...
                    datestr(day(k)+m(k,1), 0 ), datestr(day(k)+m(k,2)), 0);
            else
                fprintf('%2d %d\t%s\t%s\n', k, 0, ...
                    datestr(day(k)+m(k,1), 0), datestr(day(k)+m(k,2), 0));
            end
        end
    end
    
    % Merge blocks
    % When multiple blocks are adjacent, merge all into one
    delete = find(mergeP == 1);
    %fprintf('delete: '); fprintf('%d ', delete); fprintf('\n');
    idx = 1;
    while idx <= length(delete)
        start = m(delete(idx), 1);
        stop = m(delete(idx), 2);  % track latest stop time
        while idx < length(delete) & delete(idx+1) - delete(idx) == 1
            idx = idx + 1;
            stop = max(stop, m(delete(idx), 2));
        end
        m(delete(idx)+1, :) = [start, max(stop, m(delete(idx)+1, 2))];
        idx = idx + 1;
    end
    day(delete,:) = []; % Remove blocks
    m(delete,:) = [];
    originalIndices(delete) = [];
    
    if Debug
        fprintf('Result of merging contiguous blocks\n')
        for k=1:size(m,1);
            fprintf('%d\t%s\t%s\n', k, ...
                datestr(day(k)+m(k,1)), datestr(day(k)+m(k,2)));
        end
    end
end

end % end day_to_daym
