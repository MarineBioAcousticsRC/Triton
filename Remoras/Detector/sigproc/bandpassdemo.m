function PCMbp = bandpassdemo(Conversation, FilterBank)
% BandPass = bandpassdemo(Conversation, Filter)
% Perform bandpass filtering demo.
% Conversation is an optional Spidre conversation number, i.e. 'sw2053a'.
% Filter is an optional filter bank of the type expected by spBandPass.
%
% If Filter is not specified, a demo filter is used.
% If Conversation is not specified, a synthetic signal with exponentially
% decaying harmonics is created.

if nargin < 2
  % design for LP
  % Rp 3, Rs 20
  load BandPassDemoFilter		% Read in Filter
end

if nargin < 1
  % Create synthetic data
  [PCM,t] = spSynthesize(8000, .3, [500, 1000, 1500, 2000, 2500], ...
      [1 1/2 1/4 1/8 1/16])';
else
  PCM = spiReadPCM([spiBase, 'derived/chansepEP/sw', Conversation]);
end
  
Bands = length(FilterBank.Band);
PCMbp = spBandPass(PCM, 8000, FilterBank);

figure

subplot(Bands+1,1,1);
psd(PCM, 512, 8000);
ylabel('PSD dB');
title('Input signal');

for k = 1:Bands
  subplot(Bands+1,1,k+1);
  psd(PCMbp.Signal{k}, 512, PCMbp.SampleRate(k));
  ylabel('PSD dB');
  title(sprintf('%d - %d Hz', FilterBank.PassBands(k,:)));  
end

x=1;	%for breakpoint
