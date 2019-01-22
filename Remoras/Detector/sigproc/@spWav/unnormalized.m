function data = unnormalized(w, varargin)

data = double(w(varargin{:})) * w.Normalize;
