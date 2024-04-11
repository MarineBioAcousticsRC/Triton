function iso = SerialDateToISO8601(serial)
% Convert a set of of Matlab serial dates to ISO8601 format
% It is assumed that the dates are in UTC.

if numel(serial) > 1
    iso = cell(size(serial));
    if isa(serial, 'table')
        serial = table2array(serial);
    end
    for t = 1:numel(serial);
        iso{t} = SerialToISO(serial(t));
    end
else
    iso = SerialToISO(serial);
end

function iso = SerialToISO(serial)
iso = datestr(serial, 'YYYY-mm-ddTHH:MM:SS.FFFZ');