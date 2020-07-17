function [prevDet,nextDet] = lt_lVis_envDet_rf()

global REMORA PARAMS HANDLES
next = [];
prev = [];

% detection groups
labels = {'', '2', '3', '4', '5', '6', '7', '8'};

%create start and end times of window
startWV = PARAMS.plot.dnum;
if isfield(HANDLES.subplt,'specgram')
    winLength = HANDLES.subplt.specgram.XLim(2); %get length of window in seconds, used to compute end limit
elseif isfield(HANDLES.subplt,'timeseries')
    winLength = HANDLES.subplt.timeseries.XLim(2);
else
    disp('WARNING: cannot jump to next/previous rf detection. Please plot either spectrogram, timeseries, or both to use this function')
end
endWV = startWV + datenum(0,0,0,0,0,winLength);


for iDets = 1:length(labels)
    detId = sprintf('detection%s', labels{iDets});
    if isfield(REMORA.lt.lVis_det.(detId),'starts')
        labs = REMORA.lt.lVis_det.(detId).starts;
        next{iDets} = labs(find(labs>endWV,1));
        prev{iDets} = labs(find(labs<startWV,1,'last'));
    end
end

next = [next{:}];
prev = [prev{:}];

%truncate detections to this LTSA file- just keeps things from messing up 
next = next(next<=PARAMS.raw.dnumEnd(end));
prev = prev(prev>=PARAMS.raw.dnumStart(1));

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
