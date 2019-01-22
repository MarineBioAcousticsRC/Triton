function envelope = spEnvelope(signal)
% Compute the envelope of a signal
% The envelope is taken from the magnitude of the analytic signal.

% The analytic signal is a signal with positive frequencies only.
% It is formed by adding a signal that has been modified such that it's
% negative frequencies cancel out the the original signal's negative
% frequencies, and the positive frequencies are additive.

% The signal to be added is formed by computing the Hilbert transform
% of the signal which shifts positive and negative frequencies in opposite
% directions:
%
%  negative freq are shifted by pi/2
%  positive freq are shifted by -pi/2
% 
% A subsequent phase shift of pi/2 results in the negative frequences being
% shifted by pi and the positive frequencies returning to the original
% phase.  By adding this phase shifted hilbert signal to the original
% signal, a signal with only positive frequencies, the analytic signal
% is formed.  In Matlab's Signal Processing Toolbox, hilbert(.) computes
% the analytic signal.  The absolute value of this is the envelope.
%
% Julius Orion Smith of Stanford has a nice explanation of this at:
% https://ccrma.stanford.edu/~jos/st/Analytic_Signals_Hilbert_Transform.html


envelope = abs(hilbert(signal));
