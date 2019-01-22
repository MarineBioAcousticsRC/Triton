function [PreemphasizedSignal] = spPreemphasis(Signal, Alpha)
% [PreemphasizedSignal] = spPreemphasis(Signal, Alpha)
% Preemphasizes signal using a first order preemphasis network
% with value Alpha:  ps[n] = s[n] - Alpha*s[n-1]
%
% This code is copyrighted 1997, 1998 by Marie Roch.
% e-mail:  marie-roch@uiowa.edu
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 
%
% This code is copyrighted 1997 by Marie Roch.
% e-mail:  marie-roch@uiowa.edu
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 

error(nargchk(2,2,nargin));

PreemphasizedSignal = filter([1 Alpha], [1], Signal);
