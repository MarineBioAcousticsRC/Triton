function [bw, low, high] = spNdB_Bandwidth(spectra, NdB, bin_width)
% [bw, low, high] = spNdB_Bandwidth(spectra, NdB, bin_width)
% Return bandwidth based on peak frequency of spectra which are assumed
% to be a column oriented matrix of energies in dB.
% Results are returned in bins unless the optional argument bin_width
% is specified in which case the bins are scaled by the bin width.

error(nargchk(1,3,nargin));
if nargin < 3
    bin_width = 1;
end

[peak, peakI] = max(spectra);  % get peak bins
% initialize search
low = peakI;
high = peakI;
target_dB = peak - NdB;
[BinsN, SpectraN] = size(spectra);

for idx=1:SpectraN
    % search until target dB achieved or we hit the end
    while low(idx) > 1 && spectra(low(idx),idx) > target_dB(idx)
        low(idx) = low(idx) - 1;
    end
    dB = spectra(low(idx), idx);
    % interpolate if we are below target_dB
    if low(idx) < peakI(idx) && dB < target_dB(idx)
        % compute power change between this bin and the previous one
        % then interpolate
        delta_pow = spectra(low(idx)+1, idx) - dB;  
        over_dB = target_dB(idx) - dB;   % overshot target by N dB
        low(idx) = low(idx) + over_dB / delta_pow;
    end
    
    % similar for upper target
    while high(idx) < BinsN && spectra(high(idx), idx) > target_dB(idx)
        high(idx) = high(idx) + 1;
    end
    dB = spectra(high(idx), idx);
    if high(idx) > peakI(idx) && dB < target_dB(idx)
        delta_pow = spectra(high(idx)-1, idx) - dB;  
        over_dB = dB - target_dB(idx);   % overshot target by N dB
        high(idx) = high(idx) + over_dB / delta_pow;
    end
end

% interpolate for fractional bins that are not on the edges
bw = high - low;
if bin_width ~= 1
    bw = bw * bin_width;
    low = (low-1) * bin_width;
    high = (high-1) * bin_width;
end
