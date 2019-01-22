function data = wav(w, range)

data = double(w.memmap.Data(range)) / w.Normalize;
