function night = dbDiel(query_eng, lat, long, start, stop, varargin)
% night = dbDiel(query_eng, lat, long, start, stop, Optional)
% Return information from database about when sunrise and sunset occur 
% across the specified interval between start and stop which are UTC
% serial dates (see datenum).  Sunrise and Sunset information are 
% given as serial dates in UTC time in columns 1 and 2 respecitvely of 
% sunrise_sunset.  
%
% Position is specified as decimal longitude [0-360) and latitude [-90 90].
% Negative latitudes indicate the southern hempisphere.
% Longitudes > 180 degrees are west.
%
% Optional arguments:
%  'type', SunsetType - default civil, not well tested with other
%     types:  nautical, astronomical
%  'UTCOffset', N - Return values are offset by N hours (e.g. -4.5
%     four and a half hours before UTC).  The start and stop times
%     are still assumed to be UTC.
%  'CacheUpdate', N - By default, we use server cached entries if they
%     are available.  When N > 0, we will update the cache with fresh
%     results from the Internet.  This is not typically needed.
%
% Caveats:  
%  When the interval begins after sunrise, 
%   sunrise_sunset(1, 1) is set to  start
%  When the interval ends before sunset, 
%   sunrise_sunset(end, 2) is set to stop

% For testing 
% San Diego:  117°09'21.6''W, 32°42'52.9''N
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

% defaults
type = 'civil';
% store new server cache entries, but don't update old ones
CacheUpdate = '';
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

% shift the start date 1 day earlier and stop date 1 day later to ensure
% that we get all night/day transitions
offset_start = floor(start);
offset_stop = floor(stop);
start = start - 1;
stop = stop + 1;

%Warn user that query may fail
if stop > start+400
    fprintf(['WARNING: Large date range requested, Horizon''s server may'...
        ' reject it. Split into smaller ranges if so']);
end
queryStr = sprintf(['collection("ext:horizons%s")/', ...
    'target="sol"/latitude=%f/longitude=%f/', ...
    'start="%s"/stop="%s"/interval="5m tvh"!'], ...
    CacheUpdate, lat, long, ...
    datestr(start, 'yyyy-mm-ddTHH:MM:SS'), ...
    datestr(stop, 'yyyy-mm-ddTHH:MM:SS'));

import org.apache.xmlrpc.XmlRpcException;

% Run XML query to retrieve ephemeris information
try
    doc = query_eng.QueryReturnDoc(queryStr);
catch e
    if ~isempty(findstr(e.message, 'getaddrinfo failed'))
        warning('getaddrinfo failed, unable to obtain ephemeris')
        night = [];
        return
    else
       rethrow(e);
    end
end


% find day/night transitions
% day and or night may be repeated due to events such
% as moon rise/set/transit
nodes = dbXPathDomQuery(doc, 'ephemeris/entry');
[sunhandles, daynight] =  dbXPathDomQuery(doc, 'ephemeris/entry/sun');

transitions = find(strcmp(daynight(1:end-1), daynight(2:end)) == 0) + 1;

% count number of night periods
nightsN = sum(strcmp(daynight([1; transitions]), 'night'));
night = zeros(nightsN, 2);

k = 0;
if strcmp(daynight{1}, 'night')
    % started at night, use start time
    k = k+1;
    night(k, 1) = start;
end

% Finish writing this, trying to allow user to specify civil, astronomical,
% or natuical transitions we're looking for
%l = 0;
%for d = daynight'
%    if sunhandles.item(l).getAttribute('type') ~= ''
%        daynight(l+1) = sunhandles.item(l).getAttribute('type');
%    end
%    l = l+1;
%end

for t=transitions'
    switch daynight{t}
        case 'day'
            if k > 0
                % Start of day, close off previous night entry
                [x, tod] = dbXPathDomQuery(nodes.item(t-1), 'date');
                night(k, 2) = datenum(tod);
            end
        case 'night'
            [x, tod]= dbXPathDomQuery(nodes.item(t-1), 'date');
            k=k+1;  % start new entry
            night(k, 1) = datenum(tod);
    end
end

if strcmp(daynight(end), 'night')
    % ended during night, use end time
    night(k, 2) = datenum(stop);
end

% check start time and end time, resize to fit offset_start and offset_stop
while true
    if night(1,2) < offset_start
        % remove the first row and continue
        night(1,:) = [];
    else
        % found the earliest full night transition
        if night(1,1) < offset_start
            night(1,1) = offset_start;
        end
        break;
    end
end
% k is the index of the last row in night
k = size(night, 1);
while true
    if night(k,1) > offset_stop
        % remove the last row and continue
        night(k,:) = [];
        k = k - 1;
    else
        % found the last full night transition
        if night(k,2) > offset_stop
            night(k,2) = offset_stop;
        end
        break;
    end
end
    
night = night + datenum([0 0 0 UTCOffset 0 0]);
1;
