function Indices = spFrameIndices(SampleCount, Framing, varargin)
% Indices = spFrameIndices(SampleCount, Framing, OptArgs)
%   Determine indices for overlapping frames of data for a data set which
%   contains SampleCount samples.  Framing is a two element
%   vector containing the number of samples in each frame followed by the
%   number of samples to advance between the starts of consecutive (and
%   possibly overlapping) frames.
%
%   Optional arguments:
%   'Pad', N - stores a padding parameter that spFrameExtract
%       will use to zero pad frames to N samples (defaults
%       to frame size
%   'FrameRate', Fs - frames per unit, if supplied, time indices
%       will be computed for each frame in the specified time
%       unit (e.g. 'FrameRate', 100 would be used to specify the
%       frame rate in seconds for a 20 ms window  advanced 10 ms
%       as this results in 100 frames per s).
%   'Offset', N - Offset all frames by N samples
%   'Partial', true|false - By default, partial frames are
%       returned although the index of the last complete frame
%       is computed as well.  If false, only complete frames are 
%       returned as well.
%   'LastFrame', N - Ignore SampleCount and assume N complete frames
%
%	Any FrameLength < 0 indicates that all samples should
%	be used as a single frame.  This is useful for variable
%	length inputs.
%
%	Indices is a structure which contains the following fields:
%		.FrameShift - samples window shifted by
%		.FrameLength - length of window in samples
%		.FrameCount - Number of frames
%		.FrameLastComplete - Index of last complete frame.
%		.FrameExtractSize - When extracting frames from
%			data (spFrameExtract), pad frames to this
%			length.  A 0 indicates that .FrameLength will be used.
%       .PartialFrames - True if frame indices were computed
%           at the boundaries where there are not enough samples
%           to form complete frames.
%		.idx - A matrix whose rows represent frame indices.
%			Column 1 contains the starting sample
%			Column 2 contains the ending sample.
%		.timeidx - A column vector containing the starting
%			time in seconds for each frame.  This field
%			only exists if the optional SFrameRate argument
%			is present.
%
% This code is copyrighted 1997-2003 by Marie Roch.
% e-mail:  marie.roch@ieee.org
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 

error(nargchk(2, inf, nargin))

if numel(Framing) ~= 2
    error('Bad framing parameter');
else
    FrameLength = Framing(1);
    FrameShift = Framing(2);
end


% Set defaults
Partial = true;
Offset = 0;
PadTo = FrameLength;
frames_per_s = 0;  % unknown frame rate
SpecifyLastFrame = 0;

k=1;
while k <= length(varargin)
    switch varargin{k}
        case 'Pad'
            PadTo = varargin{k+1}; k=k+2;
        case 'FrameRate'
            frames_per_s = varargin{k+1}; k=k+2;
        case 'LastFrame'
            SpecifyLastFrame = varargin{k+1}; k=k+2;
        case 'Offset'
            Offset = varargin{k+1}; k=k+2;
        case 'Partial'
            Partial = varargin{k+1}; k=k+2;
        otherwise
            error('Bad optional argument');
    end
end
    
if FrameLength > 0
  FrameCount = floor((SampleCount - Offset) / FrameShift);
else
  % Use all samples to form a single frame
  FrameLength = SampleCount;
  FrameCount = 1;
  FrameShift = 1;	% FrameShift no longer relevant set to 1
end

Indices.FrameLength = FrameLength;
Indices.FrameShift = FrameShift;

if SpecifyLastFrame > 0
    FrameCount = SpecifyLastFrame;
    Indices.FrameLastComplete = SpecifyLastFrame;
else
    Indices.FrameLastComplete = ...
        floor((SampleCount - Offset - FrameLength + FrameShift) / FrameShift);
end
Indices.PartialFrames = Partial && ...
    ~(FrameCount == Indices.FrameLastComplete);
if Partial
    Indices.FrameCount = FrameCount;
else
    Indices.FrameCount = Indices.FrameLastComplete;
end

Indices.idx = zeros(Indices.FrameCount, 2);
for k =1:Indices.FrameCount
    Start = (k-1)*FrameShift + 1 + Offset;
    Stop = Start + FrameLength - 1;
    Indices.idx(k,:) = [Start, min(Stop, SampleCount)];
end  

if PadTo <= FrameLength
    % Don't allow truncation.
    % Don't set FrameExtractSize equal to frame length
    if PadTo ~= FrameLength
        error('Specified extracted frame length smaller than frame length\n');
    else
        Indices.FrameExtractSize = 0;
    end
else
    Indices.FrameExtractSize = PadTo;
end

if frames_per_s ~= 0
    Indices.timeidx = (0:Indices.FrameCount-1)' ./ frames_per_s;
end