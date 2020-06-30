function [prevDet,nextDet] = lt_lVis_envDet_LTSA()

global REMORA PARAMS
next = [];
prev = [];

% detection groups
labels = {'', '2', '3', '4', '5', '6', '7', '8'};
[ltsaS,ltsaE] = lt_lVis_get_ltsa_range;

for iDets = 1:length(labels)
    detId = sprintf('detection%s', labels{iDets});
    if isfield(REMORA.lt.lVis_det.(detId),'starts')&& REMORA.lt.lVis_det.(detId).PlotLabels
        labs = REMORA.lt.lVis_det.(detId).bouts.starts;
        labsE = REMORA.lt.lVis_det.(detId).bouts.stops;
        next{iDets} = labs(find(labs>ltsaE,1));
        prev{iDets} = labs(find(labsE<ltsaS,1,'last'));
    end
end

next = [next{:}];
prev = [prev{:}];

%truncate detections to this LTSA file 
next = next(next<=PARAMS.ltsa.dnumEnd(end));
prev = prev(prev>=PARAMS.ltsa.dnumStart(1));

if ~isempty(next)
    next_sort = sort(next);
    nextDet = next_sort(1);
else
    nextDet = [];
end

if ~isempty(prev)
    prev_sort = sort(prev);
    prevDet = prev_sort(end);
else
    prevDet = [];
end
