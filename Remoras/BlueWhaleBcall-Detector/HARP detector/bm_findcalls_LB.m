function bm_findcalls_LB(detection, init_params)
% Adapted from David Mellinger's 
% smk 100219

% Adapted from XMLfindcalls
% Modified to resolve issues reading xwav files with Tethys 2.5 update
% lb 030221

import nilus.*; % make nilus classes accessible
global PARAMS DATA REMORA detections helper

% rename some global variables for brevity
rf_num = PARAMS.raw.currentIndex; % # of the raw file we're on
rf_end = PARAMS.raw.endIndex; % last rf # in the window
win_len = REMORA.dt_bwb.win_len; % APPROXIMATE length of the analyzed window in s
% rf_dur = PARAMS.tseg.sec*2; % duration of rf in s
% offset = PARAMS.offset; % who knows what this is #shittydocumentation
% start_time = PARAMS.plot.dnum; % start timestamp of data we want
% end_time = start_time + win_len; % end timestamp of data we want


%%%%%%%%%%%%%%%%%%%%%%%%% configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define the spectrogram correlation kernel:

% parameters from .mat file
thresh = REMORA.bm.settings.thresh;
startF = REMORA.bm.settings.startF;
endF = REMORA.bm.settings.endF;

%2011-SOCAL
% startF    = [47.5 46.4 45.7 45.3];
% endF      = [46.4 45.7 45.3 44.7];	% Hz
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
% % %Right Whale Lisa kernel
% startF    = [100];	% Hz
% endF      = [150];	% Hz
% startT    = [0];		% s
% endT      = [1];	% s
% bandwidth = 10.0;	% Hz


% Define the peak detection parameters:
nbdS = 5.0;
% thresh = 31;

% Define the spectrogram parameters:
gramParams = struct( ...
    'frameSizeS', 2.0, ...	% spectrogram frame size, s
    'overlapFrac', 0.5, ...	% fraction in (0,1)
    'zeroPadFrac', 0);		% fraction in (0,1)
%%%%%%%%%%%%%%%%%%%%%%%%%% end of configuration %%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%% XML construction from configuration %%%%%%%%%%%%%%%%%%%%
if init_params == true
    nFreq = [];
    nTime = [];
    vFreq = [];
    vTime = [];
    % BmB det parameter names/values (n for element name, v for value)
    for pdx=1:length(startF)+1
        nFreq = [nFreq; string(strcat('Freq', sprintf('%d',pdx) ,'_Hz'))];
        nTime = [nTime; string(strcat('Time', sprintf('%d',pdx), '_s'))];
        if pdx < length(startF)
            vFreq = [string(vFreq); string(startF(pdx))];
            vTime = [string(vTime); string(startT(pdx))];
        else
            vFreq = [string(vFreq); string(endF(pdx-1))];
            vTime = [string(vTime); string(endT(pdx-1))];
        end
    end
    
    % parameter names
    nBlock = "Block_s";
    nBandw = "Bandwidth_Hz";
    nThresh = "Threshold";
    nNeighb = "Neighboorhood";
    
   % parameter values
    vBlock = string(win_len);
    vBandw = string(bandwidth);
    vThresh= string(thresh);
    vNeighb = string(nbdS);

% Setting User Defined Algorithm Parameters (Nilus Word Doc)
    % Building parent objects
    algoType = AlgorithmType();
    detections.setAlgorithm(algoType);
    Algorithm = detections.getAlgorithm();
    
    helper.createRequiredElements(Algorithm);
    
    params = Algorithm.getParameters();
    param_list = params.getAny();
    
    % create parameter tags
    for tdx = 1:length(nFreq)
        helper.AddAnyElement(param_list, nTime(tdx), vTime(tdx));
        helper.AddAnyElement(param_list, nFreq(tdx), vFreq(tdx));
    end
    
    helper.AddAnyElement(param_list, nBlock, vBlock);
    helper.AddAnyElement(param_list, nBandw, vBandw);
    helper.AddAnyElement(param_list, nThresh, vThresh);
    helper.AddAnyElement(param_list, nNeighb, vNeighb);
end

%%%%%%%%%%%%%%%%%%%%%%  END XML CONSTRUCTION  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read in data
% try
% data = ioReadXWAV(PARAMS,...
%     0, rf_dur, PARAMS.nch, ...  % can also hard-code channel
%     PARAMS.ftype, filename);

% loop over each rf whose data we're grabbing so that we can avoid timing
% issues, and add padding if needed
data = [];
rf_offsets = zeros(1, rf_end-rf_num);
for k = rf_num:rf_end
    PARAMS.plot.dnum = PARAMS.raw.dnumStart(k);
    PARAMS.raw.currentIndex = k;
    PARAMS.tseg.sec = PARAMS.xhd.byte_length(k)/PARAMS.xhd.ByteRate;
    if k ~= rf_num
        rf_offsets(k-rf_num+1) = rf_offsets(k-rf_num)+PARAMS.tseg.sec;
    end
    readseg_bwb;
    DATA = DATA';
    data = [data; DATA'];
end

PARAMS.raw.rf_offsets = rf_offsets;

fprintf('rf #%d-%d\n', rf_num, rf_end);
fprintf('Window start date: %s\n',datestr(PARAMS.raw.dnumStart(rf_num)...
    +dateoffset, 'mm/dd/yyyy HH:MM:SS.fff'));
% fprintf('Window offset time in s: %d\n', start_time);
fprintf('Window length in seconds: %.2f\n', length(data)/PARAMS.fs);
fprintf('\n');

% spectrogram
[gram,fRate,gramParams] = davespect(data, gramParams, PARAMS.fs);

% spectrogram correlation kernel; convolve with spectrogram.
[ker,vOff,hOff] = multiKernel(startF, endF, startT, endT, bandwidth, ...
    PARAMS.fs, fRate, gramParams.frameSize, gramParams.zeroPad, ...
    gramParams.nOverlap, 1);
detFn = dumbConv(gram, ker, vOff);

%         Can also do  ...
%             showKernel(ker, PARAMS.fs, fRate)    % to image the kernel

peakIx = dpeaks(detFn, round(nbdS*fRate), thresh);
score = detFn(peakIx);
peakS = ((peakIx-1)/fRate + hOff);
% disp('Detection times:')

% only grab detections from first half of window so no double counting,
% unless we're on the last window
if PARAMS.raw.endIndex ~= length(PARAMS.raw.dnumStart)
    det_inds = find(peakS <= (rf_offsets(end)+PARAMS.tseg.sec)/2);
    peakS = peakS(det_inds);
    score = score(det_inds);
end

% associate a raw file number with each of the detections
det_rf_nums = zeros(length(peakS), 1);
det_offset_rf = zeros(length(peakS), 1);
det_timestamp = zeros(length(peakS), 1);
for k = 1:length(peakS)
    det_offset = peakS(k);
    [~, rf_ind] = min(abs(rf_offsets-det_offset));

    % make sure we choose the rf the offset is in
    if det_offset < rf_offsets(rf_ind)
        rf_ind = rf_ind-1;
    end
    
    % which rf # does detection occur in
    det_rf_nums(k) = rf_ind;
    
    % offset from rf beginning of detection
    det_offset_rf(k) = det_offset - rf_offsets(rf_ind);
    
    % finally, timestamps of each detection, indexed off of rf it came from
    det_timestamp(k) = datenum(PARAMS.raw.dvecStart(rf_ind+rf_num-1, :)+...
        [0 0 0 0 0 det_offset_rf(k)])+dateoffset;
end


% % Display the results: first the spectrogram, using some heuristics for
% % intensity scaling and frequency limits, and then the detection function.
% PARAMS.dflag = true; % added otherwise 'dflag' is a non-existent field
% if PARAMS.dflag
%     figure;
%     subplot(2,1,1)
%     med = median(gram(:)); mx = max(gram(:));  % used for intensity scaling
%     imagesc([0 nCols(gram)/fRate], [0 PARAMS.fs/2], gram, ...
%         (med + (mx-med)*[.25 1]))
% %     set(gca, 'XLim', [0 win_len], 'YLim',[0 max(detFn)*1.05], 'YDir', 'normal')
%     set(gca, 'YDir', 'normal', 'YLim', startF(1)+(endF(4)-startF(1))*[2.0 -1.0])
%     colormap(jet)
%     xlabel('Time (s)')
%     ylabel('Frequency (Hz)')
%     title('Spectrogram of Blue Whale Band')
% 
% 
%     subplot(2,1,2)
%     plot(hOff + (0 : length(detFn)-1)/fRate, detFn)	% detection function
%     set(gca, 'XLim', [0 win_len], 'YLim',[0 max(detFn)*1.05])  % hOff + [0 length(detFn)-1]/fRate ...instead of 60.
%     title(sprintf('%s to %s', datestr(PARAMS.raw.dnumStart(rf_num)), ...
%         datestr(PARAMS.raw.dnumEnd(rf_end))));
%     xlabel('Time (s)')
%     ylabel('Frequency (Hz)')
% 
% 
%     hold on
%     plot(get(gca, 'XLim'), [thresh thresh], 'r') % threshold
%     plot(peakS, get(gca,'YLim')*[1.1;0.9]*ones(1,length(peakS)), 'r*') % detections
%     hold off
%     
%     % pause so you can look at window
%     waitfor(gcf);
%     
%     hold off;
%     close(gcf);
% end

bm_writecalls_LB(det_timestamp, score, detection);

end