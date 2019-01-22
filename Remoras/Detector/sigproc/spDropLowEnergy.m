function [NewFrames, RetainedFrameIndices] = ...
    spDropLowEnergy(Frames, EnergyThreshold)
% [NewFrames, RetainedFrameIndices] = spDropLowEnergy(Frames, Threshold)
% Given a framed signal where each column is a single frame and an energy
% threshold, return a modified set of frame where each frame's average
% energy is greater than Threshold (default Threshold=0).  If the output
% argument RetainedFrameIndices is present, it will contain indices of the
% original frame set that have been retained.
%
% This code is copyrighted 1997-1999 by Marie Roch.
% e-mail:  marie-roch@uiowa.edu
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 


error(nargchk(1,2,nargin))

if nargin < 2
  EnergyThreshold = 0;
end

SamplesPerFrame = size(Frames, 2);
% Compute energy
Energy = sum(Frames .* conj(Frames)) / SamplesPerFrame;

% Find frames with energy over the threshold
RetainedFrameIndices = find(Energy > EnergyThreshold);

% Retain above threshold frames
NewFrames = Frames(:,RetainedFrameIndices);
