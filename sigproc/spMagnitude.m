function Magnitude = spMagnitude(Signal, Method)
% SquaredMagnitude = spMagnitude(Signal, Method)
% Compute the squared magnitude of Signal.  Signal is assumed to be a column
% vector or a matrix where each column is a signal whose magnitude
% is to be computed.  Magnitude will be a row vector of the same length as
% the number of columns in Signal.
%
% The optional method indicates whether the magnitude should be
% computed in the 'time' (default) or 'freq' frequency domain.
%
% This code is copyrighted 1997, 1998 by Marie Roch.
% e-mail:  marie-roch@uiowa.edu
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 

error(nargchk(1, 2, nargin));

if nargin < 2
  Method = 'time';
end

Signals = size(Signal,2);

switch Method
  case 'time'
    Magnitude = sum(Signal .* conj(Signal));
    
  case 'freq'
    Spectrum = fft(Signal);
    Magnitude = sum(Spectrum .* conj(Spectrum));
end
      

