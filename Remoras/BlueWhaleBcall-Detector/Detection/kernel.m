function [ker,voff,hoff] = kernel(startF,endF,duration,BW,sRate,fRate,...
    						dataSize,zeroPad,nOverlap)
% KERNEL          Compute a center-surround kernel for spectrogram correlations
%
% [kernel,voffset,hoffset] = kernel(startF,endF,duration,BW,sRate,fRate,...
%						dataSize,zeroPad,nOverlap)
% Compute a zero-sum center-surround convolution kernel for a chirp 
% that goes from "startF" (in Hz) to "endF" over time period "duration".
% The ker has the lowest frequency in row 1, which is how Canary stores
% spectrograms.
%
% The return value voffset is the number of PIXELS that the kernel should
% be shifted up (i.e., in frequency) to its operating place.  It corresponds
% to the minumum frequency present in the kernel.
%
% The return value hoffset is the number of SECONDS that the kernel takes
% to warm up.

nyquist = sRate / 2;
w       = round(duration * fRate);
h       = round((dataSize + zeroPad) ./ 2);
w       = w + 1;          % Take care of 1-based indexing.  Matlab is a pain.
binBW   = nyquist / h;
spread  = 6;             % hat function is 60 dB down beyond this
hLo     = max(1, round((min(startF, endF) - (BW/2) * spread) / binBW) + 1);
hHi     = min(h, round((max(startF, endF) + (BW/2) * spread) / binBW) + 1);
col     = ones(hHi-hLo+1,1) * (1:w);
row     = (hLo:hHi)' * ones(1,w);

axisF   = startF + ((col - 1) ./ (w - 1)) * (endF - startF);
ker     = hat(((row - 1) * binBW - axisF) / (BW / 2));
voff    = hLo;
hoff    = nOverlap/2/sRate;		% adjust for spectrogram offset

%mesh(flipud(ker));
% see multiKernel for imaging of kernel
