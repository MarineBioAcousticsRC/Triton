function ZeroCrossings = spZeroCrossings(Signal, Derivative)
% ZeroCrossings = spZeroCrossings(Signal, Derivative)
%
% Given a signal, locate the zero crossings.  
%
% For each zero crossing point between Signal(n) and Signal(n+1),
% the actual zero crossing will be closest to n or n+1.  The selection of
% n versus n+1 is computed in one of two ways:
%
% If the optional first derivative of the signal Derivative is given, the
% point with the greatest rate of change is selected.
%
% If the optional Derivative is not included, the Signal(n:n+1) is
% examined and the point closest to zero is selected.
%
% This code is copyrighted 2003 by Marie Roch.
% e-mail:  marie.roch@ieee.org
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 


% Ensure that Signal is of the proper type
if ~ utIsVector(Signal)
  error('Signal must be a vector.')
end

if ~ utIsVector(Signal, 'Type', 'column')
  Signal = Signal';
end

if nargin > 1
  % Ensure deriviative is of the proper type
  [minSz, minPos] = min(size(Derivative));
  if minSz ~= 1
    error('Derivative must be a vector.')
  elseif minPos ~= 2
    Derivative = Derivative';  % make col vec
  end
else
  Derivative = [];
end

% Locate zero crossings:
%	Sign of first derivative:  >0 --> 1 and <= 0 --> 0
%	Use first diff of Sign to locate change points
Sign = ones(size(Signal,1), 1);
Sign(Signal(:,1) <= 0) = 0;
ChangeSign = diff(Sign);

ZeroCrossings = find(ChangeSign ~= 0);

% As this is a discrete system, the first deriviative zero crossing will
% either be closest to the sample identified or the sample + 1.
% Determine which sample is closest to the zero.

% if isempty(Derivative)
%   % Select the point where the signal is closest to zero 
%   ZeroCrossingsNeighborhood = ...
%       [Signal(ZeroCrossings), Signal(ZeroCrossings+1)]';
%   [Values, Closest] = min(abs(ZeroCrossingsNeighborhood));
% else
%   % Select the point with the greatest rate of change
%   ZeroCrossingsNeighborhood = ...
%       [Derivative(ZeroCrossings), Derivative(ZeroCrossings+1)]';
%   [Values, Closest] = max(abs(ZeroCrossingsNeighborhood));
% end
%   
% ZeroCrossings = ZeroCrossings + Closest' - 1;

