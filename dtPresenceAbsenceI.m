function [presenceI, timestamps] = dtPresenceAbsenceI(presence, varargin)
% 
% Populate presence indicator vector (presenceI) quantized by 
% a specified number of minutes (Resolution_m, see below).
% Presence is a one or two column matrix giving starting (and 
% possibly ending times) as Matlab serial dates.  If end time 
% is unavailable, only the resolution_m segment containing the 
% start time will be selected. Dates are assumed to be UTC and sorted.
% 
% timestamps(idx, :) will contain the serial date start times such
% that timestamps(idx,1) <= time of presenceI(idx) < timestamps(idx,2)
%
% Optional arguments:
%  'UTCOffset', N - Convert to local time using an offset of N (default 0)
%  'Color' - Specify color as a string (e.g. 'g' or 'green') or as
%      a red, green, blue triplet.  Avoid using light colors as they
%      will be lightened to show areas without effort.  Default 'blue'.
%  'NoEffortColor' - Color for no effort, similar to color.  Defaults
%      to a transparent version of color which will not work well in
%      a legend.
%  'Effort', SerialDateMatrix - Indicates where effort to detect was
%      made.  Regions of the plot where there was no effort will be
%      displayed with a lighter version of the plot color.
%  'Resolution_m', M - Plot resolution (bin size) in minutes (default 60)


% defaults
Effort = [];  % Use passed in dates
Resolution_m = 5;
debug = false;
UTCOffset = 0;


if ~ issorted(presence(:,1))
    error('Dates not sorted');
end

vidx = 1;
while vidx < length(varargin)
    switch varargin{vidx}
        case 'UTCOffset'
            UTCOffset = varargin{vidx+1}; vidx=vidx+2;
            if ~isscalar(UTCOffset)
                error('UTCOffset must be scalar')
            end
        case 'Effort'
            Effort = varargin{vidx+1}; vidx=vidx+2;
            if size(Effort, 2) ~= 2
                error('Effort must have start and end serial dates');
            end

        case 'Resolution_m'
            Resolution_m = varargin{vidx+1}; vidx = vidx+2;
            if ~ isscalar(Resolution_m)
                error('Resolution_m must be scalar');
            end
        case 'Debug'
            debug = varargin{vidx+1}; vidx = vidx+2;
        otherwise
            error('Bad argument %s', varargin{vidx+1});
    end
end


[rows, cols] = size(presence);
if cols > 2
    error('Bad presence information, must be Nx1 or Nx2');
end

if ~ isempty(Effort)
    if ~ isempty(presence) && ...
            (presence(1) < Effort(1, 1) || Effort(end, 2) < presence(end,end))
        warning('Detections [%s %s] outside of effort: [%s %s', ...
            datestr(presence(1)), datestr(presence(end, end)), ...
            datestr(Effort(1,1)), datestr(Effort(end,2)));
    end
else
    % Set effort to be from first to last detection
    % (not typically a good idea)
    Effort = [min(min(presence)), max(max(presence))];
end

% default to detections and override later if needed
if cols == 1
    dates = [min(presence(:,1)), max(presence(:,1))];
else
    dates = [min(presence(:,1)), max(presence(:,2))];
end

% Allocate number of bins needed
Resolution_ser = datenum(0,0,0,0,Resolution_m,0);  % serial date resolution
start = floor(min(Effort(:,1)) / Resolution_ser) * Resolution_ser;
stop = ceil(max(Effort(:,2)) / Resolution_ser) * Resolution_ser;
binsN = round((stop - start) / Resolution_ser);
presenceI = zeros(binsN, 1);


% Set up timestamps if user wants them
if nargout > 1
timestamps = [ ...
    [start:Resolution_ser:stop-Resolution_ser]', ...
    [start+Resolution_ser:Resolution_ser:stop]'];
end

% Convert presence times to indices
presenceIdcs = floor((presence - start) ./ Resolution_ser) + 1;

if size(presenceIdcs, 2) == 1
    % Start times only, just set indices
    presenceI(presenceIdcs) = 1;
else
    % Start and end times, set range
    lengths = diff(presenceIdcs, 1, 2);  % first diff across columns
    for idx=1:length(lengths)
        presenceI(presenceIdx(idx,1):presenceIdx(Idx,2)) = ...
            ones(1,lengths(idx));
    end
end

% If multiple regions of effort, set times between to NaN
if size(Effort, 1) > 1
    % Find times between efforts and convert them to indices
    NoEffort = [Effort(1:end-1, 2), Effort(2:end, 1)];
    
    % The times without effort may not occur on boundaries for which
    % we have discretized things.  When this occurs, the no-effort
    % edge is moved towards to the edge of the next boundary for
    % start of no effort and before for the previous one
    
    NotOnBoundary = rem(NoEffort, Resolution_ser) > 0;
    
    NoEffortIdcs = floor((NoEffort - start) ./ Resolution_ser) + 1;
    
    erorr('Multiple effort boundaries not yet supported (todo)')
    
end
