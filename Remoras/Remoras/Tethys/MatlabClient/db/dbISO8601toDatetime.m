function iso8601 = dbISO8601toDatetime(isodates)
% iso8601 = dbISO8601toDatetime(isodates)
% Given a set of datestrings in ISO8601 format:
%   YYYY-MM-DDTHH:MM:SSZ
%   YYYY-MM-DDTHH:MM:SS+-08:00
%   etc.
% convert them to Matlab datetime objects.  Failures in parsing result
% in NaT entries that can be checked for with isnat(iso8601).
%
% CAVEATS:
%   Not fully ISO8601 compliant, e.g., T separator is required
%   Does not work well on mixed timestamps with and without fractional
%     seconds.

try
    iso8601 = datetime(isodates, ...
        "InputFormat","uuuu-MM-dd'T'HH:mm:ss.SXXX", ...
        "Format", "uuuu-MM-dd'T'HH:mm:ss.SSSSSSS", ...
        "TimeZone","UTC");
catch e
    iso8601 = datetime(isodates, ...
        "InputFormat","uuuu-MM-dd'T'HH:mm:ssXXX", ...
        "Format", "uuuu-MM-dd'T'HH:mm:ss.SSSSSS", ...
        "TimeZone","UTC");
end
