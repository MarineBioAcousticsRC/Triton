function [complex_spectra] = whistle_frame_processing(Signal, Indices)
% Given the Signal and Indices structure it extracts frames and perform
% windowing (Hamming) and discrete fourier transform on extracted frames.

   % Hamming Window is created: frequency_length x 1
   % Normally used for narrowband application                             
   window = hamming(Indices.FrameLength);     
   complex_spectra  = [];
   
   for frame_index = 1 : Indices.FrameCount
       frames_extract = spFrameExtract(Signal, Indices, frame_index);                 
       
       % Windowing: Reduce spectral leakage   
       frames = frames_extract .* window;
  
       % Discrete Fourier transform: Time domain -> Frequency domain
       complex_spectra = [complex_spectra fft(frames)];             
   end  