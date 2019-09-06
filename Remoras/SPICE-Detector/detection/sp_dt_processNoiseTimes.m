function [noiseStarts,noiseEnds]= sp_dt_processNoiseTimes(noiseIndices,startsK,hdr)
% Write click times to .ctg label file

noiseStarts = nan(size(noiseIndices,1));
noiseEnds = nan(size(noiseIndices,1));

for cI = 1:size(noiseIndices,1)
    % Compute noise start time as sec from file start using raw file start
    % time.
    currentNoiseStart = startsK + noiseIndices(cI,1)/hdr.fs; % start time
    currentNoiseEnd = startsK + noiseIndices(cI,2)/hdr.fs;
    
    noiseStarts(cI,1) = currentNoiseStart;
    noiseEnds(cI,1) = currentNoiseEnd;
end
