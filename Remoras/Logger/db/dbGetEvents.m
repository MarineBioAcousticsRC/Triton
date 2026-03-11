function [timestamps, events, EndP] = dbGetEvents(queryEngine, varargin)
% [timestamps, events, endPredicate] = dbGetEvents(queryEngine, Optional Args)
% Retrieve detections meeting criteria from database.  Detections
% are returned as a timestamps matrix of Matlab serial dates (see
% datenum).  The timestamps will either be instantaneous or span an 
% intveral.  (Instantaneous events can be converted to fixed period 
% events with the optional 'Duration' parameter (see below).  The
% optional endP return value allows callers to distinguish between
% intrval and instantaneous detections.  Its usage is described at the
% example at the end of this help.
%
% Inputs:
% queryEngine must be a Tethys database query object, see dbDemo() for an
% example of how to create one.
%
% To query for specific types of detections, use any combination of the 
% following keyword/value pairs:
%
% 'Start', date - >= start as Matlab serial date (datenum)
% 'End', date - <= end as Matlab serial date
%
% Comparison consists of either a:
%   scalar - queries for equality (unless otherwise specified)
%   cell array {operator, scalar} - Operator is a relational
%       operator in {'=', '<', '<=', '>', '>='} which is compared
%       to the specified scalar.
%
%
% Example:  Retrieve events between 
% from Southern California regardless of project.  Note that when
% multiple attirbutes are specified, all criteria must be satisfied.  
% startd = datenum([2010 1 1]);
% endd = datenum([2010 12 31 23 59 59.999]);
% [events, endP] = dbGetEvents(qengine, 
%                         'Start', startd, 'End', endd);
%
% Output is a one or two column matrix of start and (if available) end
% times of detections.  If the result contains instantaneous detections
% and two columns are returned due to interval detections also being 
% present, the time end predicate (endP) can be used to determine
% which is which.  Where endP(row_idx) = 1, detections(row_idx, :) will
% be an interval detection.  Accordingly, a 0 indicates an instantaneous
% detection.
% Example: [detections, endP] = dbGetDetections(...);
% Interval detections: detections(endP, :)
% Instantaneous detections:  detections(~endP, 1)


conditions = '';  % selection criteria 
% condition prefix/cojunction
% First time used contains where to form the where clause.
% On subsequent uses it is changed to the conjunction and
conj = 'where';  
vidx=1;
while vidx < length(varargin)
    switch varargin{vidx}
        case 'Start'
            % Convert Matlab date to ISO 8601 and format with
            % appropriate relational operator (>= unless user
            % specified otherwise)
            date = sprintf('xs:dateTime("%s")', ...
                dbSerialDateToISO8601(varargin{vidx+1}));
            relop = dbRelOp(varargin{vidx}, '$event/%s', date, '>=');
            conditions = sprintf('%s%s %s', conditions, conj, relop);
            conj = ' and';
            vidx = vidx+2;
        case 'End'
            % Convert Matlab date to ISO 8601 and format with
            % appropriate relational operator (<= unless user
            % specified otherwise)
            date = sprintf('xs:dateTime("%s")', ...
                dbSerialDateToISO8601(varargin{vidx+1}));
            relop = dbRelOp(varargin{vidx}, '$event/%s', date, '<=');
            conditions = sprintf('%s%s %s', conditions, conj, relop);
            conj = ' and';
            vidx = vidx+2;
        % todo - Long/Lat bounding box
        otherwise
            error('Bad arugment:  %s', varargin{idx});
    end
end

query_str = dbGetCannedQuery('GetEvents.xq');
query = sprintf(query_str, conditions);
dom = queryEngine.QueryReturnDoc(query);

% Retrieve detection records from document model
if isempty(dom)
    timestamps = [];
else
    records = dbXPathDomQuery(dom, 'ty:Result/Event');
    
    N = records.getLength();
    events = cell(N, 1);
    if N > 0
        for k=1:N
            elements = records.item(k-1).getElementsByTagName('Name');
            events{k} = char(elements.item(0).getTextContent());
        end

        [timestamps, missingP] = dbParseDates(records);
        EndCount = sum( ~missingP(:,end));

        if EndCount == 0 
            % No end times were detected
            if event_duration == 0
                timestamps(:, 2) = [];  % No duration, remove end time
            else
                % Set interval to specified duration
                % Note that there is no guarantee that this will not create
                % overlapping events.
                timestamps(:, 2) = timestamps(:, 1) + event_duration;
            end
        end

        if ~ issorted(timestamps(:, 1))
            fprintf('sorting timestamps...');
            [dontcare, perm] = sort(timestamps(:,1));
            timestamps = timestamps(perm, :);
            fprintf('done\n');
        end
    else
        timestamps = [];
        EndP = false;
    end
end
