function [Frames, Labels] = ...
    spFrame(Signal, WindowSpacing, WindowLength, Partial)
%[Frames, Labels] = spFrame(Signal, WindowSpacing, WindowLength, Partial)
%	Construct frames for a one dimensional sampled 
%	signal.  Each frame starts every WindowSpacing samples
%	and contains WindowLength samples.  If the optional
%	argument Partial is non-zero, partial frames are kept, 
%	otherwise they are discarded.
%	
%	Output:
%		Frames - Matrix where each column is a frame
%		Labels - Starting position of each column in
%			in the original signal
%
%	Requires:  
%		Matlab Signal Processing toolbox
%		Naval PostGrad SPC Tools framdata.m
%
% This code is copyrighted 1997-2003 by Marie Roch.
% e-mail:  marie.roch@ieee.org
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 

% check arguments
error(nargchk(3, 4, nargin))	
if nargin < 4
  Partial = 0;
end

Overlap = WindowLength - WindowSpacing;
[Frames, Labels] = spFramData(Signal, WindowLength, WindowLength, Overlap, ...
			      'PartialFrame', Partial);
