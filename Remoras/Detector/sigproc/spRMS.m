function RMS = spRMS(Signal)
% Compute the Root Mean Square (RMS) of a Signal.  RMS is computed
% as follows:  
%
%	1/N * Sum_{k=1:N} SquaredMagnitude(Signal(k))
%
% Signal is assumed to be a column vector or a matrix where each 
% column is a signal whose RMS  is to be computed.  RMS will be 
% a row vector of the same length as  the number of columns in 
% Signal.
%
% This code is copyrighted 1998 by Marie Roch.
% e-mail:  marie-roch@uiowa.edu
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 

error(nargchk(1,1,nargin));

N = size(Signal,1);
if N == 1
  N = size(Signal, 2);	% row vector, take # of columns
end

RMS = sqrt(sum(Signal .* conj(Signal)) / N);


