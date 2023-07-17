function MS = spSample2MS(Samples, Hertz, varargin)
% MS = spSample2MS(Samples, Hertz, OptioanlArgs)
%
% Given a number of samples and a sample rate in Hertz, determine
% the time in milliseconds.
%
% OptionalArgs:
%
%	'Rounding', String
%		Where String is:
%		'round' - round towards nearest integer
%		'floor' - round towards negative infinity
%		'ceil' - round towards positive infinity
%		'none' - no rounding (default)
%
% This code is copyrighted 2002 by Marie Roch.
% e-mail:  marie.roch@ieee.org
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 

MS = Samples / Hertz * 1000;
n=1;
Rounded = 0;
while n <= length(varargin)
  switch varargin{n}
   case 'Rounding'
    switch varargin{n+1}
     case 'round'
      Rounded = 1; MS = round(MS);
     case 'floor'
      Rounded = 1; MS = floor(MS);
     case 'ceil'
      Rounded = 1; MS = ceil(MS);
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

% Should a default rounding be desired,
% check the Rounding flag here and round if not rounded.
% No need to check as default is no rounding.



