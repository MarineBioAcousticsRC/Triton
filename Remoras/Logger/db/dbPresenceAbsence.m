function [counts, dayrng, eff] = dbPresenceAbsence(presence, varargin)
% [counts, dayrng, eff] = dbPresenceAbsence(presence, Optional args...)
% Compute presence/absence in resolution_m increments
% Presence is a one or two column matrix giving starting (and 
% possibly ending times) as Matlab serial dates.  If end time 
% is unavailable, only the resolution_m segment containing the 
% start time will be selected. Dates are assumed to be UTC and sorted.
%
% Outputs:
% counts - Output depend on the 'Output' optional argument, see
%          Optional arguments.
%   Matrix with 0/1 presence indicator.  Rows are days,
%   columns make up a day with the number of columns determiend by
%   the Resolution_m argument.
%   OR
%   Row vector with counts in each time period of the day.  Equivalent
%   to summing the matrix output across rows.
% dayrng - First and last day (serial dates, see datestr/datenum)
%   of period covered by analysis
% eff - Matrix or row (as with counts) showing where there was effort.
%  
% Optional arguments:
%  'UTCOffset', N - Convert to local time using an offset of N (default 0)
%  'Effort', SerialDateMatrix - Indicates where effort to detect was
%      made.  Regions of the plot where there was no effort will be
%      displayed with a lighter version of the plot color.
%  'Resolution_m', M - Plot resolution (bin size) in minutes (default 60)
%  'Values', Nx1 - A vector of values with the same number of entries
%         as there are rows in presence.  Rather than populating each
%         entry with a 0/1 indicator value, the corresponding value
%         is used.
%  'Output', String - 
%     'indicator' (default) - counts will be a matrix of indicator 
%         functions where each row is a day and columns correspond 
%         to bins of resolution_m minutes.
%         
%     'counts' - Number of times indicator function was positive, suitable
%         for use in a histogram.  Equivalent to sum(counts) when output
%         is specified as indicator.
%     This option should not be used with the 'Values' option.

if ~ issorted(presence(:,1))
    error('Dates not sorted');
end

% defaults
Effort = [];  % Use passed in dates
UTCOffset = 0;
Resolution_m = 60;
Values = [];
OutputType = 'indicator';
debug = false;

% Process optional arguments
vidx = 1;
while vidx < length(varargin)
    switch varargin{vidx}
        case 'Effort'
            Effort = varargin{vidx+1}; vidx=vidx+2;
            if size(Effort, 2) ~= 2
                error('Effort must have start and end serial dates');
            end        
        case 'UTCOffset'
            UTCOffset = varargin{vidx+1}; vidx=vidx+2;
            if ~isscalar(UTCOffset)
                error('UTCOffset must be scalar')
            end
        case 'Resolution_m'
            Resolution_m = varargin{vidx+1}; vidx = vidx+2;
            if ~ isscalar(Resolution_m)
                error('Resolution_m must be scalar');
            end
        case 'Output'
            OutputType = varargin{vidx+1}; vidx = vidx+2;
            if ~isemtpy(Values)
                error('Cannot specify output with Values');
            end
        case 'Values'
            Values = varargin{vidx+1}; vidx = vidx+2;
            OutputType = 'values';
        otherwise
            error('Bad argument %s', varargin{vidx+1});
    end
end

if UTCOffset ~= 0
    offset = datenum(0, 0, 0, UTCOffset, 0, 0);
    presence = presence + offset;
    if ~ isempty(Effort)
        Effort = Effort + offset;
    end
end

[rows, cols] = size(presence);
if cols > 2
    error('Bad presence information, must be Nx1 or Nx2');
end

HoursPerDay = 24;
MinPerHour = 60;
MinPerDay = HoursPerDay * MinPerHour;
DailyBins = MinPerDay/Resolution_m;  % number of bins/day
Resolution_d = Resolution_m / MinPerDay;  % resolution in days

if ~ isempty(Effort)
    if ~ isempty(presence) && ...
            (presence(1) < Effort(1, 1) || Effort(end, 2) < presence(end,end))
        warning('Detections [%s %s] outside of effort: [%s %s', ...
            datestr(presence(1)), datestr(presence(end, end)), ...
            datestr(Effort(1,1)), datestr(Effort(end,2)));
    end
end

% convert presence information to days and day offsets
% Keep the indices associated with presence so that we
% can map values if the caller has specified 'Values'
[presence_d, presence_o, origInd] = dbDateToOffsets(presence, Resolution_m, 'Merge', false);

if isempty(Effort)
    % Base effort on detections as no effort specified
    first_d = min(presence_d(:,1));
    if size(presence_d, 2) == 1
        last_d = max(presence_d(:,1));
    else
        last_d = max(presence_d(:,2));
    end
else
    % Find start and end of matrix we construct
    first_d = floor(min(Effort(:,1)));
    last_d = ceil(max(Effort(:,2)));    
end
dayrng = floor(first_d):floor(last_d);

% Convert presence into binned presence/absence information
daysN = last_d - first_d;
% Convert presence_d to indices with the first day having an index of 1
% and compute the presence/absence indicator or sum
counts  = Presence2Indicator(presence_d-first_d + 1, ...
    presence_o, daysN, DailyBins, OutputType, Values, origInd);
if nargout > 2 
    if isempty(Effort)
        eff = [];
    else
        % Convert effort to days and partial days
        [eff_d, eff_o] = dbDateToOffsets(Effort, Resolution_m, debug);
        % Build indicator/count matrix for effort
        eff = Presence2Indicator(eff_d-first_d+1, eff_o, daysN, ...
            DailyBins, Resolution_d, OutputType);
    end
end


function counts = Presence2Indicator(index_d, presence_o, daysN, ...
    DailyBins, OutputType, Values, OriginalIndices)
%

% preallocate matrix covering time from first to last detection
counts = zeros(daysN, DailyBins);

% convert day offset to bin
index_m = round(presence_o * (DailyBins-1) + 1);

N = size(index_d, 1);
if N > 0
    for idx = 1:N        
        day = index_d(idx, 1);
        for bin = index_m(idx,1):index_m(idx,2)
            if isempty(Values)
                counts(day, bin) = 1;
            else
                counts(day, bin) = Values(OriginalIndices(idx));
            end
        end
    end
end

if strcmp(OutputType, 'counts')
    % Count #presences per resolution_m bin
    counts = sum(counts);
end
