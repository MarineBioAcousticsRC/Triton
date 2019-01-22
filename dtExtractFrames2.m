function [Frames, WindowCorrection] = dtExtractFrames2(Range, Data, WindowFn, Size, FrameAdv, MaxFramesPerClick)
% Frames = dtExtractFrames(Range, Data, Window, FrameAdv, MaxFramesPerClick)
% 
% Given row vector Data, extract the data between Range(1) and Range(2).
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
elseif RangeN < Size
    % only one frame
    Frames = zeros(Size, 1);
    window = WindowFn(RangeN)';
    WindowCorrection = 10*log10(sum(window)^2);
    Frames(1:RangeN) = window .* Data(Range(1):Range(2));
else
    % multiple frames, but we will just do the first one for now
    % until we decide that this is a good technique
    % we also always start from the front of the click...
    window = WindowFn(Size)';
    WindowCorrection = 10*log10(sum(window)^2);
    Frames = (window .* Data(Range(1):Range(1)+Size-1))';
end


