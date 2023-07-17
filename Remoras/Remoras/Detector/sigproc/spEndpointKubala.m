% [EndpointedSignal, Info] = spEndpoint(Signal, SampleRate, Framing)
% 
% Given a vector Signal of type int16 and the rate at which the signal
% was sampled, return an endpointed version of the signal.  If the optional
% argument Framing is present, the endpointed signal is returned as a
% matrix where each column is frame.  Framing is a row or column vector
% where the first argument indicates the advance rate for the frame and
% the second argument indicates the length.  Both measurements are in MS.
%
% Example:
%	[Signal.pcm16 Signal.sr]  = some function which aquires the signal();
%	EP = spEndpoint(Signal.pcm16, Signal.sr, [10 20]);
%
% The optional output Info is a structure containing information about
% the signal such as the DC bias, SNR, etc.
%
% See also:  int16
%
% This code is copyrighted 2002 by Marie Roch.
% e-mail:  marie.roch@ieee.org

