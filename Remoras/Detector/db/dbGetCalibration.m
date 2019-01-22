function [tf, date] = dbGetCalibration(queryH, Id, varargin)
% tf = dbGetTransferFn(queryH, Id, OptionalArgs)
% Retrieve inverse sensitivity function for a given 
% preamp/hydrophone assemblage
%
% Optional args:
%   'Closest', ISO8601 date time - Find calibration closest
%     to the given datetime, e.g. 2012-12-12T12:12:12Z
%     NOT YET IMPLEMENTED
%   'First', true|false - Return first transfer fn matching criteria
%   'Last', true|false - Return last transfer fn matching criteria
%
% WARNING:  Experimental, we have not implemented anything yet
% for multiple calibrations although the database can contain
% calibrations done on different dates.


vidx = 1;
if isnumeric(Id)
    Id = num2str(Id);
end
where = sprintf('where $cal/ID = %s', char(Id));

% default - pick first one
firstlast = true;
first = true;

while vidx < length(varargin)
    switch varargin{vidx}
        case 'Closest'
            firstlast = false;
            error('Not yet implemented');
        case 'First'
            firstlast = true;
            first = varargin{vidx+1};
            vidx = vidx+2;
        case 'Last'
            firstlast = true;
            first = ~ varargin{vidx+1};
            vidx = vidx+2;
        otherwise
            error('Optional argument not implemented');
    end
end
            
queryStr = dbGetCannedQuery('GetCalibrations.xq');
query = sprintf(queryStr, where);
    
dom = queryH.QueryReturnDoc(query);
if isempty(dom)
    error('Unable to retreive calibration %s', Id);
end

xml = xml_read(dom);

if isempty(xml)
    error('Unable to retreive calibration %s', Id);
end

if firstlast
    if first
        idx = 1;
    else
        idx = length(xml.te_COLON_TransferFunction);
    end
    tf = [xml.te_COLON_Calibration(idx).FrequencyResponse.Hz(:), xml.te_COLON_Calibration(idx).FrequencyResponse.dB(:)];
    date = dbISO8601toSerialDate(xml.te_COLON_Calibration(idx).TimeStamp);
    1;
else
    error('More than one calibration selected')
end
    
