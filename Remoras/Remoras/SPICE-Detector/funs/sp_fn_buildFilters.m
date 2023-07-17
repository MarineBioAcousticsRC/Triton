function [previousFs,p] = sp_fn_buildFilters(p,fs)

% On first pass, or if a file has a different sampling rate than the
% previous, rebuild the  filter
% Start by assuming it's a bandpass filter
bandPassRange = p.bpRanges;
p.filtType = 'bandpass';
p.filterSignal = true;
p.fB = [];
p.fA = [];

% Handle different filter cases:
% 1) low pass
if p.bpRanges(1)== 0
    % they only specified a top freqency cutoff, so we need a low pass
    % filter
    bandPassRange = p.bpRanges(2);
    p.filtType = 'low';
    if bandpassRange == fs/2
        % they didn't specify any cutoffs, so we need no filter
        p.filterSignal = false;
    end
end
% 2) High passs
if p.bpRanges(2)>= fs/2 && p.filterSignal
    % they only specified a lower freqency cutoff, so we need a high pass
    % filter
    bandPassRange = p.bpRanges(1);
    p.filtType = 'high';
end

if p.filterSignal
    [p.fB,p.fA] = butter(p.filterOrder, bandPassRange./(fs/2),p.filtType);
    %[p.fB,p.fA] = ellip(4,0.1,40,bandPassRange.*2/fs,filtType);
    % filtTaps = length(p.fB);
end
% filtTaps = length(fB);
previousFs = fs;

p.fftSize = ceil(fs * p.frameLengthUs / 1E6);
if rem(p.fftSize, 2) == 1
    p.fftSize = p.fftSize - 1;  % Avoid odd length of fft
end

p.fftWindow = hann(p.fftSize)';

lowSpecIdx = round(p.bpRanges(1)/fs*p.fftSize);
highSpecIdx = round(min(p.bpRanges(2),fs/2)/fs*p.fftSize);

p.specRange = lowSpecIdx:highSpecIdx;
p.binWidth_Hz = fs / p.fftSize;
p.binWidth_kHz = p.binWidth_Hz / 1000;
p.freq_kHz = p.specRange*p.binWidth_kHz;  % calculate frequency axis
