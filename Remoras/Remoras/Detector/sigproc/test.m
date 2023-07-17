
[Sig SigInfo] = corReadAudio([corBase('kingwb'), 'derived/au/w03_01_4ep']); 
[Noise NoiseInfo] = corReadAudio('e:/Corpus/noise/PinkNoise');

SigdB = 49;
NoisedB = 43.5;

% create degraded signal with desired SNR
[Degraded NoiseScale] = spDegrade(Sig, Noise, 'SignalLevel', SigdB, ...
				  'NoiseLevel', NoisedB, 'SNR', 20);

% extract cepstra
CepPts = 10;
SigCep = spPcmToCep(Sig, 'FFTPoints', 512, 'MaxTime', inf, ...
		    'SampleRate', 8000, 'NoEnergy', ...
		    'CepstrumPoints', CepPts);

NoiseCep = spPcmToCep(NoiseScale * Noise, 'FFTPoints', 512, 'MaxTime', inf, ...
		      'SampleRate', 8000, 'NoEnergy', ...
		      'CepstrumPoints', CepPts);

DegradedCep = spPcmToCep(Degraded, 'FFTPoints', 512, 'MaxTime', inf, ...
			 'SampleRate', 8000, 'NoEnergy', ...
			 'CepstrumPoints', CepPts);

SigVarCovar = cov(SigCep.Data{1});
NoiseVarCovar = cov(NoiseCep.Data{1});
DegradedVarCovar = stMAVarCov(DegradedCep.Data{1}, 10);

figure('Name', [Signal, ' - Estimated noise comparison'])
subplot(3,1,1)

visMatrix(abs(SigVarCovar), 'triu', 1);
Limits = get(gca, 'CLim');
% up the limit a little so that highest value isn't same color as no data
Limits(2) = 1.25 * Limits(2);
set(gca, 'CLim', Limits);
colorbar;
title('Covariance magnitude of "clean" cepstrum');
colormap(flipud(gray));

subplot(3,1,2)
visMatrix(abs(NoiseVarCovar), 'triu', 1);
title('Covariance magnitude of noise cepstrum');
set(gca, 'CLim', Limits);
colorbar;

subplot(3,1,3)
visMatrix(abs(DegradedVarCovar), 'triu', 1);
title('Covariance of estimated noise cepstrum');
set(gca, 'CLim', Limits);
colorbar;

figure('Name', [Signal, ' - Estimated noise comparison 2'])
ax = zeros(CepPts, CepPts);

Max = max(max(abs(SigVarCovar)));
for i=1:CepPts
  for j=1:CepPts
    if i >= j
      % set up axes and kill labels
      ax(i,j) = subplot(CepPts, CepPts, (j-1)*CepPts+i);

      % Compare variance/covariance
      %bar(abs([SigVarCovar(i,j), NoiseVarCovar(i,j), DegradedVarCovar(i,j)]));
      bar([SigVarCovar(i,j), NoiseVarCovar(i,j), DegradedVarCovar(i,j)]);
      set(ax(i,j), 'XTickLabel', {});
      set(ax(i,j), 'YTickLabel', {});
      MaxDisp = max(abs([SigVarCovar(i,j), NoiseVarCovar(i,j), ...
			 DegradedVarCovar(i,j)]));
      set(ax(i,j), 'YLim', [-MaxDisp MaxDisp]);
      %set(ax(i,j),'YLim', [0 Max]);
    end
  end
end

figure('Name', [Signal, 'Variance comparison'])
bar([diag(SigVarCovar) diag(NoiseVarCovar) diag(DegradedVarCovar)])
xlabel('Cepstral component')
ylabel('Variance')
colormap(gray);
legend('"Clean"', 'Noise', 'Estimated noise')

