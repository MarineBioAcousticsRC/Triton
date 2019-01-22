function w = spMemMappedWav(Filename)
% w = spMemMappedWav(Filename)
% Support for memory mapped Microsoft RIFF/wav files
% Does not support wave chunk lists (mulitple data chunks)
% Currently only supports 16 bit data, others reasonably easy to add.
%
% Usage:  w = spMemMappedWav(filename)
% w.memmap.data - contains wave data
% Other fields of w report number of samples, channels, etc.

[info, w.fs, w.bits, opts] = wavread(Filename, 'size');
w.Samples = info(1);
w.Channels = info(2);
w.HeaderBytes = 44;
w.Format = opts.fmt;

% Check for supported data types
if w.Format.nBlockAlign * 8 ~= w.Format.nBitsPerSample
  error('data requires padding for alignment, cannot handle')
end

if w.Channels > 1
  warning(['File contains more than 1 channel, treating like single ' ...
           'channel'])
end

switch w.Format.nBitsPerSample
 case 16
  precision = 'int16';
 case 8
  precision = 'int8';
 otherwise
  error('%d bits per sample not supported', w.Format.nBitsPerSample);
end

w.memmap = memmapfile(Filename, 'offset', w.HeaderBytes, ...
                      'format', precision);

