function Result = spNLFilter(Signal, Type, varargin)
% spNLFilter(Signal, FilterType, Arg1, ... ArgN)
%
% Perform non linear filtering upon a signal.  
%
% Valid filter types:
%	'diff' - Computer Nth difference
%		N (Arg 1) - Nth difference
%
%	'hanning' - Smooth via an N point Hanning filter with
%		normalized coefficients.  
%		N (Arg 1) - Number of points (odd recommended)
%		
%	median - Median filter
%		Median (Arg 1) - Median filter size
%		
%	peaknorm - Peak normalization
%		NormalValue (Arg 1) - Value to which highest
%			peak is normalized
%
%	Tukey - Nonlinear double smoothing.
%		described in IEEE Trans. ASSP-23 No. 6, Dec 75
%		Rabiner, Sambur, Schmidt
%
%         x(n) ----------> + -------|
%		  |        ^ 	    |
%		  v        | 	    v
%            |----------|  |   |----------|
%	     | median   |  |   | median   |
%	     | smoother |  |   | smoother |
%	     |----------|  |   |----------|
%	          |        |        |
%	          | -1 --> *        |
%                 v	   ^        v
%            |----------|  |   |----------|
%     	     | linear   |  |   | linear   |
%    	     | smoother |  |   | smoother |
%	     |----------|  |   |----------|
%		  |	   |	    |
%		  |	   |	    |
%		  |--------|	    |
%		  v     	    |
%	 w(n) <-- + <---------------|
%
%		Arguments:
%		Median (Arg 1) - Median filter size
%		Smooth Size (Arg 2) - Number of points for linear smoother
%

if size(Signal, 2) == 1
  % Row vector, we expect a column vector
  Signal = Signal';
  Transpose = 1;
else
  Transpose = 0;
end

if isstr(Type)
  switch Type(1)
    % Median filtering
    case {'m','M'}
     
     FilterSize = varargin{1};
     if license('test', 'signal_toolbox')
       % User has signal processing toolbox, use it
       % For small filter sizes, a good chunk of their code
       % When profiled in Matlab2008b, 40% of the time was spent
       % dealing with multiple dimensions, and ~4% of the time or more
       % was spent checking arguments.  This filter is an excellent
       % candidate for a mex file.
       Result = medfilt1(Signal, FilterSize);
     else
       % Much slower, slightly different results
       error(nargchk(1,3,nargin))
       MidPtOffset = (FilterSize - 1) / 2;
       Result = Signal;
       [Dummy, SignalSize] = size(Signal);
       % Handle beginning
       for i = 1:MidPtOffset
	 Result(i) = median(Signal(1:i+MidPtOffset));
       end
      % Handle middle
      for i = MidPtOffset+1:SignalSize - MidPtOffset
	Result(i) = median(Signal(i-MidPtOffset:i+MidPtOffset));
      end
      % Handle end
      for i = SignalSize - MidPtOffset + 1:SignalSize
	Result(i) = median(Signal(i-MidPtOffset:SignalSize));
      end
     end
    
  case {'d','D'}
    % Nth difference filter
    error(nargchk(1,3,nargin))
    Result = spDelta(Signal, varargin{1});
    
  case {'h','H'}
    % Normalized Hanning Filter
    error(nargchk(1,3,nargin))
    FilterSize = varargin{1};
    % Reuse Hanning filter from previous invocation if available
    % Helpful when called frequently w/ same size
    persistent Hanning;
    if length(Hanning) ~= FilterSize
        Hanning = hanning(FilterSize);
        Hanning = Hanning / sum(Hanning);
    end
    % Like filter(Hanning, 1, Signal), but adds trailing zeros
    % to let filter output die.
    Result = conv(Hanning, Signal);

  case {'p','P'}
    % Peak Normalization
    error(nargchk(1,3,nargin))
    PeakVal = varargin{1};
    Result = Signal - max(Signal) + PeakVal;
    
  case {'t','T'}
    % Tukey filter
    error(nargchk(1,4,nargin))
    Median = varargin{1};
    HanningSize = varargin{2};
    if ~ mod(HanningSize, 2)
      error('Hanning window size must be odd for Tukey filter');
    else
      Offset = floor(HanningSize / 2);
    end
    
    EstSignal = spNLFilter(Signal, 'Median', Median);
    EstSignal = spNLFilter(EstSignal, 'Hanning', HanningSize);
    EstSignal([1:Offset end-Offset+1:end]) = [];	% dump phase shift

    Error = Signal - EstSignal;
    Error = spNLFilter(Error, 'Median', Median);
    Error = spNLFilter(Error, 'Hanning', HanningSize);
    Error([1:Offset end-Offset+1:end]) = [];	% dump phase shift
    
    Result = EstSignal + Error;
    
  otherwise
    error(sprintf('Unrecognized filter type "%s"\n', Type));
end

else
	error('Type must be a string\n');
end

if Transpose
  Result = Result';
end
