function dates = dbISO8601toSerialDate(isodatesZ, offset)
% dates = dbISO8601toSerialDate(isodates, offset)
% Given a cell array of ISO8601 format dates:
%   YYYY-MM-DDTHH:MM:SS.FFFZ
%   e.g. 2010-02-09T07:39:22.325Z
% convert to Matlab serial dates.
% For now, we assume that all times are in UTC and do not
% parse the possible time zone indictator following the Z
%
% The optional parameter offset is a Matlab serial date that
% will be used as an offset.  This is useful for handling time
% zones or converting to Triton format serial dates, which are
% offset from a different date than the standard date.  To
% convert to Triton dates, use -dateoffset() as the offset parameter.


% Variants of ISO 8601 time stamps without timezone
iso8601_fmt = {
    'yyyy-mm-ddTHH:MM:SS.FFF'
    'yyyy-mm-ddTHH:MM:SS';
    'yyyy-mm-ddTHH:MM'
    'yyyy-mm-dd HH:MM:SS.FFF'
    'yyyy-mm-dd HH:MM:SS';
    'yyyy-mm-dd HH:MM'
    };
iso8601_fmt_N = length(iso8601_fmt);

if ischar(isodatesZ)
    % make cell array if string
    isodatesZ = {isodatesZ};
end

isodates = strrep(isodatesZ, 'Z', '');  % Matlab doesn't play well w/ Z
dates = zeros(size(isodates));  % preallocate

% Loop through dates applying the correct ISO format for each one
for row = 1:size(dates, 1)
    for col = 1:size(dates, 2)
        iso = 1;  % first date format to try
        done = false;
        % try to convert date using iso8601_fmt{iso} as the format
        % string.  If it fails, try the next one.
        while ~ done
            try
                dates(row,col) = ...
                    datenum(isodates{row,col}, iso8601_fmt{iso});
                done = true;
            catch e
                if findstr(e.identifier, 'ConvertDateString') > -1 && ...
                        iso < iso8601_fmt_N
                    iso = iso + 1; % bad date format, try next one
                else
                    if ischar(isodates{row, col})
                        e.message = sprintf('%s converting %s', ...
                            isodates{row, col});
                    end
                    rethrow(e);
                end
            end
        end
    end
end

% If user passed in an offset, add it.
if nargin > 1
    dates = dates + offset;
end


