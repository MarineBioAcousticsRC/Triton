%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sound file to detect blue whales in:
filename = 'C:\Documents and Settings\sara\My Documents\Detectors\Mellinger\Mellinger\useful\CINMS03J_sitJ_080801_203300.d100.x.wav';

% Define the spectrogram correlation kernel:
startF    = 50.67;	% Hz
endF      = 47.59;	% Hz
startT    = 0;		% s
endT      = 12.77;	% s
bandwidth = 2.0;	% Hz

% Define the peak detection parameters:
nbdS = 5.0;
thresh = 25;

% Define the spectrogram parameters:
gramParams = struct( ...
    'frameSizeS', 2.0, ...	% spectrogram frame size, s
    'overlapFrac', 0.5, ...	% fraction in (0,1)
    'zeroPadFrac', 0);		% fraction in (0,1)
%%%%%%%%%%%%%%%%%%%%%%%%%% end of configuration %%%%%%%%%%%%%%%%%%%%%%%%%%


% Read sound, make spectrogram of it.
[x,sRate] = wavread(filename);
[gram,fRate,gramParams] = davespect(x, gramParams, sRate);

% Make spectrogram correlation kernel, correlate it with spectrogram.
[ker,vOff,hOff] = multiKernel(startF, endF, startT, endT, bandwidth, sRate, ...
    fRate, gramParams.frameSize, gramParams.zeroPad, gramParams.nOverlap, 1);
detFn = dumbConv(gram, ker, vOff);

% Display the results: first the spectrogram, using some heuristics for
% intensity scaling and frequency limits, and then the detection function.
subplot(211)
med = median(gram(:)); mx = max(gram(:));  % used for intensity scaling
imagesc([0 nCols(gram)/fRate], [0 sRate/2], gram, [med + (mx-med)*[.25 1]])
set(gca, 'YDir', 'normal', 'YLim', [startF+(endF-startF)*[2.0 -1.0]])
colormap(hot)
ylabel('Hz')
title('spectrogram of blue whale band')

subplot(212)
plot(hOff + (0 : length(detFn)-1)/fRate, detFn)	% detection function
set(gca, 'XLim', hOff + [0 length(detFn)-1]/fRate, 'YLim',[0 max(detFn)*1.05])
title('detection function')
xlabel('time, s')

peakIx = dpeaks(detFn, round(nbdS*fRate), thresh);
peakS = ((peakIx-1)/fRate + hOff);
disp('Detection times:')
fprintf('%.1f  ', peakS); disp(' ')

hold on
plot(get(gca, 'XLim'), [thresh thresh], 'r')	% threshold
plot(peakS, get(gca,'YLim')*[1.1;0.9]*ones(1,length(peakS)), 'r*') % detections
hold off


% Can also do    showKernel(ker, sRate, fRate)    to image the kernel.
