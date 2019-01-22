% MAData = stMA(Data, N, Shift)
% Assuming column oriented data, compute the N point moving average
% for each column and return a matrix of the same size containing the
% the moving average values.  The first M<N values will be MA(M).
% A uniformly weighted window is assumed.  The argument Shift is optional.
%
% 	Optional arguments:
% 		Shift
% 			Default behavior for each column is the N point
% 			causal process:
% 
% 				MA(t) = 1/N sum_{k=t-N+1}^{k=t} x(t)
% 
% 			When Shift is specified, the process is shifted:
% 
% 				MA(t) = 1/N
% 					sum_{k=t+Shift-N+1}^{k=t+Shift} x(t)
% 
% 			To have a centered MA window, choose odd N and
% 			set Shift=(N-1)/2.  S must be >= 0.  When Shift > 0,
% 			both the beginning and ending samples will be of
% 			MA(M) where M < N.
%
% Caveats:  
%
% This routine is implemented in C/C++ and must be compiled with: 
% 'mex stMA'.  You must have a C/C++ compiler installed to compile this.  
% Free C/C++ compilers are available for a variety of platforms.  Most
% linux/unix platforms come with the appropriate compilers, Microsoft
% offers a free version of their VisualStudio C/C++ (community edition)
% compiler for Windows.
% To see if it has been compiled for your platform, type 
% computer('arch') at the Matlab prompt to determine the
% architecture of your machine and operating system.  Check if a file
% with the name of this function and the architecture extension exists.
% If there is no file, then you need to compile in order to use this.
%
% For efficiency, the MA process uses a running sum rather than
% recomputing the average each time.  This may lead to errors in precision
% over time.
%  
% Complex data is not supported at this time, it would be trivial
% to add support for this.
%
% Example:
%  Given spectrogram S which is oriented by time X frequency,
%  we wish to compute a moving average of the power over a 5 s
%  window.  When computing the spectrogram, a 10 ms frame advance
%  was used, so this corresponds to a moving average of 500 time
%  samples.  We would like to take the average symmetrically around
%  each point, so we use 499 or 501 time bins so that there is
%  an even number about each point.
% 
%  By default, stMA would use the 5 s *preceeding* each time bin,
%  e.g. the time bin for 8.5 s would be computed from 3.51 s to
%  8.5 s.  This is not what we desire, so we add an offset of 
%  floor(501/2)+1 = 251 bins which shifts the average so that
%  we have 2.5 s on either side of 8.5 s.  
%
%  Resulting code
%  S_ma = stMA(S', 501, 251);  % 5 s MA process across spectral bins
%  S_ma = S_ma';  % put back in time X freq order
%  
%  Of course, we could compute these numbers based on time and
%  frame advance rather than hardcoding them as in this example.
%
%  S_ma now contains spectral power where each frame has 
%
% This code is copyrighted 1999 by Marie Roch.
% e-mail:  marie.roch@ieee.org
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 
