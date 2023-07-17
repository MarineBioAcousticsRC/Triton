function validClicks = sp_dt_pruneClipping(clicks,p,hdr,filteredData)
% Prune out detections that are too high amplitude, and therefore likely
% clipped.

validClicks = ones(1, size(clicks,1));  % assume all are good to begin

for c = 1:size(clicks, 1)
    % Go through the segments of interest one by one, and make sure they
    % don't exceed clip threshold.
    if any(abs(filteredData(clicks(c,1):clicks(c,2))) > ...
            p.clipThreshold *(2^hdr.nBits)/2)
        validClicks(c) = 0;
    end
end