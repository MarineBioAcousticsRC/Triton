% [EnergyInfo] = spEnergyLevels(Signal, SampleRate, ...
%		FrameAdvanceMS, FrameLengthMS)
%
% Given a 16 bit signed signal (use Matlab function int16 to create), it's
% sample rate, and desired frame parameters, estimate the signal energy
% parameters.  Currently, Signal can only contain one channel of information
% and is thus simply a vector.  The returned structure EnergyInfo contains
% the following fields:
%
%	SampleCount - Length of Signal
%	SampleRate
%	Channels - Number of channels in signal (always 1)
%	Signal - signal energy (dB)
%	Noise - noise energy (dB)
%	SNR - Signal - Noise (dB)
%	FrameAdvanceN - Number of samples each frame is advanced
%	FrameLengthN - Size of each frame in samples
%	FrameEnergy - Energy (dB) of each frame.
