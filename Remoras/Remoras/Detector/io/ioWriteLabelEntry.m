function ioWriteLabelEntry(handle, times, label, binary)
% ioWriteLabelEntry(handle, times, label, binary)
% Used by ioWriteLabel or callable directly, this writes one
% label entry to a Wavesurfer label file.
%
%
% Arguments:
% handle - an open file handle
% times and label - have the same semantics as in ioWriteLabel
% binary - write start/stop times in: true->binary format, false->text
%       format

Fields = length(times);

% Write start and stop time.
if binary
  fwrite(handle, times(1:2), 'double');
else
  fprintf(handle, '%f %f ', times(1), times(2));
end

% Write label
if Fields > 2
  % Format SNR as part of label name
  fprintf(handle, '%s-%.0f\n', label, times(3));
else
  fprintf(handle, '%s\n', label);
end
