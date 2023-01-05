function [tf, date] = dbGetTransferFn(queryH, Id, varargin)
%%% DEPRECATED! TransferFunctions collection is now Calibrations
%%% use dbGetCalibration to query that collection.
%
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

% default - pick first one
args = {};
while vidx < length(varargin)
    switch varargin{vidx}
        case 'Closest'
            args = {'Timestamp', varargin{vidx+1}};
            vidx = vidx + 2;
        case 'First'
            if varargin{vidx+1} == true
                args = {'Timestamp', 'earliest'};
            end
            vidx = vidx + 2;
        case 'Last'
            if varargin{vidx+1} == true
                args = {'Timestamp', 'latest'};
            end
            vidx = vidx + 2;
        otherwise
            error('Optional argument not implemented');
    end
end

warning(['dbGetTransferFn deprecated and will be removed in a future release.\n', ...
    'Use dbGetCalibration() instead.']);
[tf, date] = dbGetCalibration(queryH, Id, args{:});
