function display(w)
% display an spWavMemMap object

disp(sprintf(...
    '\n%s =\nspWav object Fs=%d, samples=%d, channels=%d, bits=%d', ...
    inputname(1), w.fs, w.Samples, w.Channels, w.bits))

