% PartitionedSignal = spPartition(Signal, SampleRate, Method)
% 
% Given a vector Signal of type int16 and the rate at which the signal
% was sampled, partition the Signal according to the Method.
%
% Valid methods:
% 'kubala' - Endpoint speech using the Kubala endpointer.  The following
%	fields will be populated:
%	Speech - Data tagged as speech
%	NonSpeech - Data tagged as non-speech.
%
%	Note that non consecutive segments are concatenated without
%	any padding.  Consequently, if the speech is subsequently
%	framed, portions of the signal which were not adjacent may
%	be contained in the same frame.
%
% See also:  int16
%
% This code is copyrighted 2002 by Marie Roch.
% e-mail:  marie.roch@ieee.org

