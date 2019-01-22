function Frames = dtExtractFrames(Range, Data, Window, FrameAdv, Direction)
% Frames = dtExtractFrames(Range, Data, Window, FrameAdv, Direction)
% 
% Given column vector Data, extract the data between Range(1) and Range(2).
%
% Partial frames will be contained past the boundaries and all
% frames are windowed with the specified Window (column vector, note
% that the FrameLen is derived from the length of Window).
%
% FrameAdv specifies the number of samples between consecutive frames.
%
% Direction N - indicates whether the frame is aligned at the starting
%       edge or the trailing edge of the signal.  (1 work forwards from
%       the start, -1 work backwards from the end)
%       Example:
%                                               --- signal
%                                               (   Range(1)
%                                               )   Range(2)
%                                               === portion of interest 
%
%                                              |-- frame N --|     
%                         |-- frame 1 --| ...
%    When N=1       |-- frame 0 --|
%               ----(====================================)----
%    When N=-1                             |-- frame N --|                   
%                             ...  |-- frame N-1  --| 
%               |--- frame 0 --|
%
% Frames is a matrix of column oriented data.
%
% Examples:
%
% Extract frames of length 4 between the 3rd and 15th element
% of the signal, starting at 3.
% dtExtractFrames([3,15],1:20, rectwin(4)', 2, 1)
% 
% ans =
% 
%      3     5     7     9    11    13
%      4     6     8    10    12    14
%      5     7     9    11    13    15
%      6     8    10    12    14    16
% 
% Extract frames of length 4 between the 3rd and 15th element
% of the signal, ending at 15.
% >> dtExtractFrames([3,15],1:20, rectwin(4)', 2, -1)
% 
% ans =
% 
%      2     4     6     8    10    12
%      3     5     7     9    11    13
%      4     6     8    10    12    14
%      5     7     9    11    13    15
     

RangeN = diff(Range) + 1;
DataN = length(Data);

if RangeN <= 0
  error('invalid Range')
end

FrameLen = length(Window);        % frame length
FramesN = ceil(max((RangeN - FrameLen), 0)/ FrameAdv + 1);
Frames = zeros(FrameLen, FramesN);

switch Direction
 case 1
  Start = Range(1);  % extend towards end of signal
  FrameIndices = 1:FramesN;
 case -1
  Start = Range(2) - FrameLen + 1;
  FrameIndices = FramesN:-1:1;
 otherwise
  error('invalid Direction')
end

NextFrame = Direction * FrameAdv;
for idx=FrameIndices
  Stop = Start+FrameLen-1;
  if Start < 1 || Stop > DataN
    Frames = [];      % out of bounds, discard click
    return
  end
    
  % fprintf('frame %d: [%d, %d]\n', idx, Start, Start+FrameLen-1);
  Frames(:,idx) = (Data(Start:Start+FrameLen-1) .* Window)';
  Start = Start + NextFrame;
end



