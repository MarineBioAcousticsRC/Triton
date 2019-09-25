function [detectionsSample,detectionsSec] = sp_dt_LR(energy,hdr,buffSamples,startK,stopK,p)
% Find all events exceeding threshold.
% Return times of those events
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Flag times when the amplitude rises above a threshold

if ~p.snrDet
    aboveThreshold = find(energy>((p.countThresh^2)));
else
    medianNoise = sqrt(median(energy));
    smoothEnergy = sqrt(sp_fn_fastSmooth(energy,p.delphClickDurLims(1),1,1));
    aboveThreshold = find(smoothEnergy>(medianNoise+10^(p.snrThresh/10)));
end

if isempty(aboveThreshold)
    detectionsSec = [];
    detectionsSample = [];
else
    % sampleStart = floor(startK * hdr.fs)+1;
    % sampleStop = floor(stopK * hdr.fs)+1;
    
    % add a buffer on either side of detections.
    detStartSample = max(((aboveThreshold - buffSamples)), 1);
    detStopSample = min(((aboveThreshold + buffSamples)), length(energy));
    
    detStart = max((((aboveThreshold - buffSamples)/hdr.fs) + startK), startK);
    detStop = min((((aboveThreshold + buffSamples)/hdr.fs) + startK), stopK);
    
    % Merge flags that are close together.
    if length(detStart)>1
        [stopsM,startsM] = sp_dt_mergeCandidates(buffSamples/hdr.fs,...
            detStop', detStart');
        [stopsSampleM,startsSampleM] = sp_dt_mergeCandidates(buffSamples,...
            detStopSample', detStartSample');
    else
        startsM = detStart;
        stopsM = detStop;
        startsSampleM = detStartSample;
        stopsSampleM = detStopSample;
    end
    
    
    detectionsSec = [startsM,stopsM];
    detectionsSample = [startsSampleM,stopsSampleM];
end