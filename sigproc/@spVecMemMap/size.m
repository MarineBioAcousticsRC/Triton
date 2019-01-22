function s = size(v, varargin)
% size - return size of vector

s = size(v.memmap.data, varargin{:});

