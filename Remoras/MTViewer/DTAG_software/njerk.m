function    j = njerk(A,fs)
%
%    j = njerk(A,fs)
%       Compute the norm-jerk of a triaxial accelerometer
%       recording. Norm-jerk is ¦¦dA/dt¦¦ scaled to give
%       a result in m/s2 for A in g.
%       A is a 3-column vector of acceleration signals in g's. It
%       can be in the tag frame or whale frame - j will be
%       the same.
%       fs is the sampling rate in Hz of the acceleration signals.
%
%    markjohnson@st-andrews.ac.uk
%    15 aug 2012

j = (9.81*fs)*sqrt(diff(A).^2*ones(3,1)) ;
