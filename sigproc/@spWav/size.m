function s = size(w, varargin)
% size - return size of waveform in samples

s = [w.Samples, w.Channels];
