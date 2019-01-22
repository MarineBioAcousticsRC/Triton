%===============================================================================
%                   dtFftRAPT
%===============================================================================
function [fx, tt]=dtFftRAPT(s, fs)
% function [fx, tt] = dtFftRAPT(s, fs)
%
% FFT based Robust Algorithm for Pitch Tracking
% Inputs:
%   s    waveform
%   fs   sampling frequency
% Outputs:
%   fx   pitch(frequency) at times specified in tt
%   tt   an N x 2 matrix where first column gives the times corresponding
%        to the frequencies in fx, and a 1 in the second column indicates
%        the beginning of a contour.
% 
% NOTE: If no outputs are specified, the function plots a graph containing
% the spectrogram, unsmoothed(blue) and smoothed(magenta) contours
% corresponding to the input waveform.
%

% -----
%
% Authors: Shyam Kumar Madhusudhana     <shyam@mail.sdsu.edu>
%          Dr. Marie Roch               <mroch@sciences.sdsu.edu>
%   

DEBUGFLAG = 0;
if nargout == 0
    DEBUGFLAG = 1;
end

% setup output variables' formats
ofx = zeros(0, 1);	% Contains frequencies in the contour
ott = zeros(0, 2);	% 1st col gives times for the above frequencies in the contour
                        % 2nd column identifies beginning of a new contour

s = s(:);               % force s to be a column

candtr = 0.8;
ncands = 10;
sweep_direction = 'b';  % d=downwards, u=upwards, b=both ways
freq_win = 8;           % Hz, window in which to look for candidates from previous frames
smoothing_span = 3;     % num of bins in smoothing filter
PeakRejectRatio = 0.9;  % if any peak is less than (avg_peak * 0.9), it is rejected
PeakRejectRatioS2 = 0.7;% Peak Reject Ratio Stage 2
MinContourLength = 0.75;% in seconds
LookBackLimit = 0.30;   % in seconds. Limit lookback to 0.30s(300 ms).
DoPostProcessing = 1;   % set to 0 if post-processing not needed, 1 if needed
PPGap = 1.5;            % in seconds. During post-processing, consider consecutive contours
                        % with separation less than PPGap.

[pwr, f, t] = fft_rapt_specgram(s, fs, 1024, 50, 30, 100);


nframe=length(t);
LookBackLimitPts = ceil(fs * LookBackLimit * nframe / length(s));
peaks = zeros(length(f), length(t));
peakidxs = zeros(length(f), length(t));
% for backtracking
best = cell(1, nframe);

% Enable, to perform per-frequency-bin normalization
spec_rate = .128;
noise_tail_s = 2;
spec_frames = round(noise_tail_s / spec_rate);
% probably will fail at end points - Shyam will fix :=)
noiseest = sum(pwr(:, [1:spec_frames, end-spec_frames-1:end]), 2) / (spec_frames * 2);
%fprintf('Size(noiseest) = (%d, %d)\n', size(noiseest, 1), size(noiseest, 2));
%fprintf('Size(pwr)      = (%d, %d)\n', size(pwr, 1), size(pwr, 2));
%keyboard
pwr = pwr - noiseest(:, ones(1,nframe));

% Identify peaks and the candidate frequency sequences.
% Complexity = n * m1,
% where n=numFrames & m1<<numFreqBins is the num of peaks
for iframe=1:nframe
    [peak_indexes, peak_values] = fft_rapt_findpeaks(pwr(:, iframe), 'q');
    %when debugging, uncomment the below line to see the peaks at every frame
    %fft_rapt_findpeaks(pwr(:, iframe), 'q');

    vipkd = [peak_values peak_indexes+f(1)-1];
    vipkd(find(peak_values<max(peak_values)*candtr), :) = [];    % eliminate peaks that are small
    if size(vipkd, 1)
        if size(vipkd, 1) > ncands
            vipkd = sortrows(vipkd);
            vipkd(1:size(vipkd, 1)-ncands, :) = [];    % eliminate lowest to leave only ncands
        end

        peaks(1:size(vipkd, 1), iframe) = vipkd(:, 1);
        peakidxs(1:size(vipkd, 1), iframe) = vipkd(:, 2);

        % Prepare data for backtracking
        if iframe>1
            prevcands = peakidxs(find(peakidxs(:, iframe-1)), iframe-1);
            best{iframe} = zeros(size(vipkd, 1), 1);
            for idx=1:size(vipkd, 1)
                freqidx=vipkd(idx, 2);
                better = [];
                if sweep_direction == 'd'
                    better = find(prevcands >= freqidx & prevcands <= freqidx+freq_win);
                elseif sweep_direction == 'u'
                    better = find(prevcands >= freqidx-freq_win & prevcands <= freqidx);
                elseif sweep_direction == 'b'
                    better = find(prevcands >= freqidx-freq_win & prevcands <= freqidx+freq_win);
                end
                [maxv, maxi] = max(peaks(better, iframe-1));
                if length(maxi)
                    best{iframe}(idx) = better(maxi);
                end
            end
        end
    end	    % if size(vipkd, 1)
end    % End identifying peaks and candidate frequency sequences

if DEBUGFLAG
    %figure
    imagesc(t, f, pwr);
    set(gca, 'YDir', 'normal');
    %figure
    hold on
end

mean = sum(max(peaks)) / nframe;
%fprintf('Mean : %f\n', mean);
newStart = 1;
lastBest = 0;

% Actual backtracking. Choose the best contour
% Complexity: n * (m1 + 
for iframe=1:nframe
    numcands = length(best{iframe});
    if numcands > 0
        if DEBUGFLAG
            plot(t(iframe*ones(numcands, 1)), peakidxs(1:numcands, iframe), 'k*');
            [maxv, maxi] = max(peaks(:, iframe));
            plot(t(iframe), peakidxs(maxi, iframe), 'go');
        end

        if iframe > 1
            continues = 0;
            currentcands = [];
            for idx=1:numcands
                if best{iframe}(idx) > 0
                    if(lastBest > 0 && (best{iframe}(idx) == lastBest) && peaks(idx, iframe) >= mean*PeakRejectRatio)
                        currentcands = [currentcands idx];
                        continues = 1;
                    else
                        if DEBUGFLAG
                            plot([t(iframe-1) t(iframe)], [peakidxs(best{iframe}(idx), iframe-1) peakidxs(idx, iframe)], 'y:');
                        end
                    end
                end
            end
            if continues == 1
                % choose the closest, may not be the peak with higher energy
                [minv, minx] = min(abs(peakidxs(currentcands) - peakidxs(lastBest)));
                idx = currentcands(minx);
                if DEBUGFLAG
                    plot([t(iframe-1) t(iframe)], [peakidxs(best{iframe}(idx), iframe-1) peakidxs(idx, iframe)], 'b-');
                end
                lastBest = idx;
                last_tt_idx = size(ott, 1);
                if newStart && ((last_tt_idx > 0 && ott(last_tt_idx, 1) < t(iframe-1)) || last_tt_idx == 0)
                    was_really_newStart = 1;    % assuming will be true for now
                    %lookback to see if there was a gap that could be filled
                    last_tt_idx = size(ott, 1);
                    if iframe > 2 && last_tt_idx > 0
                        if t(iframe - 2) == ott(last_tt_idx, 1)
                            inrange = fft_rapt_isinrange(ofx(last_tt_idx), peakidxs(best{iframe}(idx), iframe-1), freq_win, sweep_direction);
                            if inrange
                                was_really_newStart = 0;
                                if DEBUGFLAG
                                    plot([t(iframe-2) t(iframe-1)], [ofx(last_tt_idx) peakidxs(best{iframe}(idx), iframe-1)], 'b-');
                                end
                            end
                        % see if one point was leftover that could have been included
                        elseif iframe > 3 && t(iframe-3) == ott(last_tt_idx, 1)
                            intermcands = peakidxs(find(peakidxs(:, iframe-2)), iframe-2);
                            fgap = (2 * freq_win) + 1;    % priming, with an upper limit that'll never be reached
                            bestinterim = 0;
                            midfreq = (ofx(last_tt_idx) + peakidxs(best{iframe}(idx), iframe-1)) / 2;
                            % determine the best intermediate candidate point
                            for intermcandidx = 1:length(intermcands)
                                inrange1 = fft_rapt_isinrange(ofx(last_tt_idx), peakidxs(intermcandidx, iframe-2), freq_win, sweep_direction);
                                inrange2 = fft_rapt_isinrange(peakidxs(intermcandidx, iframe-2), peakidxs(best{iframe}(idx), iframe-1), freq_win, sweep_direction);
                                if inrange1 && inrange2
                                    ffgap = abs(peakidxs(intermcandidx, iframe-2) - midfreq);
                                    if ffgap < fgap
                                        fgap = ffgap;
                                        bestinterim = peakidxs(intermcandidx, iframe-2);
                                    end
                                end
                            end
                            if bestinterim
                                ofx = [ofx; bestinterim];
                                ott = [ott; t(iframe-2) 0];
                                was_really_newStart = 0;
                                if DEBUGFLAG
                                    plot([t(iframe-3) t(iframe-2)], [ofx(last_tt_idx) bestinterim], 'b-');
                                    plot([t(iframe-2) t(iframe-1)], [bestinterim peakidxs(best{iframe}(idx), iframe-1)], 'b-');
                                end
                            end
                        end
                    end    % end looking back for gaps
                    if DEBUGFLAG
                        plot(t(iframe-1), peakidxs(best{iframe}(idx), iframe-1), 'r*');
                    end
                    ofx = [ofx; peakidxs(best{iframe}(idx), iframe-1)];
                    ott = [ott; t(iframe-1) was_really_newStart];
                    newStart = 0;
                    
                    if was_really_newStart && iframe > 3 && last_tt_idx > 0
                        if t(iframe - 2) == ott(last_tt_idx, 1)    % case 1
                            revFrameIdx = iframe - 1;
                            lookBackPrevBestIdx = best{iframe}(idx);
                            while ott(last_tt_idx, 2) == 0
                                hasParentCandidate = best{revFrameIdx}(lookBackPrevBestIdx) > 0;
                                if hasParentCandidate
                                    parentPeakValue = peaks(best{revFrameIdx}(lookBackPrevBestIdx), revFrameIdx-1);
                                    prevPeakValue = peaks(find(peakidxs(:, revFrameIdx-1) == ofx(last_tt_idx)));
                                    if ((parentPeakValue >= prevPeakValue) && (parentPeakValue >= mean*PeakRejectRatio))
                                    % steal candidate
                                        if DEBUGFLAG
                                            plot(t(revFrameIdx-1), peakidxs(best{revFrameIdx}(lookBackPrevBestIdx), revFrameIdx-1), 'r*');
                                            plot([t(revFrameIdx-1) t(revFrameIdx)], ...
                                                [peakidxs(best{revFrameIdx}(lookBackPrevBestIdx), ...
                                                    revFrameIdx-1) peakidxs(lookBackPrevBestIdx, revFrameIdx)], 'b-');
                                        end
                                        ott(last_tt_idx+1, 2) = 0;
                                        ott(last_tt_idx, 2) = 1;
                                        ofx(last_tt_idx) = peakidxs(best{revFrameIdx}(lookBackPrevBestIdx), revFrameIdx-1);

                                        last_tt_idx = last_tt_idx - 1;
                                        lookBackPrevBestIdx = best{revFrameIdx}(lookBackPrevBestIdx);
                                        revFrameIdx = revFrameIdx - 1;
                                    else
                                        break;
                                    end
                                else
                                    break;
                                end
                            end
                        else
                            forwardIdxs = [best{iframe}(lastBest) lastBest];
                            goBackIdx = iframe-2;
                            doAdd = 0;
                            lb_lastBest = best{iframe-1}(forwardIdxs(1));
                            lastEnteredFrameIdx = 0;
                            while (goBackIdx > 0) && (goBackIdx >= (iframe-1 - LookBackLimitPts)) && lb_lastBest > 0
                                if peaks(lb_lastBest, goBackIdx) >= mean*PeakRejectRatioS2
                                    forwardIdxs = [lb_lastBest forwardIdxs];
                                    lb_lastBest = best{goBackIdx}(lb_lastBest);
                                else
                                    break;
                                end
                                if lb_lastBest <= 0
                                    break;
                                end
                                goBackIdx = goBackIdx - 1;
                                lastEnteredFrameIdx = fft_rapt_GetIndexIfEntered(t(goBackIdx), ott(1:last_tt_idx, 1));
                                if lastEnteredFrameIdx > 0 
                                    if ofx(lastEnteredFrameIdx) == peakidxs(lb_lastBest, goBackIdx)
                                        doAdd = 1;
                                        break;
                                    end
                                end
                            end
                            if doAdd
                                ofx = ofx(1:lastEnteredFrameIdx);
                                ott = ott(1:lastEnteredFrameIdx, :);
                                goBackIdx = goBackIdx + 1;
                                for lb_Idx=goBackIdx:iframe
                                    ott = [ott; t(lb_Idx) 0];
                                    ofx = [ofx; peakidxs(forwardIdxs(lb_Idx - goBackIdx + 1), lb_Idx)];
                                end
                            end
                        end
                    end
                end    % if newStart
                ofx = [ofx; peakidxs(idx, iframe)];
                ott = [ott; t(iframe) 0];
                if DEBUGFLAG
                    plot(t(iframe), peakidxs(idx, iframe), 'r*');
                end
            else
                lastBest = 0;
            end    % if (continues == 1)
        end    % if iframe > 1, beyond the first frame
        if lastBest == 0
        % If no best could be found for the current frame,
        % use the highest peak as the prevous best for the next frame.
            [maxv, maxi] = max(peakidxs(:, iframe));
            lastBest = maxi;
            newStart = 1;
        end
    else    % If no candidates(peaks) were available for the current frame
        lastBest = 0;
        newStart = 1;
    end
end    % Done actual backtracking

% perform contour smoothing
smoothing_filter = ones(smoothing_span, 1) / smoothing_span;
starts = [find(ott(:, 2)); size(ott, 1)+1];
tmpott = [];
tmpofx = [];
for seq=1:length(starts)-1
    if (ott(starts(seq+1)-1, 1) - ott(starts(seq), 1)) >= MinContourLength
        freqs = ofx(starts(seq):starts(seq+1)-1);
        if starts(seq+1)-starts(seq) >= smoothing_span
            freqs = convn(freqs, smoothing_filter, 'same');
            %endpoints remain as is, copy the rest
            ofx((starts(seq)+1):(starts(seq+1)-2)) = freqs(2:end-1);
        end
        if DEBUGFLAG
            plot(ott(starts(seq):starts(seq+1)-1, 1), ofx((starts(seq)):(starts(seq+1)-1)), 'mv-');
        end
        tmpott = [tmpott; ott((starts(seq)):(starts(seq+1)-1), :)];
        tmpofx = [tmpofx; ofx(starts(seq):starts(seq+1)-1)];
    end
end

% perform post-processing if needed
if DoPostProcessing && size(tmpott, 1)
    ott = tmpott; ofx = tmpofx;
    tmpott = zeros(0, 2); tmpofx = zeros(0, 1);
    time_incr = t(2) - t(1);
    starts = [find(ott(:, 2)); size(ott, 1)+1];
    for seq=1:length(starts)-1
        % copy current contour length as it is
        tmpott = [tmpott; ott(starts(seq):starts(seq+1)-1, :)];
        tmpofx = [tmpofx; ofx(starts(seq):starts(seq+1)-1)];
        if seq < length(starts)-1       % if not the last contour
            if ((ott(starts(seq+1)) - ott(starts(seq+1)-1) <= PPGap) && ...
                    fft_rapt_isinrange(ofx(starts(seq+1)-1), ofx(starts(seq+1)), freq_win, sweep_direction) == 1)
                % satisfies condition, fill in pseudo contour
                slope = time_incr * (ofx(starts(seq+1)) - ofx(starts(seq+1)-1)) / (ott(starts(seq+1)) - ott(starts(seq+1)-1));
                last_freq = ofx(starts(seq+1)-1);
                time_range = ott(starts(seq+1)-1):time_incr:ott(starts(seq+1))-time_incr;
                interim_ott = zeros(length(time_range), 2);
                interim_ofx = zeros(length(time_range), 1);
                for n=1:length(time_range)
                    interim_ott(n, 1) = time_range(n);
                    interim_ofx(n, 1) = last_freq;
                    last_freq = last_freq + slope;
                end
                if DEBUGFLAG
                    plot([interim_ott(:, 1); ott(starts(seq+1), 1)] , [interim_ofx; last_freq], 'm^-');
                end
                tmpott = [tmpott; interim_ott];
                tmpofx = [tmpofx; interim_ofx];
                ott(starts(seq+1), 2) = 0;
            end
        end
    end
end


if DEBUGFLAG
    hold off
else
    fx = tmpofx;
    tt = tmpott;
end


%===============================================================================
%                   fft_rapt_specgram
%===============================================================================
function [pwr, f, t] = fft_rapt_specgram(s, fs, nfft, overlap, minfreq, maxfreq)

%80 ms contains atleast two cycles of 30Hz signals
window = hanning(round(256 * fs/1000));
noverlap = round((overlap / 100) * length(window));

% calculate spectrogram plot (need signal toolbox)
[sg, f, t]=spectrogram(s, window, noverlap, nfft, fs);

sg = abs(sg);
%sg = sg - (sum(sum(sg)) / (size(sg, 1) * size(sg, 2)));

df = fs / nfft;
fimin = ceil(minfreq / df)+1;
fimax = ceil(maxfreq / df);
pwr = sg(fimin:fimax,:);
f = f(fimin:fimax);


%===============================================================================
%                   fft_rapt_isinrange
%===============================================================================
function x = fft_rapt_isinrange(first, second, limit, direction)
% tells if the given frequencies are in limited range

case1 = (first >= second && first-limit <= second);
case2 = (first <= second && first+limit >= second);
if direction == 'd' && case1
    x = 1;
elseif direction == 'u' && case2
    x = 1;
elseif direction == 'b' && (case1 || case2)
    x = 1;
else
    x = 0;
end


%===============================================================================
%                   fft_rapt_GetIndexIfEntered
%===============================================================================
function x = fft_rapt_GetIndexIfEntered(item, inlist)
% Returns the index of the item in the inlist,  Returns 0 if not present.

x = 0;
n = length(inlist);
while n > 0 && item < inlist(n)
    n = n - 1;
end
if item == inlist(n)
    x = n;
end


%===============================================================================
%                   fft_rapt_findpeaks
%===============================================================================
function [k,v]=fft_rapt_findpeaks(x,m,w)
%FINDPEAKS finds peaks with optional quadratic interpolation [K,V]=(X,M,W)
%
%  Inputs:  X        is the input signal
%           M        is mode:
%                       'q' performs quadratic interpolation
%                       'v' finds valleys instead of peaks
%           W        is the width tolerance; a peak will be eliminated if there is
%                    a higher peak within +-W samples
%
% Outputs:  K        are the peak locations in X (fractional if M='q')
%           V        are the peak amplitudes: if M='q' the amplitudes will be interpolated
%                    whereas if M~='q' then V=X(K). 

% Outputs are column vectors regardless of whether X is row or column.
% If there is a plateau rather than a sharp peak, the routine will place the
% peak in the centre of the plateau. When the W input argument is specified,
% the routine will eliminate the lower of any pair of peaks whose separation
% is <=W; if the peaks have exactly the same height, the second one will be eliminated.
% All peak locations satisfy 1<K<length(X).
%
% If no output arguments are specified, the results will be plotted.
%

%	   Copyright (C) Mike Brookes 2005
%      Version: $Id: dtFftRAPT.m,v 1.6 2007/11/02 07:16:24 shyam Exp $
%
%   VOICEBOX is a MATLAB toolbox for speech processing.
%   Home page: http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.html
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This program is free software; you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation; either version 2 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You can obtain a copy of the GNU General Public License from
%   http://www.gnu.org/copyleft/gpl.html or by writing to
%   Free Software Foundation, Inc.,675 Mass Ave, Cambridge, MA 02139, USA.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<2
    m=' ';
end
nx=length(x);
if any(m=='v')
    x=-x(:);        % invert x if searching for valleys
else
    x=x(:);        % force to be a column vector
end
dx=x(2:end)-x(1:end-1);
r=find(dx>0);
f=find(dx<0);

if length(r)>0 & length(f)>0    % we must have at least one rise and one fall
    dr=r;
    dr(2:end)=r(2:end)-r(1:end-1);
    rc=repmat(1,nx,1);
    rc(r+1)=1-dr;
    rc(1)=0;
    rs=cumsum(rc); % = time since the last rise

    df=f;
    df(2:end)=f(2:end)-f(1:end-1);
    fc=repmat(1,nx,1);
    fc(f+1)=1-df;
    fc(1)=0;
    fs=cumsum(fc); % = time since the last fall

    rp=repmat(-1,nx,1);
    rp([1; r+1])=[dr-1; nx-r(end)-1];
    rq=cumsum(rp);  % = time to the next rise

    fp=repmat(-1,nx,1);
    fp([1; f+1])=[df-1; nx-f(end)-1];
    fq=cumsum(fp); % = time to the next fall

    k=find((rs<fs) & (fq<rq) & (floor((fq-rs)/2)==0));   % the final term centres peaks within a plateau
    v=x(k);

    if any(m=='q')         % do quadratic interpolation
        b=0.5*(x(k+1)-x(k-1));
        a=x(k)-b-x(k-1);
        j=(a>0);            % j=0 on a plateau
        v(j)=x(k(j))+0.25*b(j).^2./a(j);
        k(j)=k(j)+0.5*b(j)./a(j);
        k(~j)=k(~j)+(fq(k(~j))-rs(k(~j)))/2;    % add 0.5 to k if plateau has an even width
    end

    % now purge nearby peaks

    if nargin>2
        j=find(k(2:end)-k(1:end-1)<=w);
        while any(j)
            j=j+(v(j)>=v(j+1));
            k(j)=[];
            v(j)=[];
            j=find(k(2:end)-k(1:end-1)<=w);
        end
    end
else
    k=[];
    v=[];
end
if any(m=='v')
    v=-v;    % invert peaks if searching for valleys
end
if ~nargout
    if any(m=='v')
        x=-x;    % re-invert x if searching for valleys
        ch='v';
    else
        ch='^';
    end
    plot(1:nx,x,'-',k,v,ch);
end

