function mkspecgram
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% mkspecgram.m
%
% makes the spectogram and sets the right parameters based on the spectrogram
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS DATA

   % some spectra stuff 
   window = hanning(PARAMS.nfft);
   noverlap = round((PARAMS.overlap/100)*PARAMS.nfft);
   % calculate spectrogram plot (need signal toolbox)
%    [sg,f,PARAMS.t]=specgram(DATA(:,PARAMS.ch),PARAMS.nfft,PARAMS.fs,window,noverlap);
    [~,f,PARAMS.t,sg]=spectrogram(DATA(:,PARAMS.ch),window,noverlap,PARAMS.nfft,PARAMS.fs);
   % produce image (gain) only within limits
%    nf = length(f);

   df = PARAMS.fs/PARAMS.nfft;
%    k = length(PARAMS.t);
   fimin = floor(PARAMS.freq0 / df)+1;
   fimax = floor(PARAMS.freq1 / df)+1;
   sg = sg(fimin:fimax,:);
   PARAMS.f = f(fimin:fimax);
%    PARAMS.pwr = 20*log10(abs(sg))...		% counts^2/Hz
%       - 10*log10(sum(window)^2)...  % undo normalizing factor
%       + 3;      % add in the other side that matlab doesn't do
   PARAMS.pwr = 10*log10(abs(sg));		% counts^2/Hz
   PARAMS.fimin = fimin;
   PARAMS.fimax = fimax;