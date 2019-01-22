function power_dB = dtSNR_meanssub(power_dB, useP) 
% snr_power = dtSNR_meanssub(power_dB, useP) 
% Estimate SNR via means subtraction.  The argument useP
% is a logical index variable that indicates which time slices
% of the spectrogram power_dB should be used in the mean estimation

if nargin < 2
    useP = ones(size(power_dB, 2));
end
% Compute mean of each frequency
meanf_dB = mean(power_dB(:, useP), 2);
% typically faster to subtract on a frame by frame basis than to
% build an entire matrix and subtract without a loop.
last_frame = size(power_dB, 2);
for frame_idx = 1:last_frame
    power_dB(:,frame_idx) = power_dB(:,frame_idx) - meanf_dB;
end
