function runkernal(gramParams, data, hdr)

[gram,fRate,gramParams] = davespect(data, gramParams, hdr.fs);

% Make spectrogram correlation kernel, correlate it with spectrogram.
[ker,vOff,hOff] = multiKernel(startF, endF, startT, endT, bandwidth, hdr.fs, ...
    fRate, gramParams.frameSize, gramParams.zeroPad, gramParams.nOverlap, 1);
detFn = dumbConv(gram, ker, vOff);

% Display the results: first the spectrogram, using some heuristics for
% intensity scaling and frequency limits, and then the detection function.
if DEBUGFLAG > 0
    subplot(211)
    med = median(gram(:)); mx = max(gram(:));  % used for intensity scaling
    imagesc([0 nCols(gram)/fRate], [0 hdr.fs/2], gram, [med + (mx-med)*[.25 1]])
    set(gca, 'YDir', 'normal', 'YLim', [startF+(endF-startF)*[2.0 -1.0]])
    colormap(jet)
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

    hold on
    plot(get(gca, 'XLim'), [thresh thresh], 'r')	% threshold
    plot(peakS, get(gca,'YLim')*[1.1;0.9]*ones(1,length(peakS)), 'r*') % detections
    hold off

    pause
end
