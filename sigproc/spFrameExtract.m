function Frame = spFrameExtract(Data, Indices, Index)
% spFrameExtract - Given data in a column vector format, and an index
% structure produced by SPframeIndices, extract the data associated 
% with frame Index.
%
% This code is copyrighted 1997, 1998 by Marie Roch.
% e-mail:  marie-roch@uiowa.edu
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 


Start = Indices.idx(Index,1);
Stop = Indices.idx(Index,2);
if Indices.FrameExtractSize | Index > Indices.FrameLastComplete
  % zero padding necessary
  if Indices.FrameExtractSize
    PadLength = Indices.FrameExtractSize;
  else
    PadLength = Indices.FrameLength;  
  end
  Frame = zeros(PadLength, 1);
  Frame(1:Stop-Start+1) = Data(Start:Stop);
else
  Frame = Data(Start:Stop);
end
