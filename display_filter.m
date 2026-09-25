function x = display_filter(x, fs, f1, f2)
% x = display_filter(x, fs, f1, f2)
% Bandpass a segment for display between f1 and f2 Hz.
%
% Zero-phase FIR bandpass: unlike a one-pass IIR filter it introduces no
% phase distortion, so waveform shape and arrival times survive filtering.
% The DC offset is removed first, otherwise the step at the start of the
% segment rings through the filter.
%
% Shared by plot_timeseries, plot_specgram and plot_spectra so the three
% display panels cannot drift apart. Requires the Signal Processing
% Toolbox, as the elliptic filter it replaced also did.

x = double(x);
x = x - mean(x);                        % remove DC before filtering

% Normalised cutoffs must lie strictly inside (0,1). Clamp rather than
% error, so a band requested up to or beyond Nyquist still draws.
Wn = [f1 f2] / (fs/2);
Wn = min(max(Wn, 1e-6), 1 - 1e-6);
if Wn(2) <= Wn(1)
    return                              % degenerate band; leave as-is
end

% filtfilt requires numel(x) > 3*order, so scale the order to the segment
% rather than fixing it. 200 taps is the design target; short segments get
% the largest even order that still fits.
nOrder = min(200, 2 * floor((numel(x) - 1) / 6));
if nOrder < 4
    return                              % too short to filter meaningfully
end

b = fir1(nOrder, Wn, 'bandpass');
x = filtfilt(b, 1, x);
