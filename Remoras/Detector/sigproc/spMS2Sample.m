function Samples = spMS2Sample(MS, Hertz, varargin)
% Samples = spMS2Sample(MS, Hertz, OptioanlArgs)
%
% Given a time in MS and a sample rate in Hertz, determine
% the number of samples corresponding to the time.
%
% OptionalArgs:
%
%	'Rounding', String
%		Where String is:
%		'round' - round towards nearest integer
%		'floor' - round towards negative infinity (default)
%		'ceil' - round towards positive infinity
%		'none' - no rounding
%
% This code is copyrighted 2002 by Marie Roch.
% e-mail:  marie.roch@ieee.org
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 

Samples = (MS / 1000) * Hertz;

n=1;
Rounded = 0;
while n <= length(varargin)
  switch varargin{n}
   case 'Rounding'
    switch varargin{n+1}
     case 'round'
      Rounded = 1; Samples = round(Samples);
     case 'floor'
      Rounded = 1; Samples = floor(Samples);
     case 'ceil'
      Rounded = 1; Samples = ceil(Samples);
     case 'none'
      Rounded = 1;
     otherwise
      error(sprintf('Bad Rouning method %s', varargin{n+1}));
    end
    n=n+2;
    
   otherwise
    error(sprintf('Bad optional argument: "%s"', varargin{n}));
  end
end

if ~ Rounded
  Samples = floor(Samples);
end



