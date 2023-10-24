function night = dbDiel(query_eng, lat, long, start, stop, varargin)
% night = dbDiel(query_eng, lat, long, start, stop, Optional)
% Return information from database about when sunrise and sunset occur 
% across the specified interval between start and stop time.  
%
% query_eng - Server handle, Result of dbInit
% lat - latitude (-90, 90)
% long - longitude degrees East [0, 360)
% start - start time of analysis, Matlab serial date (datenum), datetime,
%   or ISO8601 time string
% stop - end time of analysis (datenum/datetime)
%
% night will contain serial dates (defaults to UTC time) with each row
% specifying the sunset and sunrise time.
%
% Optional arguments:
%  'type', SunsetType - 
%     'setrise' (default)- When the sun sets/rises, uses the US Naval 
%       Observatory default which is about -34 arc minutes below the 
%       horizon to account for refraction.
%     'civil' - sun is 6° below horizon
%     'nautical' - sun is 12° below horizon
%     'astronomical' - sun is 18° below horizon
%  'UTCOffset', N - Return values are offset by N hours (e.g. -4.5
%     four and a half hours before UTC).  The start and stop times
%     are still assumed to be UTC.
%
% Caveats:  
%  When the interval begins after sunset, night(1, 1) is set to  start
%  When the interval ends before sunset, night(end, 2) is set to stop
%
% Example
% San Diego:  117˚09'21.6''W, 32˚42'52.9''N
% long = 360 - (117 + 09/60 + 21.6/3600)
% lat = 32 + 42/60 + 52.9/3600
% altitude = -0.001451  (km)
% Format query string:

if lat <-90 || lat > 90
    error('Geodetic latitude must be in degrees North [-90, 90]')
end
if long < 0 || long > 360
    error('Geodetic longitude must be in degrees East [0, 360]')
end

% Put timestamps in datetime format
iso8601 = "yyyy-MM-dd'T'HH:mm:ssZ";  % ISO 8601 format 
if isnumeric(start)
    start = datetime(start, 'ConvertFrom', 'datenum');
elseif ischar(start) || isstring(start)
    start = datetime(start, "TimeZone", "UTC", "Format", iso8601);
end

if isnumeric(stop)
    stop = datetime(stop, 'ConvertFrom', 'datenum');
elseif ischar(stop) || isstring(stop)
    stop = datetime(stop, "TimeZone", "UTC", "Format", iso8601);
end    

% defaults
type = 'setrise';
UTCOffset = 0;

idx = 1;
while idx < length(varargin)
    switch varargin{idx}
        case 'type'
            type = varargin{idx+1};
            idx = idx+2;
        case 'UTCOffset'
            UTCOffset = varargin{idx+1}; idx=idx+2;
            if ~isscalar(UTCOffset)
                error('UTCOffset must be scalar')
            end
        case 'CacheUpdate'
            if varargin{idx+1} > 0
                CacheUpdate = ':cacheupdate'
            end;
            idx = idx + 2;                
        otherwise
            error('Bad arugment:  %s', varargin{idx});
    end
end

switch type
    case 'setrise'
        horizon = dms2degrees([0, -34, 0]);
    case 'civil'
        horizon = -6;
    case 'nautical'
        horizon = -12;
    case 'astronomical' 
        horizon = -18;
    otherwise
        error('Unexpected diel type');
end

% shift the start date 1 day earlier and stop date 1 day later to ensure
% that we get all night/day transitions
prior_day = dateshift(start, 'start', 'day') - days(1);
subsequent_day= dateshift(stop, 'end', 'day') + days(1);


queryStr = sprintf(['collection("ext:solar")/', ...
    'latitude=%f/longitude=%f/', ...
    'start="%s"/stop="%s"/horizon=%.4f!'], ...
    lat, long, ...
    datestr(prior_day, 'yyyy-mm-ddTHH:MM:SS'), ...
    datestr(subsequent_day, 'yyyy-mm-ddTHH:MM:SS'), ...
    horizon);

% Run XML query to retrieve ephemeris information
try
    %doc = query_eng.QueryReturnDoc(queryStr);
    xmlstr = query_eng.Query(queryStr);
catch e
    if ~isempty(findstr(e.message, 'getaddrinfo failed'))
        warning('getaddrinfo failed, unable to obtain ephemeris')
        night = [];
        return
    else
       rethrow(e);
    end
end


typemap = {
    'date','datetime'    
};
data = tinyxml2_tethys('parse', char(xmlstr), typemap);
if iscell(data) && isempty(data{1})
    night = [];  % nothing found
    return;
end

timestamps = cell2mat([data.entry.date]');
daynight = string([data.entry.sun]');

N = round(length(daynight)/2);
night = zeros(N, 2);

nidx = 1;
if strcmp(daynight(1), "day")
    % Start of effort is during the night.  Set first night to start
    night(nidx,1) = datenum(start);
end
for idx=1:length(timestamps)
    if strcmp(daynight(idx), "day")
        night(nidx, 2) = timestamps(idx);
    else
        % New night, next row
        nidx = nidx + 1;
        night(nidx, 1) = timestamps(idx);
    end
end
if strcmp(daynight(end), "night")
    % End of effort during night.  Set end of night to stop effort
    night(nidx, 2) = datenum(stop);
end

if UTCOffset
    night = night + datenum([0 0 0 UTCOffset 0 0]);
end
1;
