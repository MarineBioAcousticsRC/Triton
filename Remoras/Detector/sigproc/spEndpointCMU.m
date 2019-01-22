function [Samples, Segments] = spEndpointCMU(Signal, SampleRate)
% [Samples, Segments] = spEndpointCMU(Signal, SampleRate)
% Endpoint the given signal using the CMU endpointer.
% The indices of the segments containing speech are returned in
% Samples and the 10 ms frame indices are returned in Segments.
%
% A temporary file containing the raw signal is created and an external
% endpointer is invoked on the temporary file.  After processing, the
% file is removed. 

if ~ isa(Signal, 'int16')
  error('Signal to endpoint must be consist of 16 bit integers');
end

RawFile = ['/tmp/', getenv('USER'), '.raw'];
spWritePcm16(RawFile, Signal);

% Utility to extract feature information and run segmenter
EPUTIL='/zal/mroch/speech/cmu/segmenter/endpoint';

% do it!
[ResultCode, Results] = system(sprintf('%s %s', EPUTIL, RawFile));

if ResultCode ~= 0
  error(sprintf('endpointer failure, return code =%d\nOutput = %s', ...
		 ResultCode, Results));
end

% Process results
Segments = sscanf(Results, '%d');
SegmentCount = length(Segments)/2;

if (SegmentCount ~= floor(SegmentCount))
  error('endpointer failed to return appropriate frames');
end

Segments = reshape(Segments, 2, SegmentCount)';

% Convert segments to samples:
% Segments are currently in 10 ms frames.  
% Normalize to % of a second (N/100), multiply by samples per second, &
% add one for Matlab indexing.
SampleLabels = Segments * (SampleRate / 100) + 1;

% Determine how many samples we have & preallocate
SampleCounts = SampleLabels(:,2) - SampleLabels(:,1) + 1;	% per segment
SampleCountTotal = sum(SampleCounts);
Samples = zeros(SampleCountTotal, 1);

N = 0;
for k=1:length(SampleCounts)
  Samples(N + 1:N + SampleCounts(k)) = ...
      Signal(SampleLabels(k,1):SampleLabels(k,2));
  N = N + SampleCounts(k);
end

x = 1;	% breakable line
