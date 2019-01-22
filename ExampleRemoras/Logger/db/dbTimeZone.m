function offset = dbTimeZone(queries, latitude, longitude, method)
% offset = dbTimeZone(queries, longitude, longitude, method)
% Retrieve offset from UTC time for specified longitude and latitude
%
% Inputs:
% queries - query engine handle
% longitude - degrees east (-180, 180] or [0, 360)
% latitude - degrees north [-90, 90]
% method -  Optional
%       nautical - Nautical 15 degree timezones centered on
%           the prime meridean (default if not specified)
%       civil - Geopolitcial timezone (experimental)

if nargin < 4
    method = 'nautical';
end

if latitude < -90 || latitude > 90
    error('latitude must be in degrees north [-90, 90]')
end
if longitude < -180 || longitude > 360
    error('longtitude must be degrees east [-180, 180] or [0, 360]')
end

query = sprintf(...
    'collection("ext:timezone")/longitude=%f/latitude=%f/tztype="%s"!', ...
    longitude, latitude, method);

dom = queries.QueryReturnDoc(query);
if ~ isempty(dom)
    % Retrieve the offset
    [odom, offset_str] = dbXPathDomQuery(dom, 'timezone/offset');
    offset = sscanf(offset_str{1}, '%f');
else
    error('TimeZone not returned');
end

1;


