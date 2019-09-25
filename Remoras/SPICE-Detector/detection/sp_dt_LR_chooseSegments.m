function [startsSec,stopsSec,p] = sp_dt_LR_chooseSegments(p,hdr)
% Divide acoustic data into smaller chunks to prevent over-committing memory
% Find a reasonable length of data to handle taking into account that the
% interleaved channels will also be read. To ensure that analysis
% is continuous across a segment, we make sure that the time split
% time is some multiple of the frame rate.

% Figure out how long the file is by summing up all the bytes
starts = 0;
stops = sum(hdr.xhd.byte_length)/hdr.xhd.ByteRate;
p.fftSize = 2^ceil(log2(hdr.fs * p.frameLengthUs/1000));

p.frameAdvanceSec = p.fftSize / hdr.fs; % this should now be used instead of 
% p.frameLengthSec because it has more precision

chooseMB  = 45; % Based upon empirical performance on a 1 GB machine.
chooseSamples = chooseMB * 1024 * 1024 / 8;  % change into samples
chooseSec = chooseSamples / hdr.fs;  % translate into time
maxTimeSec = p.frameAdvanceSec * round(chooseSec/hdr.nch/p.frameAdvanceSec);

labLength = stops-starts; 
segmentsRequired = ceil(labLength/maxTimeSec);  % # segments per interval

startsSec = zeros(sum(segmentsRequired), 1);
stopsSec = zeros(sum(segmentsRequired), 1);
newIdx = 1;

% Step through starts, and if multiple segments are required to handle an
% interval, add intermediate starts/stops, so you end up with smaller
% chunks.
for oldIdx = 1:length(starts)
    for k=1:segmentsRequired(oldIdx)
        startsSec(newIdx) = starts(oldIdx) + ((k-1)*maxTimeSec);
        stopsSec(newIdx) = min(startsSec(newIdx)+ maxTimeSec-1/hdr.fs, stops(oldIdx));
        newIdx = newIdx+1;
    end
end