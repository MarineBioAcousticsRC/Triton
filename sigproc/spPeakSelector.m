function [PeakList, PeakIndicator] = spPeakSelector(Signal, varargin)
% [PeakList1, PeakIndictator] = spPeakSelector(Signal, Optional Args)
%
% Given a 1 dimensional signal, return a list of peak (and/or valley) 
% indices by examining the first and second derivatives of the signal.
%
% If the optional output PeakIndicator is present, PeakIndicator is
% of the same size as PeakList and indicates whether each item in
% PeakList is a peak (1) or a valley (0).
%
% Optional arguments:
%
%       'Method', 'simple', 'regression', 'magnitude'
%               'simple' - Peaks/valleys are defined as being above/below
%                       their nearest neighbors.  Detects every possible
%                       peak.
%               'simpleN' - Similar to simple, except with respect
%                       to their N nearest neighbors.
%               'regression' - An Nth order regression (default method
%                       using N=1) is fitted to the curve and peaks & 
%                       valleys are selected based upon approximations of
%                       the derivative.  Ignores tiny ridges in growing
%                       mountains.  This is the default method.
%               'magnitude' - Not a peak detector per se, but find the 
%                       largest/smallest sample.
%	'Type', 'peak'|'valley'|'peak+valley'
%		Select peaks (default), valleys, or both.  If the method
%               is peak+valley and a second output is defined, peaks will
%               be returned in PeakList1 and valleys in PeakList2.
%               Otherwise peaks and valleys are both in PeakList1.
%	'Display', N
%		If non-zero, creates a plot showing the signal, selected
%               peaks, as well as the signal derivatives used to pick
%               the peaks.
%
%       The following options are only applicable when regression-based
%       peak picking is active..
%  'Order', N
%     Number of points to either side fo the current
%               point used for computing peaks.
%	'RegressionOrder', N
%		Number of points to either side of the current 
%               sample used for computing regression curve for 
%		first derivative.  If no order is specified, 
%               1 is used.
%	'Threshold', N >= 0
%		Distance that the 2nd derivative must be away
%		from zero to be considered a local maximum or
%		minimum.  As these are discretized derivatives,
%		inflection points may have second derivatives
%		which are greater than zero.
%	'JerkRange', [Min Max]
%		Jerk is the third derivative which describes the
%		change in acceleration.  (Picture stepping on 
%		the gas and feling the "jerk' of high acceleration.)
%		When this option is specified, only peaks whose
%		jerk lies within the range specified by Min and Max
%		are returned.
%
% Sample invocation:
% peaks = spPeakSelector([2 3 9 5 6 7 9 4], 'Method', 'simple')
% peaks =
%     3 7
% indicating the 3rd and 7th items (9 and 9) are peaks.
%
% This code is copyrighted 2003-2009 by Marie Roch.
% e-mail:  marie.roch@ieee.org
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 


% Defaults
Method = 'regression';
Order = 1;     % how far out to compute regression
PeakType = 'peak';
FindPeaks = 1;	% Controls for finding peaks & valleys
FindValleys = 0;
Display = 0;	% plot?
Epsilon = 0;
Jerk = 0;
n=1;
while n < length(varargin)
  switch varargin{n}

   case 'Display'
    Display = varargin{n+1}; n=n+2;

   case 'JerkRange' 
    JerkRange = varargin{n+1}; n=n+2;
    if ~ isnumeric(JerkRange) || length(JerkRange ~= 2)
      error('JerkRange argument must be a 2 dimensional numeric vector');
    end
    if JerkRange(1) > JerkRange(2)
      error('JerkRange argument must be [Min, Max], not [Max, Min]')
    end
    error('JerkRange detection not yet implemented');
    
   case 'Method'
    Method = varargin{n+1};
    n=n+2;
    
   case {'Order', 'RegressionOrder'}
    Order = varargin{n+1};
    n=n+2;
    
   case 'Threshold'
    Epsilon = varargin{n+1}; 
    n=n+2;
    if Epsilon < 0
      erorr('Threshold argument must be >= 0');
    end
    
   case 'Type'
    PeakType = varargin{n+1};
    n=n+2;
    
   otherwise
    error(sprintf('Bad optional argument: "%s"', varargin{n}));

  end
end

% Ensure that Signal is of the proper type
if ~ utIsVector(Signal)
  error('Signal must be a vector.')
end

if ~ utIsVector(Signal, 'Type', 'column')
  Signal = Signal';
end

switch PeakType
 case 'peak'
  FindPeaks = 1;
  FindValleys = 0;
 case 'valley'
  FindPeaks = 0;
  FindValleys = 1;
 case 'peak+valley'
  FindPeaks = 1;
      FindValleys = 1;
 otherwise
  error('Bad Type argument %s', PeakType);
end

Peaks = [];
Valleys = [];

switch Method
 case 'magnitude'
  if FindPeaks
    [DontCare, Peaks] = max(Signal);
  end
  if FindValleys
    [DontCare, Valleys] = min(Signal);
  end
  
 case 'simple'
  % Simple peak detection.  See if center point above/below neighbors

  % When the sign of the first difference changes, we are at a peak
  % or valley.  By taking the second difference we can easily find
  % these locations
  diff2 = diff(sign(diff(Signal)));
  if FindPeaks
      Peaks = find(diff2 < 0)';
      if ~ isempty(Peaks)
          Peaks = Peaks + 1;  % account for lost offset w/ diff
      end
  end
  if FindValleys
      Valleys = find(diff2 > 0)';
      if ~ isempty(Valleys)
          Valleys = Valleys + 1;
      end
  end
  

 case 'simpleN'
  Order2 = 2 * Order;
  for idx = 1+Order:length(Signal)-Order
    Check = [idx-Order:idx-1, idx+1:idx+Order];
    if FindPeaks && sum(Signal(Check) < Signal(idx)) == Order2
      Peaks = [Peaks, idx];
    end
    if FindValleys && sum(Signal(Check) > Signal(idx)) == Order2
      Valleys = [Valleys, idx];
    end
  end
  
 case 'regression'
  % Compute first (Signal(:,2)) & second (Signal(:,3)) derivatives  
  Signal = spDelta(Signal, Order, 'Method', 'regression');
  Signal = spDelta(Signal, 1, 'Components', 2);
  if Jerk
    % Compute third derivative Signal(:, 4)
  Signal = spDelta(Signal, 1, 'Components', 3);
  end
  
  % Locate zero crossings:
  %	Sign of first derivative:  >0 --> 1 and <= 0 --> 0
  %	Use first diff of Sign to locate change points
  
  ZeroCrossings = spZeroCrossings(Signal(:,2), Signal(:,3));
  
  % Check for zero crossing for peaks/valleys 
  PeakList = [];
  
  if FindPeaks
    Peaks = ZeroCrossings(find(Signal(ZeroCrossings,3) < -Epsilon))';
  end

  if FindValleys 
    Valleys = ZeroCrossings(find(Signal(ZeroCrossings,3) > Epsilon))';
  end
  
 otherwise
  error(sprintf('Bad method:  %s', Method))
end

if Display 
  newplot
  HoldState = ishold;
  
  if ~ Jerk
    % User did not request jerk, but compute so that it can be plotted 
    Signal = spDelta(Signal, 1, 'Components', 3);
  end
  plot(Signal);
  hold on
  LegendText = {'Signal', 'vel', 'acc' 'jerk',};

  
  if FindPeaks
    plot(Peaks, Signal(Peaks, 1), 'r^');
    LegendText = {LegendText{:}, 'peak'};
  end

  if FindValleys
    plot(Valleys, Signal(Valleys, 1), 'gv');
    LegendText = {LegendText{:}, 'valley'};
  end
  
  legend(LegendText{:})
  if ~ HoldState
    hold off
  end
end

% set up output arguments
PeakList = [Peaks; Valleys];
if ~ isempty(Peaks) & ~ isempty(Valleys)
  % Has both peaks & valleys, sort them and retain
  % permutation in case user wants peak/valley indicator
  [PeakList, Permute] = sort(PeakList);
else
  Permute = [];  % didn't sort, no need for permutation
end
  
if nargout > 1
  % Build peak indicator according to original ordering
  PeakIndicator = [ones(size(Peaks)); zeros(size(Valleys))];
  if ~ isempty(Permute)
    % Reorder peak indicators to reflect sort
    PeakIndicator = PeakIndicator(Permute);
  end
end
