function [Signal, snr_power_dB, Indices, dft, clickP] = ...
    dtProcessBlock(handle, header, channel, ...
    StartBlock_s, block_len_s, Framing, varargin)
%    noisy_bins_N, noisy_intensity_dB, NoiseSub)
% [Signal, SNRPower_dB, Indices, Dft, clickP] = ...
% dtProcessBlock(AudioFileHandle, AudioFileHeader, channel, ....
%     StartBlock_s, BlockLen_s, Framing, OptArgs)
% Given a start time and length in seconds, framing
% information in samples ([Length, Advance]), and any optional
% arguments, read in a data block and perform spectral processing.
%
% Returns information about the block including the raw signal,
% spectrogram, timing information, the raw dft, and an indicator as to
% whether or not a click occurred at each block.
%
% Optional arguments:
%   'Pad_s', s - Pad block on each side (if possible) by specified 
%       value in s.
%   'Shift', n - Shift analysis by n samples.
%   'Range', [bins] - Only retain the spectral bins in the specified
%                     range.
%   'ClickP' [Bins, dB] - Parameters for the click detection heuristic
%                      # of bins that must exceed threshold dB
%   'Noise', NoiseArgs - Noise compensation arguments (cell array to
%                      pass multiple arguments)
%   'RemoveTransients', true|false - Reduce the effects of high frequency
%                      transient calls such as clicks (default true)

error(nargchk(6, inf, nargin));

if numel(Framing) ~= 2
    error('Framing argument must have [length_samples, advance_samples]');
else
    Length_samples = Framing(1);
    Advance_samples = Framing(2);
end

% defaults
block_pad_s = 0;
shift_samples = 0;
NoiseSub = {};
noise_bins_N = 0;
noise_intensity_dB = 0;
range_bins = [1:floor(Length_samples/2)];
RemoveTransients = false;

% We cannot use the serial dates as they may contain duty cycling.
% The alternatives are to find the duty cycles and subtract the missing
% time or to compute the last possible end time from the number of 
% samples in the file.  We choose the latter.
file_end_s = sum(header.xhd.byte_length / ...
    (header.nch * header.samp.byte))/header.fs;

vidx = 1;
while vidx < length(varargin)
    switch varargin{vidx}
        case 'ClickP'
            clickargs = varargin{vidx+1}; vidx=vidx+2;
            if numel(clickargs) ~= 2
                error('Bad ClickP arguments');
            end
            noise_bins_N = clickargs(1);
            noise_intensity_dB = clickargs(2);
        case 'Pad'
            block_pad_s = varargin{vidx+1}; vidx=vidx+2;
        case 'Range'
            range_bins = varargin{vidx+1}; vidx=vidx+2;
        case 'RemoveTransients'
            RemoveTransients = varargin{vidx+1}; vidx=vidx+2;
        case 'Shift'
            shift_samples = varargin{vidx+1}; vidx=vidx+2;
        case 'Noise'
            NoiseSub = varargin{vidx+1}; vidx=vidx+2;
        otherwise
            error('Bad optional argument');
    end
end
% Compute start and stop times taking into account padding needs
start = max(0, StartBlock_s - block_pad_s);
stop = min([StartBlock_s+block_len_s+block_pad_s, file_end_s]);
% How much padding were we able to actually provide
start_pad = StartBlock_s - start;
stop_pad = stop - (StartBlock_s+block_len_s);
if stop_pad < 0
    stop_pad = 0;  % unable to provide any padding
end

% Retrieve the data for this block
Signal = ioReadWav(handle, header, start, stop, ...
    'Units', 's', 'Channels', channel);

% Build filter to detect transients such as echolocation clicks
% Todo:  Have filter passed in as a parameter and only construct once.
if RemoveTransients
    % design filter:  lowtrans, hightrans, attenlow_dB, ripplehigh_dB, fs
    d = fdesign.highpass(5000, 10000, 60, 3, header.fs);  % filter specification
    hd = design(d, 'cheby1');  % design to specification
    
end

% Remove transients such as echolocation clicks
if RemoveTransients
    SignalHP = filter(hd, Signal); % high pass filter the signal
    Teager = abs(spTeagerEnergy(SignalHP));  % half-wave rectifiied Teager Energy
    % estimate noise floor - Our click detector uses the 40th percentile,
    % but it is biased towards minimizing false alarm
    NoiseFloor = prctile(Teager, 40);  
    Thresh = 50*NoiseFloor;
    smooth_us = 50;
    smooth_N = round(header.fs * smooth_us * 1e-6);
    minlen_us = 100;
    minlen_N = round(header.fs * minlen_us * 1e-6);
    if rem(smooth_N, 2) == 0
        smooth_N = smooth_N + 1;  % make odd
    end
    shift_N = round(smooth_N/2);
    TeagerMA = stMA(Teager, smooth_N, shift_N);  % centered moving average
        
    Exceeds = TeagerMA > Thresh;
    % Find short groups of over threshold sections
    [begin, label, leng]= spRunLengthAnalysis(Exceeds');  % group
    MaxClickLen_s = .002;
    selected = label == 1 & leng < MaxClickLen_s/(1/header.fs) & leng > smooth_N;
    
    RemovalMethod = 'poly';
    Rm = find(selected);
    debug = false;
    if debug
        PreSignal = Signal;
        t = 0:1/header.fs:(length(Signal)-1)/header.fs;
        clickFigH= figure('Name', 'Click mitigation');
        subplot(3,1,1);
        plot(t, Signal);
        hold on;
        clickAxH = gca;
        teagAxH = subplot(3,1,2);
        plot(t, TeagerMA, 'r', t, Teager, 'b', [t(1), t(end)], Thresh([1, 1]), 'c-');
        YLim = get(clickAxH, 'Ylim');
        linkaxes([clickAxH, teagAxH], 'x');
    end
    prevE = 1;
    for s = 1:length(Rm)
        if s < length(Rm)
            nextB = begin(Rm(s+1));
        else
            nextB = length(Signal)+1;
        end
        b = max(2, begin(Rm(s)));
        e = min(length(Signal)-1, begin(Rm(s))+leng(Rm(s))-1);
        if debug
            plot(clickAxH, t([b b e e]), [YLim YLim], 'g:');
        end
        switch RemovalMethod
            case 'linear'
                Signal(b:e) = ...
                    interp1q([b-1; e+1], [Signal(b-1); Signal(e+1)], [b:e]');
            case 'poly'
                WindowFreq = 5000;  % Window on either size based on this freq
                points = max(50, round(header.fs / WindowFreq));
                
                % skip over multiple sections that are too close
%                 while s < length(Rm) && e+points >= begin(Rm(s+1))
%                     s = s+1;
%                     e = min(length(Signal)-1, begin(Rm(s))+leng(Rm(s))-1);
%                 end
                if debug
                    plot(clickAxH, t([b b e e]), .4*[YLim YLim], 'r:');
                end
%                 FitIndices = [max(1, b-2-points):b-1, ...
%                     e+1:min(length(Signal),e+points)]';
                FitIndices = [max(prevE, b-2-points):b-1, ...
                    e+1:min(nextB-1, e+points)]';
                order = 4; % polynomial order
                %coeffs = polyfit(FitIndices, Signal(FitIndices), order);
                coeffs = dtPolyFitNoCondCheck(FitIndices, Signal(FitIndices), order);
                tmp = polyval(coeffs, b:e);
                if max(abs(tmp)) < max(abs(Signal(b:e)))
                    Signal(b:e) = tmp;
                end
                prevE = e;

            otherwise
                error('Bad removal method');
        end
                
    end
    if debug
        plot(clickAxH, t, Signal, 'm:');  % new signal
        set(clickAxH, 'YLim', [-1.2, 1.2]);
        resAxH = subplot(3,1,3); 
        plot(t, PreSignal - Signal); % residual
        linkaxes([clickAxH, teagAxH, resAxH], 'x');
    end
        
end

% Perform spectral analysis on block
[snr_power_dB, Indices, dft, clickP] = dtSpecAnal(Signal, header.fs, ...
    Length_samples, Advance_samples, shift_samples, ...
    range_bins, noise_bins_N, ...
    noise_intensity_dB, NoiseSub);

% Convert the padding to frames and remove the frames that should
% not be processed.
Advance_s = Advance_samples / header.fs;
if start_pad > 0
    startRange = [1:round(start_pad / Advance_s)];
else
    startRange = [];
end

framesN = size(snr_power_dB, 2);  % total # of frames
if stop_pad >= 0
    start_of_end_idx = round(max(0, stop - stop_pad - start)/Advance_s);
    stopRange = [start_of_end_idx:Indices.FrameCount];
else
    stopRange = [];
end
deleteRange = [startRange, stopRange];
if ~ isempty(deleteRange)
    snr_power_dB(:, deleteRange) = [];
    dft(:, deleteRange) = [];
    clickP(deleteRange) = [];
    % # of samples we lost to padding on either side
    pad_samples = round((start_pad + stop_pad) * header.fs);
    % Recompute indices
    Indices = spFrameIndices(length(Signal)-pad_samples, ...
        [Length_samples, Advance_samples], ...
        'LastFrame', size(snr_power_dB, 2), ...
        'FrameRate', 1/Advance_s);
    
    % It looks like we lost frames based on the new interval,
    % but we know better because we computed the padded interval
    % first and now we are just recomputing the labels w/o padding
    if ~isempty(deleteRange) 
        Indices.FrameLastComplete = Indices.FrameCount;
    end
    % Remove padding from signal
    Signal = Signal(round(start_pad*header.fs+1) : ...
        length(Signal)-round(stop_pad*header.fs));
end

% relative to file rather than block
Indices.timeidx = Indices.timeidx + StartBlock_s;