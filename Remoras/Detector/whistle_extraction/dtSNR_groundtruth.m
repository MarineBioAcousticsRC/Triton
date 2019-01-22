function [tonals discarded_tonals] =  dtSNR_groundtruth(Filename, ...
    ground_truth, Start_s, Stop_s, Snr_dB)
% dtSNR_groundtruth(Filename, ground_truth, Start_s, Stop_s)
% Discard the ground truth tonals if certain part of it is below specified
% signal to noise ratio. Returns the updated ground truth tonal list and
% the list of discarded ground truth tonals.
% NOTE: This works specifially for moving average implementation. Different
% way must be adopted for fixed block implementation.
%
% Filename - Name of the audio file
%            Example - 'palmyra092007FS192-071011-230000.wav'
% ground_truth - ground truth tonals
% Start_s - start time in s relative to the start of the first recording
% Stop_s - stop time in s relative to the start of the first recording
% Snr_dB - Desired threshold for signal to noise ratio.

% defaults
Advance_ms = 2;
Length_ms = 8;
NoiseSub = 'median';          % what type of noise compensation

header = ioReadWavHeader(Filename);
handle = fopen(Filename, 'rb', 'l');
Stop_s = min(Stop_s, header.Chunks{header.dataChunk}.nSamples/header.fs);

% Select channel as Triton would
channel = channelmap(header, Filename);

% Borrowed these thresholds from dtTonalsTracking ------------------------
% define frequency range over which we search for tonals
thr.high_cutoff_Hz = 50000;
thr.low_cutoff_Hz = 5000;
thr.click_dB = 8;   % SNR criterion for clicks (part of click skipping decision)

% Frames containing broadband signals will be ignored.
% If more than broadand% of the bins exceed the threshold,
% we consider the frame a click.
thr.broadband = .01;

% Frame length and advance in samples
Length_s = Length_ms / 1000;
Length_samples = round(header.fs * Length_s);
Advance_s = Advance_ms / 1000;
Advance_samples = round(header.fs * Advance_s);
Nyquist_bin = floor(Length_samples/2);

bin_Hz = header.fs / Length_samples;    % Hz covered by each freq bin

thr.high_cutoff_bins = min(ceil(thr.high_cutoff_Hz/bin_Hz)+1, Nyquist_bin);
thr.low_cutoff_bins = ceil(thr.low_cutoff_Hz / bin_Hz)+1;

% save indices of freq bins that will be processed
range_bins = thr.low_cutoff_bins:thr.high_cutoff_bins;
range_binsN = length(range_bins);  % # freq bin count

% To compute the phase derivative, we should shift by a small
% number of samples and take the first difference
% We want the time difference to be small enough that at the highest
% frequency of interest, we will not move an entire cycle.
% Oversampling should help us here.
shift_samples = floor(header.fs / thr.high_cutoff_Hz);
% -----------------------------------------------------------------------

import java.util.*;
tonals = java.util.LinkedList();
discarded_tonals = java.util.LinkedList();
movAvg_s = 1.5; % Consider movAvg_s on either side of the processing frame.
snr_threshold_dB = Snr_dB;  % SNR threshold
SNR_percent = 0.7;  % Atleast 30% of tonal is SNR_dB

groundIt = ground_truth.iterator();
while groundIt.hasNext()
    tonal = groundIt.next();
    
    g_time = tonal.get_time();
    g_freq = tonal.get_freq();
    
    % Get start and end time of the ground truth tonal
    g_startTime = g_time(1);
    g_endTime = g_time(end);
    
    if (g_startTime - movAvg_s) >= Start_s
        startBlock_s = g_startTime - movAvg_s;
    else
        startBlock_s = Start_s;
    end
    
    if (g_endTime + movAvg_s) <= Stop_s
        stopBlock_s = g_endTime + movAvg_s;
    else
        stopBlock_s = Stop_s;
    end
    
    Signal_mavg = ioReadWav(handle, header, startBlock_s, stopBlock_s, ...
        'Units', 's', 'Channels', channel);
    
    % Perform spectral analysis on block for moving average
    [snr_dB, Indices_mavg, dft_mavg, clickP_mavg] = ...
        dtSpecAnal(Signal_mavg, header.fs, Length_samples, Advance_samples, ...
        shift_samples, range_bins, thr.broadband * range_binsN, ...
        thr.click_dB, NoiseSub);
    
    % Get the value of power_dB for a pixel using time and frequency
    % information from the ground truth tonal and spectrogram of the
    % recording. This works specific for moving average implementation.
    % Different way must be adopted for fixed block implementation.
    % -------------------------------------------------
    idx_from = round((header.fs / Advance_samples)...
        * (g_startTime - startBlock_s));
    idx_to = idx_from + floor((header.fs / Advance_samples)...
        * (g_endTime - g_startTime));
    if (idx_from - idx_to) == 0
        continue;
    end
    snr_power_dB = snr_dB(:, idx_from+1:idx_to);
    SNR_dB = zeros(1, length(g_time));
    for idx = 1 : length(g_time)
        t = g_time(idx);
        taux = t - g_startTime;
        if taux < Advance_s
            tidx = 1;
        else
            tidx = floor(taux / Advance_s);
        end
        f = g_freq(idx);
        bins = round(f / bin_Hz) + 1;
        if bins > thr.high_cutoff_bins
            bins = thr.high_cutoff_bins;
        end
        if bins < thr.low_cutoff_bins
            bins = thr.low_cutoff_bins;
        end
        bins = bins - (thr.low_cutoff_bins - 1);
        SNR_dB(idx) = snr_power_dB(bins, tidx);
    end    
    % ---------------------------------------------------------------------
    
    % Ground truth tonal should be discarded or not.
    % Sort the SNR_dB vector and get the value at idx_percent.
    %
    %                     |- idx_percent
    %                     v
    %	 [p1 p2 p3 p4 p5 p6 p7 p8 p9 p10]
    SNR_dB = sort(SNR_dB);
    idx_percent = round(SNR_percent * length(SNR_dB));
    value = SNR_dB(idx_percent);
    if value < snr_threshold_dB
        discarded_tonals.addLast(tonal);
    else
        tonals.addLast(tonal);
    end
    
end
