function [timestamps, missingP] = dbParseDates(dom, varargin)
% [timestamps, missingP] = dbParseDates(records, OptionalArgs)
%
% Given a set of records returned from a dbXPathDOMQuery, parse timestamp
% fields and return them as a matrix of Matlab serial dates.  Each row
% corresponds to the timestamps associated with a single record.
%
% missingP is an indicator function. 1 indicates that the value was
% missing for the record and 0 indicates that a value was extracted.
%
% Optional arguments
%  'Elements', names - Cell array of element names that will be checked
%     Defaults to {'Start', 'End'}
%  'Record, str - Name of element containing the fields from which
%     dates will be extracted.  Defaults to 'Detection'



% defaults
Elements = {'Start', 'End'};
Record = 'Detection';

vidx = 1;
while vidx < length(varargin)
    switch varargin{vidx}
        case 'Elements'
            Elements = varargin{vidx+1};
            if ~ iscell(Elements)
                error('%s argument must be a cell array', varargin{vidx});
            end
            vidx=vidx+2;
        case 'Record'
            Record = varargin{vidx+1};
            k=k+2;
        otherwise
            error('Unknown argument')
    end
end

records = dom.item(0).getElementsByTagName(Record);
N = records.getLength();
% We won't know whether every detection has an endtime until
% we have gone through the set of records.  Assume end times
% for now.
timestamps = zeros(N, 2);
missingP = zeros(N, length(Elements));

for k=1:N
    for t = 1:length(Elements)
        elements = records.item(k-1).getElementsByTagName(Elements{t});
        time_el = elements.item(0);
        missingP(k, t) = isempty(time_el);
        if ~ missingP(k, t)
            value = char(time_el.getTextContent());
            timestamps(k, t) = dbISO8601toSerialDate(value);
        end
    end
end
