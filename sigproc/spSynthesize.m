function [Signal, t] = spSynthesize(SampleRate, Time, Frequencies, Amplitudes)
% Signal = spSynthesize(SampleRate, Time, Frequencies, Amplitudes)
% Creates a synthetic signal of duration Time with energy at the frequencies
% specified in the vector Frequencies (Hz).  Each sinusoidal component 
% is scaled by the vector in Amplitudes.  Output is the time domain  
% column vector signal and x axis time markings.
%
% This code is copyrighted 1998 by Marie Roch.
% e-mail:  marie-roch@uiowa.edu
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 

error(nargchk(4,4,nargin));

% Make sure column vectors
if size(Frequencies, 2) ~= 1, Frequencies = Frequencies'; end
if size(Amplitudes, 2) ~= 1, Amplitudes = Amplitudes'; end

t=0:1/SampleRate:Time;	% time axis
Signal=zeros(1,length(t));	% empty signal
Rads = 2 * pi * Frequencies;
Signal = sum( sin(Rads(:,ones(length(t),1)) ... 
		  .* t(ones(length(Frequencies),1),:)) ... 
	      .* Amplitudes(:,ones(length(t),1)), 1)';

 
