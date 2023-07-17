function w = spWav(Filename)
% w = spWavMemMap(File)
% Support for large Microsoft RIFF/wav files.  Data remains
% on disk except for what is accessed at any given time.
% Multiples accesses to the same indices result in the file
% being read multiple times.
%
% Supports any file readable by wavread.
%
% Usage:  w = spWav(filename)
%         length(w) - returns number of samples in any one of the
%               channels
%         size(w) - returns [samples, channel count]
%         w(3:15, 1) - returns samples 3 through 15 in channel 1
%         w(3:15) - returns samples 3 through 15 in the "current channel"
%              By default, w.CurrentChannel is 1, but it can be assigned
%              to another channel.  e.g. w.CurrentChannel = 2;  
%              Note that this behavior is different from typical
%              Matlab behavior which would treat the matrix of samples
%              & channels as a vector indexed one by one.
%
% Other fields of w report number of samples, channels, etc.
%



[info, w.fs, w.bits, opts] = wavread(Filename, 'size');

w.Filename = Filename;
w.Samples = info(1);
w.Channels = info(2);
w.Format = opts.fmt;
w.CurrentChannel = 1;

w.Normalize = 2^(w.Format.nBitsPerSample - 1);

% Create class
w = class(w, 'spWav');



