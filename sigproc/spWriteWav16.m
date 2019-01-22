function spWriteWav16(File, Waveform, SampleRate)
% spWriteAU(File, Waveform, SampleRate)
% Write Waveform as a Sun/Next AU file.
% It is assumed that the audio data is in the range of 16 bit PCM 

Normalization = 2^15;
wavwrite(Waveform / Normalization, SampleRate, 16, File);
