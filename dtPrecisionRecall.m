function Result = dtPrecisionRecall(queryH, Detections, Groundtruth, Resolution_m)
% dtPrecisionRecall(queryH, ...
% Compute the precision and recall

if nargin < 4
    Resolution_m = 60;
end

trialsN = length(Detections);  % how many to compare against

% Pull up information about the groundtruth
[gtEffort, gtDetails] = dbGetEffort(queryH, 'Document', Groundtruth);

% Process by call and species
Result = gtDetails.Kind;
for sidx = 1:length(gtDetails.Kind)
    if ~ iscell(Result(sidx).Call)
        % Let us treat single call types like everything else
        Result(sidx).Call = {Result(sidx).Call};
    end
    
    callsN = length(Result(sidx).Call);
    
    Result(sidx).Precision = zeros(trialsN, callsN);
    Result(sidx).Recall = zeros(trialsN, callsN);

    for cidx = 1:callsN
        % Retrieve detections
        detections = dbGetDetections(queryH, 'Document', Groundtruth, ...
            'SpeciesCode', Result(sidx).SpeciesCode, ...
            'Call', Result(sidx).Call{cidx});
        Effort = [dbISO8601toSerialDate(gtDetails.Start), ...
            dbISO8601toSerialDate(gtDetails.End)];
        
        [detectionsI, timestamps] = dtPresenceAbsenceI(...
            detections, 'Effort', Effort, 'Resolution_m', Resolution_m);
                
        cumulativeI = zeros(size(detectionsI, 1), 1);
        
        for testidx = 1:trialsN
            % Pull in the test detections
            testdet = dbGetDetections(queryH, ...
                'Document', Detections{testidx}, ...
                'SpeciesCode', Result(sidx).SpeciesCode, ...
                'Call', Result(sidx).Call{cidx});
            
            testI{testidx} = dtPresenceAbsenceI(...
                testdet, 'Effort', Effort, ...
                'Resolution_m', Resolution_m);
            cumulativeI = cumulativeI + testI{testidx};
            
            % Compute precison and recall
            Result(sidx).Recall(testidx, cidx) = ...
                sum(testI{testidx}' & detectionsI') / sum(detectionsI);
            % stopped here Result(sidx).Precision(testidx) = 
            Result(sidx).Precision(testidx, cidx) = ...
                sum(testI{testidx}' & detectionsI') / sum(testI{testidx});
            1;
        end
        
    end
    1;
end



