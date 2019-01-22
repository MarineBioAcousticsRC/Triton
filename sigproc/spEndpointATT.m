function Segments = spEndpointATT(Energy, varargin)
% Segments = spEndpointATT(Energy, OptionalArgs)
%
% Implements the AT&T Labs speech endpointer described by:
%
% @Article{li2002:canny_ep,
%   status =	 {j},
%   author = 	 {Li, Q. and Zheng, J. and Tsai, A. and Zhou, Q.},
%   title = 	 {Robust endpoint detection and energy normalization
%                   for real-time speech and speaker recognition},
%   journal = 	 itsap,
%   year = 	 2002,
%   volume =	 10,
%   number =	 3,
%   pages =	 {146-157},
%   month =	 {March}
% }
%
% Optional arguments
% 
%	'StateMachine', String - Specify state machine to use
%		'rt' - Li et al real time
%		'extended' - Modifications to 'rt'
%
%	'Thresholds', [Lower, Upper] - Permits setting of lower and upper
%		thresholds for state machine (see Li et al. for details)
%		User may set only lower or upper threshold, by using NaN 
%		for the threshold which should use the default value.  
%		Defaults are those suggested in the article.
%
%	'Gap', GapFrames - Number of consecutive frames that filter response
%		must remain in [Lower, Upper] before speech is considered
%		complete.
%
%	'RepairContour', N - If N ~= 0, repair discontinuities in the
%		energy contour due to drops in the signal (i.e. 
%		due to an acoustic echo canceler).  All points in the
%		contour whose value is FloorValue will be repaired.
%		If N > 0, the smallest value in the contour is set to
%		the Floor Value.  Otherwise, the FloorValue is set to N.
%		Default off (N=0)
%
%	'Display', N - If N ~= 0, produces a figure which displays:
%		* filter response
%		* energy signal (scaled & shifted vertically so as not
%		  overlay the filter response
%		* indication of what was marked as speech
%		Default off (N=0)
%
%	'LowEnergyBackup', N
%		Subtracts N frames from the start of each segment.
%		Useful for low energy starts (i.e. fricatives).
%		Default no backup (N=0).
%
%	'FloorValue', N - All frames with energy values of N will be
%		assumed to have zero energy.  As these are usually 
%		coded as a very small number, they can represent a 
%		large discontinuity which can be marked as speech by the 
%		edge detector.  When RepairContour is set, these values
%		will be smoothed with appropriate noise values.
%
% This code is copyrighted 2003 by Marie Roch.
% e-mail:  marie.roch@ieee.org
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 



% Make sure Energy is a row vector
if ~ utIsVector(Energy), error('Energy must be a vector'); end
if ~ utIsVector(Energy, 'Type', 'row'), Energy = Energy'; end

% Tunable parameter deaults
Gap = 30;		% Li et al suggested default
ThreshUpper = 3.6;	% Li et al suggested default
ThreshLower = -3.0;	% Li et al suggested default
LowEnergyBackup = 0;
StateMachine = 'rt';

%ThreshLower = -6.0;
%ThreshUpper = 12;

g0 = 80.0;	% currently not used - variables for energy norm
gm = 60.0;

RepairContour = 0;
Display = 0;

n=1;
while n <= length(varargin)
  switch varargin{n}
   case 'StateMachine'
    StateMachine = varargin{n+1}; n=n+2;
    
   case 'Thresholds'
    Thresholds = varargin{n+1}; n=n+2;
    if length(Thresholds) ~= 2
      error(['Thresholds keyword parameter requires [ThresholdLower,' ...
	     ' ThresholdUpper']);
    end
    if ~ isnan(Thresholds(1))
      ThreshLower = Thresholds(1);
    end
    if ~ isnan(Thresholds(2))
      ThreshUpper = Thresholds(2);
    end
    
   case 'Gap'
    Gap = varargin{n+1}; n=n+2;
    
   case 'LowEnergyBackup'
    StartSpeechOffset = varargin{n+1}; n=n+2;
    if StartSpeechOffset < 0
      error('LowEnergyBackup must be >= 0');
    end

   case 'RepairContour'
     RepairContour = varargin{n+1}; n=n+2;
     if RepairContour < 0
       FloorValue = RepairContour;
     else
       FloorValue = min(Energy);
     end
     
   case 'Display'
    Display = varargin{n+1}; n=n+2;
    
   otherwise
    error(sprintf('Bad optional argument: "%s"', varargin{n}));

  end
end

% filter coefficients 
Long = 1;
if Long
  W = 13;		% filter width
  s = 7/W;
else
  W = 7;
  s = 1;
end
K = [1.582743 1.468015 -0.077481 -0.035918 -0.872097 -0.56];
A = .41 * s;

% Doesn't appear to be antisymmetric as claimed.  I suspect that
% the filter coefficients do need to be recalculated in spite of
% author's claim.  Looking at Table I of the cited Petrou/Kittler
% article, K1-K6 do vary depending upon filter length.  We'll have
% to check with Peter later.
%
% I think that they are just computing the negative values and reflecting
% about the axis, so we'll try the same thing.  The plot w/ reflection looks
% like their figure 1 (p. 148). 
f = - ConstructFilter(-W:0, A, s, K);
f = [f, fliplr(-f(1:W-1))];
f = f/13;	% normalization

if Display
  OriginalEnergy = Energy;	% needed for display
  DisplayArg = {'Display', 1};
else
  DisplayArg = {};
end

if RepairContour
  Energy = spRepairContour(Energy, 'RemoveShortBursts', 10, DisplayArg{:});
end

ShowComponents = 0;	% this is for debugging the filter
if ShowComponents
  range = -W:W;
  for x=range
    if x < 0
      Sign = -1;
    else
      Sign = 1;
    end
    f2(x+W+1) = Sign * ...
	(exp(A * x) * (K(1) * sin(A * x) + K(2) * cos(A * x)) + ...
	 exp(-A * x) * (K(3) * sin(A * x) + K(4) * cos(A * x)) + ...
	 K(5) + K(6) * exp(s * x));
    f3(x+W+1, 1) = Sign * exp(A*x) * K(1) * sin(A*x);
    f3(x+W+1, 2) = Sign * exp(A*x) * K(2) * cos(A*x);
    f3(x+W+1, 3) = Sign * exp(-A*x) * K(3) * sin(A*x);
    f3(x+W+1, 4) = Sign * exp(-A*x) * K(4) * cos(A*x);
    f3(x+W+1, 5) = Sign * K(5);
    f3(x+W+1, 6) = Sign * K(6)*exp(s*x);
  end
  f3(:, 7) = sum(f3, 2);
  
  for idx=1:6
    LegendText{idx} = sprintf('K_%d', idx);
  end
  LegendText{end+1} = 'f';
  plot(range, f3, 'o-');
  legend(LegendText{:})
end

SmoothEnergy = 0;
if SmoothEnergy
  HanningWidth = 7;
  Energy = spNLFilter(Energy, 'hanning', HanningWidth);
  % delete extra convolution values
  Energy(end-HanningWidth+2:end) = [];
end

% Convolve filter with energy signal which has been padded by the
% left value to avoid a large discontinuity at the beginning.
FiltResp = conv([Energy(ones(1,2*W)), Energy], f);
FiltResp = FiltResp(2*W+1:end);

% State names
Silence = 0;
InSpeech = 1;
LeavingSpeech = 2;

% State machine
PrevState = Silence;
State = Silence;
Segments = [];
SegmentCount = 0;
EnergyCount = length(Energy);
StateHistory = zeros(EnergyCount, 1);
Count = 0;
CountHistory = zeros(EnergyCount, 1);
NoiseFrameCountHistory = zeros(EnergyCount, 1);
NoiseFrames = 0;

ThreshRange = ThreshUpper - ThreshLower;
ThreshUpperLeavingSpeech = ThreshLower + .85 * ThreshRange;

NoiseFloordB = Energy(1);	%+
NoiseFloorAdaptNew = .03;	%+
NoiseFloorAdaptOld = 1 - NoiseFloorAdaptNew; %+
NoiseFloorHistory = zeros(EnergyCount, 1);

SignaldB = Energy(1) + 6;
SignalRunningAverageN = 3;
SingalRunningAverageRing = SignaldB(ones(SignalRunningAverageN, 1));
SignalRunningNext = 0;

SNRThreshdB = 7;

switch StateMachine
 case 'rt'
  for t=1:EnergyCount
    StateHistory(t) = State;
    CountHistory(t) = Count;

    switch State
     case Silence
      if FiltResp(t) > ThreshUpper
	
	SpeechFrames = 0; %+
	PrevState = State;
	State = InSpeech;
	
	NextStart = t - LowEnergyBackup;
	if SegmentCount
	  % Previous segment exists, check if it needs to be extended
	  % or a new segment created
	  if Segments(SegmentCount, 2) + 1 < NextStart
	    % noise in between, start new segment
	    SegmentCount = SegmentCount + 1;
	    Segments(SegmentCount, 1) = NextStart;	% mark start
	  end
	else
	  % First segment, place start at beginning or next start
	  SegmentCount = SegmentCount + 1;
	  Segments(SegmentCount, 1) = max(1, NextStart);
	end
      end
      
     case InSpeech
      
      if FiltResp(t) < ThreshLower
	Count = 0;
	PrevState = State;
	State = LeavingSpeech;
      end
    
     case LeavingSpeech
      
      if FiltResp(t) > ThreshLower
	if FiltResp(t) > ThreshUpper
	  PrevState = State;
	  State = InSpeech;
	else
	  % between thresholds
	  if FiltResp(t) > ThreshUpperLeavingSpeech
	    % Not high enough to return to speech, but
	    % enough to give us a new lease on life
	    Count = 0;
	  end
	  
	  if Count < Gap
	    Count = Count + 1;
	  else
	    Segments(SegmentCount, 2) = t;
	    PrevState = State;
	    State = Silence;
	    Count = 0;
	  end
	end
      else
	% Under lower threshold
	Count = 0;
      end
      
     otherwise
      error('Bad state');
    end
  end    
  
 case 'extended'
  for t=1:EnergyCount
    
    NoiseFloorHistory(t) = NoiseFloordB;
    StateHistory(t) = State;
    CountHistory(t) = Count;
    NoiseFrameCountHistory(t) = NoiseFrames;
    
    switch State
     case Silence
      if FiltResp(t) > ThreshUpper
	
	%+ Sanity check, are we really in a speech region or is this
	%+ just a hiccup in the noise floor.
	Range = t:min(EnergyCount, t+5);
	if mean(Energy(Range)) - NoiseFloordB >= SNRThreshdB
	  
	  NoiseFrames = 0; %+
	  SpeechFrames = 0; %+
	  PrevState = State;
	  State = InSpeech;
	  
	  NextStart = t - LowEnergyBackup;
	  if SegmentCount
	    % Previous segment exists, check if it needs to be extended
	    % or a new segment created
	    if Segments(SegmentCount, 2) + 1 < NextStart
	      % noise in between, start new segment
	      SegmentCount = SegmentCount + 1;
	      Segments(SegmentCount, 1) = NextStart;	% mark start
	    end
	  else
	    % First segment, place start at beginning or next start
	    SegmentCount = SegmentCount + 1;
	    Segments(SegmentCount, 1) = max(1, NextStart);
	  end
	end
      else
	%+ Compute noise floor as a geometric mean.
	%+ Avoid large swings by not permitting new values to be 
	%+ more than N% away from current one.
	if Energy(t) > NoiseFloordB
	  NoiseFrame = min(Energy(t), NoiseFloordB * 1.05);
	else
	  NoiseFrame = max(Energy(t), NoiseFloordB * 0.95);
	end
	NoiseFloordB = NoiseFloorAdaptNew * NoiseFrame + ...
	    NoiseFloorAdaptOld * NoiseFloordB; %+
      end
      
      
     case InSpeech
      SpeechFrames = SpeechFrames + 1; %+
      
      if FiltResp(t) < ThreshLower
	Count = 0;
	PrevState = State;
	State = LeavingSpeech;
	NotUnderThreshLowerYet = 1;	%added
      else
	if Energy(t) - NoiseFloordB <= SNRThreshdB
	  %+ We are very close to the noise floor
	  %+ Let's keep track of the number of times this has occurred.
	  NoiseFrames = NoiseFrames + 1; %+
	  
	  if NoiseFrames > 40 & NoiseFrames / SpeechFrames > .60
	    %+ If this is happening a lot and we have come from 
	    %+ silence, it is probably a false start
	    SegmentCount = SegmentCount - 1;
	    PrevState = State;
	    State = Silence;
	  end
	  
	end
      end
      
     case LeavingSpeech
      if Energy(t) - NoiseFloordB <= SNRThreshdB
	%+ We are very close to the noise floor
	%+ Let's keep track of the number of times this has occurred.
	NoiseFrames = NoiseFrames + 1; %+
      end
      SpeechFrames = SpeechFrames + 1;
      
      if FiltResp(t) > ThreshLower
	if FiltResp(t) > ThreshUpper
	  PrevState = State;
	  State = InSpeech;
	else
	  % between thresholds
	  if FiltResp(t) > ThreshUpperLeavingSpeech
	    % Not high enough to return to speech, but
	    % enough to give us a new lease on life
	    Count = 0;
	  end
	  
	  if Count < Gap
	    NotUnderThreshLowerYet = 1;	% added
	    Count = Count + 1;
	  else
	    Segments(SegmentCount, 2) = t;
	    PrevState = State;
	    State = Silence;
	    Count = 0;
	  end
	end
      else
	% Under lower threshold
	
	% original
	% Count = 0;
	
	% added
	Count = Count + 1;
	if NotUnderThreshLowerYet
	  Count = 0;
	  NotUnderThreshLowerYet = 0;
	end
      end
     otherwise
      error('Bad state');
    end
  end % end time
  
 otherwise
  error('Bad state machine')
end % switch StateMachine
      
% finish up
if State ~= Silence
  Segments(SegmentCount, 2) = t;
end

% If we had a false start, we may have a partial segment
% that needs to be deleted.
if size(Segments, 1) ~= SegmentCount
  Segments(end,:) = [];
end

if Display
  figure('Name', 'Filter response')
  
  EnergyAxis=1:length(Energy);
  FiltAxis=1:length(FiltResp);

  SpeechFrames = NaN;
  SpeechFrames = SpeechFrames(ones(size(Energy)));
  for k=1:SegmentCount
    SpeechFrames(Segments(k,1):Segments(k,2)) = min(FiltResp);
  end

  Scale = 1; %max(FiltResp) / max(Energy);
  Shift =  max(Energy) - min(FiltResp); %max(FiltResp) - min(FiltResp);

  plot(EnergyAxis, Energy * Scale -  Shift, ...
       FiltAxis, FiltResp, ...
       FiltAxis, ones(length(FiltResp), 1) * ThreshLower, ':', ...
       FiltAxis, ones(length(FiltResp), 1) * ThreshUpper, ':', ...
       EnergyAxis, SpeechFrames, ...
       EnergyAxis, -15 - StateHistory*5, ...
       EnergyAxis, CountHistory, ...
       EnergyAxis, NoiseFloorHistory * Scale - Shift, ...
       EnergyAxis, NoiseFrameCountHistory);

  LegendTags = {'energy','filter', sprintf('lower %.2f', ThreshLower), ...
		sprintf('upper %.2f', ThreshUpper), 'speech', ...
		'states', 'count', 'noise'};

  title('Li et al energy-based endpointer');
  xlabel('Frame index');
  ylabel('Filter response & Energy (shifted & scaled)')

  if RepairContour
    % Highlight repaired sections
    %Highlight = [];
    Same = find(Energy == OriginalEnergy);
    
    % Erase portions of signal that are the same
    OriginalEnergy(Same) = NaN;
    
    hold on;
    plot(EnergyAxis, OriginalEnergy * Scale - Shift, 'r:');
    LegendTags = {LegendTags{:}, 'Before repair'};
    hold off;
  end
  
  legend(LegendTags{:})
  
end

% ------------------------------------------------------------

function Filter = ConstructFilter(Range, A, s, K)

sinRange = sin(A*Range);
cosRange = cos(A*Range);
Filter = exp(A * Range) .* (K(1)* sinRange + K(2)*cosRange) + ...
	 exp((-A) * Range) .* (K(3)*sinRange + K(4)*cosRange) + ...
	 K(5) + K(6) .* exp(s * Range);
