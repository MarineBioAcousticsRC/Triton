function [snr_dB, Indices, dft, clickP] = ...
    dtSpecAnal(Signal, Fs, Length, Advance, Shift, Range, ...
        BroadbandThrN, ClickThr_dB, NoiseComp)
% [snr_dB, Indices, dft, clickP] = dtSpecAnal(
%       Signal, Fs, Length, Advance, Shift, Range, ...
%        BroadbandThrN, ClickThr_dB, NoiseComp)
% Perform spectral analysis
%
% Signal - 1D signal of interest
% Fs - signal sample rate
% Length - frame length in samples
% Advance - frame advance in samples
% Shift - Shift start of frame by N samples
% Range - Frequency bins to retain
% BroadbandThrN - N Frequency bins > ClickThr_dB --> broadband energy
% ClickThr_dB - bin N dB above bg noise might be part of a click
% NoiseComp - noise compensation method (see dtSpectrogramNoiseComp)

frames_per_s = Fs/Advance;
% Remove Shift samples from the length so that we have enough space to
% create a right shifted frame
Indices = spFrameIndices(length(Signal)-Shift, [Length, Advance], ...
        'FrameRate', frames_per_s, 'Offset', Shift, 'Partial', false);
last_frame = Indices.FrameLastComplete;
range_binsN = length(Range);

% click present predicate - Indicator fn for whether or not each
% frame contains a click
clickP = zeros(1, last_frame);  
if nargout > 2
    dft = zeros(range_binsN, last_frame);  % dft of frames
end
power_dB = zeros(range_binsN, last_frame); % power spectrum of frames

SpecAnalyMethod = 'dft';
switch SpecAnalyMethod
    case 'dft'
        specest = @(f) fft(f);
    case 'lpc'
        specest = @(f) pburg(f, 10, Length, 'twosided');
    otherwise
        error('bad method %s', SpecAnalyMethod);
end
window = blackmanharris(Length);
uNoise = zeros(length(Range), 1);  % mean noise statistic
for frameidx = 1:last_frame
    frame = spFrameExtract(Signal,Indices,frameidx);  % get samples
    frame = frame .* window;
    spec_frame = specest(frame);  % run spectral estimator
    dft(:,frameidx) = spec_frame(Range);
    magsq = dft(:,frameidx) .* conj(dft(:,frameidx));
    uNoise = uNoise + magsq;  % Keep track of frames
    power_dB(:,frameidx) = 10*log10(magsq);
end

if nargout > 3
    meanf_dB = 10*log10(uNoise / last_frame);
    for frameidx = 1:last_frame
      clickP(frameidx) = ...
          sum((power_dB(:,frameidx) - meanf_dB) > ClickThr_dB) ...
          > BroadbandThrN;
    end
    if sum(clickP) == last_frame
       % We suspect there are clicks in every frame
       % Don't exclude any frames when estimating noise.
       clickP = zeros(size(clickP));  
    end
end

% Estimate noise and remove via spectral means subtraction
% we may want to move to a better way of doing this
if ~ iscell(NoiseComp)
    NoiseComp = {NoiseComp};
end
snr_dB = dtSpectrogramNoiseComp(power_dB, Advance/Fs, ...
    ~clickP, NoiseComp{:});