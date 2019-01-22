function NewData = spDelta(Data, Offset, varargin)
% Deltas = spDelta(Data, Offset, OptionalArgs)
% Construct differences for a data set where each row represents an
% observation.  Deltas are taken from +/- Offset observations for
% each observation.  Observations for whom the the deltas cannot be
% computed as they lie beyond the boundaries are handled by copying the
% left & right most delta vectors.
%
% Deltas are computed according to the following linear regression formula:
%			
%	d_t = sum_{z=1 to Offset} z * (c_{t+z} - c_{t-z})
%	      -------------------------------------------
%		       2 * sum_{z=1 to Offset} z^2
%	Young S., Odell J., Ollason D., Valtchev V., 
%	and Wooland P., _The HTK Book_, Cambridge University.
%
% or via the simple difference:
%
%	d_t = c_{t-Offset} - c_{t+Offset}
%	      ---------------------------
%		   2 * Offset
%
% Optional arugments:
%	'Components' [ComponentIndices] - Deltas should only be
%		computed on a subset of the components
%		as specified in the vector:  [3 7 9] would
%		compute deltas for the 3rd, 7th, and 9th components
%		only.  An empty matrix indicates that the delta
%		should be computed for all components.
%		This can be used to compute the so-called delta deltas
%		by selecting previously computed deltas.
%
%	'Method' DeltaMethod
%		'simple' - Use the simple difference method
%		'regression' - Compute regression difference (default)
%
% The column data is extended with the difference data.
%
% Examples:  
%
% Assume Observations contains 13 components (ie c0 + MFCC c1-c12)
%
% ObsDelt = spDelta(Observations, 2, 'Components', [2:13])
% Returns the set of observations with the first difference
% of components 2-13 as new components.  Two frames to the left
% and right are used to compute the first difference.  In this example,
% we do not compute the derivative of the energy c0.
%
% ObsDeltDelt = spDelta(ObsDelt, 1, 'Components', [14:25])
% Compute the so-called delta delta coefficients.  Note that
% take the derivative of the preceding and following frames, which
% already contain the two frame offsets from our previous call.
%
% This code is copyrighted 1997-2003 by Marie Roch.
% e-mail:  marie.roch@ieee.org
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 

if nargin < 2
    error('requires 2 or more arguments');
end

Components = [];		% defaults
Method = 'regression';

m=1;
while m < length(varargin)
  switch varargin{m}
   case 'Components'
    Components = varargin{m+1}; m=m+2;
    
   case 'Method' 
    Method = varargin{m+1}; m=m+2;
    
   otherwise
    error(sprintf('Bad option "%s"', varargin{m}));
  end
end

[Length, Dim] = size(Data);

if isempty(Components)
  Components=1:Dim;	% Compute diff on all components
  DiffDim = Dim;
else
  DiffDim = length(Components);
end

NDim = Dim + DiffDim;	% New # of dimensions
DeltaRange = Dim+1:NDim;

% Determine location of the first and last samples for which
% we can compute complete delta coefficients.
Left= 1 + Offset;
Right = Length - Offset;

if Left >= Right
  error('Offset too large for number of observations');
end

NewData = zeros(Length, NDim);	% preallocate
NewData(:,1:Dim) = Data;	  % copy original data


switch Method
  case 'simple'
   % compute delta
   NewData(Left:Right, DeltaRange) = ...
       Data(1:(Length-2*Offset), Components) - ...
       Data((Left+Offset):end, Components);
   
   Denominator = 2 * Offset;

 case 'regression'
  % compute numerator 
  %	sum_{z=1 to Offset} z * (c_{t+z} - c_{t-z})

  for delta=1:Offset;
    NewData(Left:Right, DeltaRange) = ...
	NewData(Left:Right, DeltaRange) + ...
	delta * (Data(Left+delta:Right+delta, Components) - ...
		 Data(Left-delta:Right-delta, Components));
  end

  % compute denominator
  %	2 * sum_{z=1 to Offset} z^2
  Denominator = 2 * sum((1:Offset).^2);

end

NewData(:,DeltaRange) = NewData(:,DeltaRange) ./ Denominator;

% Copy lost deltas due to boundary conditions.
repcolumn = ones(1, Offset);
NewData(1:Left-1, DeltaRange) = NewData(Left*repcolumn, DeltaRange);
NewData(Right+1:end, DeltaRange) = NewData(Right*repcolumn, DeltaRange);

