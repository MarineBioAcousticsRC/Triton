function RepairedContour = spRepairContour(Contour, varargin)
% RepairedContour = spRepairContour(Contour)
%
% Given a vector which represents a contour with missing values, repair
% the discontinuities. By default, the missing value is taken to be
% the smallest value in the in the contour.
%
% Optional arguments:
%	'Missing', N
%		Sets the missing value to N as opposed to the
%		minimal value.
%	'Display', N
%		If N ~= 0, plots the original and repaired contour
%			as well as the detected peaks.
%	'RemoveShortBursts', N
%		If N >= 0, short segments of the contour which are
%		of length N or less and that are surrounded by
%		missing values are assumed to be too noisy to be
%		reliable and are treated like missing values.
%
% This code is copyrighted 2003 by Marie Roch.
% e-mail:  marie.roch@ieee.org
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 

% Make sure Contour is a row vector
if ~ utIsVector(Contour), error('Contour must be a vector'); end
if ~ utIsVector(Contour, 'Type', 'row')
  Contour = Contour';
  OutputColVector = 1;	% Remember so we can return output as column vector
else
  OutputColVector = 0;
end


% default values

MissingValue = min(Contour);	% smallest value represents a missing value
ShortBurstLength = 0;		% runs of valid values of <= this length
				% treated as missing values

WarnPercentage = .90;	% Warn when more than WarnPercentage of contour
			% contains the MissingValue

Display = 0;
			
n=1;
while n < length(varargin)
  switch varargin{n}
   case 'Missing'
    MissingValue = varargin{n+1}; n=n+2;
   case 'Display'
    Display = varargin{n+1}; n=n+2;
   case 'RemoveShortBursts'
    ShortBurstLength = varargin{n+1}; n=n+2;
   otherwise
    error(sprintf('Bad optional argument: "%s"', varargin{n}));
  end
end

% Locate any "floor" values which were probably assigned 
% for convenience.  i.e. representing log(0) by a small
% number.

FloorIndices = find(Contour == MissingValue);
if (length(FloorIndices) > WarnPercentage * length(Contour))
  warning(...
      sprintf('>%.2f%% of the energy samples == min value of %.2f', ...
	      WarnPercentage, MissingValue));
end

RepairedContour = Contour;

if ~ isempty(FloorIndices)
  
  % In telephone speech, we frequently see steep slopes in energy as the
  % acoustic echo cancellor cuts in and out.  These slopes cause the 
  % endpointer to detect false edges.  We will find these short runs
  % and set them to the floor value.
  
  % example
  % Floor Indices
  %	23 24     69 70 ... 76     164 165 ... 169   y
  %
  % Delta(idx) - Distance between the idx'th floored sample and the
  %	next one:
  %	 1 45      1  1 ... 88       1   1 ...  (y-169)
  %
  % DeltaJump(idx) - Indices of the elements of Delta which 
  % contain the distance to the next run of floored samples.
  %  2 10 16 ...
  %  as Delta(2) = 45, Delta(10) = 88, etc.
  %
  % Useful information:
  %		last frame in floored segment:  
  %			FloorIndices(DeltaJump(1)) = 24th frame
  %		length + 1 of non-floored value run between the 1st and 2nd
  %		run of floored values:
  %			Delta(DeltaJump(1)) = 45 
  %			so there are 44 frames
  
  Delta = diff(FloorIndices);
  DeltaJump = find(Delta > 1);
    
  if ShortBurstLength
    
    % Treat short regions of valid values as invalid.
    
    % Sample application:
    % In telephone speech, we frequently see steep slopes in energy as the
    % acoustic echo cancellor cuts in and out.  These slopes cause the 
    % endpointer to detect false edges.  We try to take some of the
    % samples around it.
    
    ShortBurstRuns = find(Delta(DeltaJump) < ShortBurstLength + 1);
    if ~ isempty(ShortBurstRuns)
      
      % Construct a list of regions of length <= ShortBurstRunLength
      ShortBurstIndices = zeros(length(ShortBurstRuns), 2);
      ShortBurstIndices(:,1) = FloorIndices(DeltaJump(ShortBurstRuns))'+1;
      ShortBurstIndices(:,2) = ...
	  ShortBurstIndices(:,1)+ Delta(DeltaJump(ShortBurstRuns))' - 2;
      
      % Set these short regions to the value which indicates missing data
      for idx=1:size(ShortBurstIndices, 1)
	Contour(ShortBurstIndices(idx,1):ShortBurstIndices(idx,2)) = ...
	    MissingValue;
      end
      
      
      % Recompute data structures
	FloorIndices = find(Contour == MissingValue);
	if (length(FloorIndices) > WarnPercentage * length(Contour))
	  warning(...
	      sprintf('>%.2f%% of the energy samples == min value of %.2f dB', ...
		      WarnPercentage, min(Contour)));
	end
	Delta = diff(FloorIndices);
	DeltaJump = find(Delta > 1);
    end
  end
  
  % Set up the region to be repaired
  RepairIndices = zeros(length(DeltaJump)+1,2);
  RepairIndices(:,1) = FloorIndices([1, DeltaJump+1])';
  RepairIndices(:,2) = FloorIndices([DeltaJump, end])';
  
  % Find the peaks of the smoothed signal
  SmoothedContour = spNLFilter(Contour, 'tukey', 3, 5);
  peaks = spPeakSelector(SmoothedContour, 'Display', Display);
  
  % Find the nearest peaks before & after the regions to be repaired
  % Update the repair indices so that they point to this region
  for k=1:size(RepairIndices, 1)
    LeftPeaks = find(peaks < RepairIndices(k, 1));
    RightPeaks = find(peaks > RepairIndices(k, 2));
    if ~ isempty(LeftPeaks)
      RepairIndices(k,1) = peaks(LeftPeaks(end)) + 1;
    end
    if ~ isempty(RightPeaks)
      RepairIndices(k,2) = peaks(RightPeaks(1)) - 1;
    end
  end
  
  % Values from which we will interpolate
  TargetIndices = [RepairIndices(:,1) - 1, RepairIndices(:,2) + 1];
  
  % Adjust energies if we started/ended in a floored value region.
  % As the beginning/ending samples are unknown, just set them to the
  % closest point for which we have an energy reading.
  if TargetIndices(1,1) == 0
    TargetIndices(1,1) = TargetIndices(1,2);
  end
  if TargetIndices(end,2) > length(Contour)
    TargetIndices(end, 2) = TargetIndices(end, 1);
  end
  
  Slope = RepairedContour(TargetIndices(:,2)) - ...
	  RepairedContour(TargetIndices(:,1));
  
  for idx = 1:length(Slope)
    Range = RepairIndices(idx, 1):RepairIndices(idx, 2);
    %Range = TargetIndices(idx, 1):TargetIndices(idx, 2);
    RangeLength = length(Range);
    RepairedContour(Range) = Contour(TargetIndices(idx, 1)) + ...
	Slope(idx) * (1:RangeLength)/(RangeLength+1);
  end

  
  if Display
    figure('Name', 'Contour Repair')
    indices = 1:length(Contour);
    plot(indices, Contour, 'b-', indices, RepairedContour, 'g-.');
    legend('Contour', 'Repaired')
  end

end
  
if OutputColVector
  RepairedContour = RepairedContour';
end

