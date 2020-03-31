function [abstime,peakS] = bm_findcalls_soundtrap(y,I,blockIdx,startTime,endTime,startF,endF,thresh,block,halfblock,offset,DISPLAY,filename)
%% function findcalls(halfblock, block, gap, offset, startS, endS, filename, startF, endF, thresh,out_fid, DISPLAY)

% Adapted from David Mellinger's 
% smk 100219
% sbp 190917
% ak 200206

%%%%%%%%%%%%%%%%%%%%%%%%% configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define the spectrogram correlation kernel:

% Example kernel blue whale b call
% startF    = [45, 44.5, 44, 43.5];	% Hz
% endF      = [44.5, 44, 43.5, 42.7];	% Hz
startT    = [0 1.5 3 4.5];		% s
endT      = [1.5 3 4.5 10];	% s
bandwidth = 2.0;	% Hz

% %2011-OCNMS
% startF    = [47.67 47.13 46.59 46.23];	% Hz
% endF      = [47.13 46.59 46.23 45.43];	% Hz
% startT    = [0 1.5 3 4.5];		% s
% endT      = [1.5 3 4.5 10];	% s
% bandwidth = 2.0;	% Hz

% % %Be4 kernel
% startF    = [55 57.5 57.6];	% Hz
% endF      = [57.5 57.6 57.6];	% Hz
% startT    = [0 1 2];		% s
% endT      = [1 2 3];	% s
% bandwidth = 3.0;	% Hz
% 
% %Fin Whale kernel
% startF    = [25];	% Hz
% endF      = [20];	% Hz
% startT    = [0];		% s
% endT      = [1];	% s
% bandwidth = 5.0;	% Hz


% Define the peak detection parameters:
nbdS = 5.0;
% thresh = 30;

% Define the spectrogram parameters:
gramParams = struct( ...
    'frameSizeS', 2.0, ...	% spectrogram frame size, s
    'overlapFrac', 0.5, ...	% fraction in (0,1)
    'zeroPadFrac', 0);		% fraction in (0,1)

%%%%%%%%%%%%%%%%%%%%%%%%%% end of configuration %%%%%%%%%%%%%%%%%%%%%%%%%%

% Make spectrogram
[gram,fRate,gramParams] = davespect(y, gramParams,I.SampleRate);

% Make spectrogram correlation kernel, correlate it with spectrogram.
[ker,vOff,hOff] = multiKernel(startF, endF, startT, endT, bandwidth, I.SampleRate, ...
    fRate, gramParams.frameSize, gramParams.zeroPad, gramParams.nOverlap, 1);
detFn = dumbConv(gram, ker, vOff);

%         Can also do  ...
% showKernel(ker, I.SampleRate, fRate)    % to image the kernel

peakIx = dpeaks(detFn, round(nbdS*fRate), thresh);
score = detFn(peakIx);
peakS = ((peakIx-1)/fRate + hOff);
%             disp('Detection times:')


% Display the results: first the spectrogram, using some heuristics for
% intensity scaling and frequency limits, and then the detection function.
if DISPLAY > 0 && max(detFn)>0
    subplot(211)
    med = median(gram(:)); mx = max(gram(:));  % used for intensity scaling
    imagesc([0 nCols(gram)/fRate], [0 I.SampleRate/2], gram, [med + (mx-med)*[.25 1]])
     set(gca, 'YDir', 'normal','XLim', [0 block], 'YLim', [startF(1)+(endF(4)-startF(1))*[2.0 -1.0]])
    %set(gca, 'YDir','reverse')
    colormap(jet)
    ylabel('Hz')
    title('spectrogram of blue whale band')
    


    subplot(212)
    plot(hOff + (0 : length(detFn)-1)/fRate, detFn)	% detection function
    set(gca, 'XLim', [0 block], 'YLim',[0 max(detFn)*1.05])  % hOff + [0 length(detFn)-1]/fRate ...instead of 60.
    title(['detection: ',datestr(startTime),' - ',datestr(endTime)])
    xlabel('time, s')


    hold on
    plot(get(gca, 'XLim'), [thresh thresh], 'r')	% threshold
    plot(peakS, get(gca,'YLim')*[1.1;0.9]*ones(1,length(peakS)), 'r*') % detections
    hold off

    %             pause
end


abstime = bm_writecalls_soundtrap2 (halfblock, startTime, peakS, score);

end