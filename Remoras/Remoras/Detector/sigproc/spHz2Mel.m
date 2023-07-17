function Mel = spHz2Mel(Hz)
% Mel = spHz2Mel(Hz)
% Convert Hertz to Mels
% Uses Mel conversion from CMU SphinxIII

Mel = 2595 * log10(1 + Hz/700);
