function Extracted = spExtractFromIndices(Indices, Signal, varargin)
% Extracted = spExtractFromIndices(Indices, Signal, varargin)
%
% Indices is a set of indices where each row indicates the starting
% and ending frame of some portion of the signal on which a property
% holds (i.e. the signal is speech between these points).  It is assumed
% that the indices are ordered.
%
% Given a Signal vector, and the indices, extract the portion of the signal
% specified by the indices.  
%
% Optional arguments:
%	'Framing', [SampleRate, FrameAdvanceMS, FrameLengthMS]
%		This argument is used to specify the framing 
%		parameters which correspond to the indices.  
%		When there are partial frames, they will be zero
%		padded.
%
%		If this argument is omitted, a one to one correspondence 
%		between the indices and the signal is assumed.
%
%	'Frame', N - If N non-zero, Extracted is a matrix where
%		each column is a frame as opposed to the signal.
%
%	'MinSeparation', N - If N non-zero, each extracted segment
%		must be at least N frames from the end of the previous
%		segment.  If not, segments are merged.  This value
%		can never be less than the number of frames which overlap
%		due to framing parameters (the default value).
%
%       'SampleRate', N - Sample rate of signal (needed to convert
%               framing parameters)


% defaults
Frame = 0;
MinSeparation = 0;

SampleRate = 1;		% default framing (1 to 1 signal/index alignment)
FrameAdvanceMS = 1000;
FrameLengthMS = 1000;
idx=1;
while idx < length(varargin)
  switch varargin{idx}
   case 'Frame'
    Frame = varargin{idx+1}; idx = idx + 2;

   case 'Framing'
    if length(varargin{idx+1}) ~= 3
      error('Bad Framing argument');
    end
    SampleRate = varargin{idx+1}(1);
    FrameAdvanceMS = varargin{idx+1}(2);
    FrameLengthMS = varargin{idx+1}(3);
    idx = idx+2;
    
   case 'MinSeparation'
    MinSeparation = varargin{idx+1}; idx = idx + 2;

   case 'SampleRate'
    SampleRate = varargin{idx+1}; idx = idx + 2;
    
   otherwise
    error(sprintf('Bad optional argument: "%s"', varargin{idx}));
  end
end

% Make sure Signal of the proper form
if ~ utIsVector(Signal)
  error('Signal must be a vector');
end

if ~ utIsVector(Signal, 'Type', 'column')
  Signal = Signal';
end

FrameAdvanceN = spMS2Sample(SampleRate, FrameAdvanceMS);
FrameLengthN = spMS2Sample(SampleRate, FrameLengthMS);

SampleCount = length(Signal);

if (max(Indices) - 1) * FrameAdvanceN + FrameLengthN > SampleCount
  error('Indices extend past size of signal');
end

OverlapSamples = FrameLengthN - FrameAdvanceN;
OverlapFrames = ceil((FrameLengthN - FrameAdvanceN) / FrameAdvanceN);
Overlap = max(OverlapFrames, MinSeparation);

% Locate overlapping indices and place them in reverse order so that
% we can merge overlapping segments and delete the second segment
% of the overlap without having to renumber the indices. 
OverlapIndicator = Indices(2:end, 1) - Indices(1:(end-1), 2) <= Overlap;
OverlapSegments = fliplr(find(OverlapIndicator == 1)');

% Merge all overlapping segments
for idx = OverlapSegments
  Indices(idx, 2) = Indices(idx+1, 2);
  Indices(idx+1, :) = [];
end

% Determine sample indices
SampleIndices = zeros(size(Indices));
SampleIndices(:, 1) = (Indices(:,1) - 1) * FrameAdvanceN + 1;
SampleIndices(:, 2) = (Indices(:,2) - 1) * FrameAdvanceN + FrameLengthN;

% Fix any SampleIndices that go past the end of signal due to
% partial framing.
SampleIndices(find(SampleIndices > SampleCount)) = SampleCount; 

if Frame
  % compute # frames from the segments
  SegmentCount = Indices(:,2) - Indices(:,1) + 1;
  FrameCount = sum(SegmentCount);
  
  Extracted = zeros(FrameLengthN, FrameCount);	% preallocate
  NewFrameIdx = 1;
  % Frame each segment
  for idx = 1:size(SampleIndices, 1)
    Extracted(:, NewFrameIdx:(NewFrameIdx + SegmentCount(idx) - 1)) = ...
	spFrame(Signal(SampleIndices(idx,1):SampleIndices(idx, 2)), ...
		FrameAdvanceN, FrameLengthN, 1);
    NewFrameIdx = NewFrameIdx + SegmentCount(idx);
  end
  
else
  % extract signal only
  SegmentCount = (SampleIndices(:,2) - SampleIndices(:,1) + 1)';
  SampleCount = sum(SegmentCount);

  Extracted = zeros(SampleCount, 1);	% preallocate
  
  NewSampleIdx = 1;
  for idx = 1:size(SampleIndices, 1)
    Extracted(NewSampleIdx:NewSampleIdx+SegmentCount(idx) - 1, :) = ...
	Signal(SampleIndices(idx,1):SampleIndices(idx, 2));
    NewSampleIdx = NewSampleIdx + SegmentCount(idx);
  end
end




