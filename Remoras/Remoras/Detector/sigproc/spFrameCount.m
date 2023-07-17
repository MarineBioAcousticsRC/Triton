function [Whole, Partial] = spFrameCount(SignalN, ...
					 FrameAdvanceN, FrameLengthN)
% [WholeFrames, PartialFrames] = ...
%	spFrameCount(SignalN, FrameAdvanceN, FrameLengthN)
% 
% Given the number of samples SignalN in a signal and the length and
% advance in the frame in samples, determine the number of complete
% and partial frames in the signal.
%
% This code is copyrighted 2004 by Marie Roch.
% e-mail:  marie.roch@ieee.org
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 

% Compute number of frames including whole and partial ones.
TotalFrames = ceil(SignalN / FrameAdvanceN);

% Determine how many of those are whole frames
Whole = TotalFrames;	% Optimistic guess
OffsetToLastSample = FrameLengthN - 1;
% Back off until we have the complete number of frames.
while ((Whole - 1) * FrameAdvanceN  + FrameLengthN) > SignalN
  Whole = Whole - 1;
end

Partial = TotalFrames - Whole;

