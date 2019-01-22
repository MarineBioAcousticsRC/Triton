function s = size(w, varargin)
% size - return size of waveform in samples

s = size(w.memmap.data, varargin{:});
