function [SingleClicks, CompleteClicks, Noise, SNR] = dtHighResClick(...
    Fs, TeagerEnergy, Delay, Signal, FigureH, LRClickLength_s)
% [SingleClicks, GroupClicks, Noise] = dtHighResClick(Fs, TeagerEnergy, ...
%                Delay, Signal, FigureH, LRClickLength_s)
% Returns a set of starting and ending samples indicating
% the start and end times of each click.
% 
% Fs - sample rate
% TeagerEnergy - instantaneous sample energy
% Delay - Number of samples of delay in energy signal
% Signal - Original signal
% Duration_us - 
% FigureH - If not [], plot into figure pointed to by handle.
% LRClickLength_s - Length (in seconds) of single low freq click detection
%   Currently, we assume that this is reasonably short.  If it is longer
%   than the BlockSize constant (defined in the fn), this could be a
%   problem.
%
% Do not modify the following line, maintained by CVS
% $Id: dtHighResClick.m,v 1.16 2013/05/16 17:55:51 mroch Exp $
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 5
  FigureH = [];
end

if nargin <6
    LRClickLength_s = [];
end

% Tyack & Clark 2000 cite Au (1993) in Hearing by Whales & Dolphins, Au
% (ed.) stating that dolphins can distinguish clicks separated by as
% little as 205 us.
MinClickSeparation_us = 250;
MinClickSeparation_samples = ceil(Fs /1e6 * MinClickSeparation_us);

% Separation between peaks is dependent upon head size.  We've
% been observing that peaks are about 70-100 us for delphinids
% and place the gap at something under that.  As the energy does
% not fall off immediately, we don't need the full 70+ us.
MinGap_us = 50;
MinGap_samples = ceil(Fs/1e6 * MinGap_us);

% Minimum duration of a click in us.  
MinClick_us = 30;   % ? 20
MinClick_samples = ceil(Fs / 1e6 * MinClick_us);

MaxClick_us = 500;
MaxClick_samples =ceil(Fs /1e6 * MaxClick_us);


N = length(TeagerEnergy);

TeagerEnergy = abs(TeagerEnergy);       % half wave rectify

% Set up first block
% Set up analysis so it starts after Delay units have been passed
% or we will run into problems when shifting backwards to take
% any delay between the energy signal and the waveform.
Start = 1;
StartAnalysis = Start + Delay;
Stop = length(TeagerEnergy);

SingleClicks = [];
CompleteClicks=[];
Noise = [];



Range = Start:Stop;
SearchRange = StartAnalysis:Stop;
% Matlab's order statistics function prctile sorts all values
% first.  In theory, we can speed this up by using quick select
% but the overhead does not seem to be worth while when the array
% size is reasonably small (e.g. ~ 230 samples <-- 1200 us at 192 kHz).
NoiseFloor = prctile(TeagerEnergy, 40); % We seem to be picking up some
                                        % echos, may want to increase...
% NoiseFloor = stQuickSelect(TeagerEnergy, round(.4*length(TeagerEnergy)));
StartThreshold = 1.5 * NoiseFloor;
StopThreshold = 3 * NoiseFloor;
HighThreshold = 50 * NoiseFloor;

meanTeagerEnergy = stMA(TeagerEnergy, 11, 5);
CandidatesRel = find(meanTeagerEnergy(SearchRange) > HighThreshold) + Delay;

if ~ isempty(CandidatesRel)
    % Get noise
    NoiseStart = 1;
    CandidateIdx = 1;
    PrevCandidate = 0;
    while NoiseStart < CandidatesRel(end)
        NoiseStop = min(Stop, floor(CandidatesRel(CandidateIdx) ...
            - 0.5 * MaxClick_samples));

        if NoiseStop > NoiseStart + MinClick_samples
            Noise = [Noise; NoiseStart NoiseStop];
        end

        % take next noise start after possible click echo
        NoiseStart = CandidatesRel(CandidateIdx) + 2 * MaxClick_samples;

        while CandidateIdx < length(CandidatesRel) & ...
                (CandidatesRel(CandidateIdx)< NoiseStart | ...
                CandidatesRel(CandidateIdx) - .5*MaxClick_samples < ...
                PrevCandidate)
            NoiseStart = CandidatesRel(CandidateIdx) + 2 * MaxClick_samples;
            PrevCandidate = CandidatesRel(CandidateIdx);
            CandidateIdx = CandidateIdx+1;
        end
    end

    % Handle very last noise region
    if Stop - NoiseStart > MinClick_samples
        Noise = [Noise; NoiseStart Stop];
    end

    % For now, we may miss things that span blocks

    % Group candidates ----------------------------------------

    % dist to next high energy sample
    [s_starts, s_stops, durations] = spDurations(CandidatesRel, MinGap_samples);
    % find segments where high energy has a shorter duration than a click
    discards = find(durations <= MinClick_samples);
    s_starts(discards) = [];
    s_stops(discards) = [];
    durations(discards) = [];
    clear peaks
    c_starts = s_starts;        % init complete clicks to single/partial clicks 
    c_stops = s_stops;
    % Expand region to lower thresholds
    k=1;
    while k<=length(s_starts)
        range = s_starts(k):s_stops(k);

        if length(range) > 3
            [PeakList] = spPeakSelector(TeagerEnergy(range)); % 'RegressionOrder', 3, 'Threshold', 1);
        else
            PeakList = [];
        end
        % % Discard low quality peaks
        %PeakList = find(TeagerEnergy(range(PeakList)) >= HighThreshold);  
        if ~isempty(PeakList)
            [m, midx] = max(TeagerEnergy(range(PeakList)));
            LargePeakList = sort(find(TeagerEnergy(range(PeakList)) > .5*m));
            midx = range(PeakList(LargePeakList(1)));
            m = TeagerEnergy(midx);
            PeakPlot = 0;       % debugging use
            if PeakPlot
                figure(99)
                plot(range, TeagerEnergy(range), '.b-',midx, m, 'ro', ...
                    range(PeakList), TeagerEnergy(range(PeakList)), 'g*')
                pause
            end

            %Find first strong peak
            %[vals, sidx] = sort(TeagerEnergy(range), 'descend');
            %Using first 4 strongest values to find first peak, There's probably a better way
            %[m, midx] = sort(sidx(1:min(sidx(end), 4))); %max(TeagerEnergy(range));
            %midx = range(m(1));
            %midx = range(sidx(2));

            % Find left edge of click don't go past halfway to previous click
            if k == 1
                Leftmost = 2;
            else
                Leftmost = s_stops(k-1)+floor((s_starts(k)-s_stops(k-1))/2)+1;
            end
            SumEnergy = TeagerEnergy(midx);
            LeftIdx = midx - 1;
            while LeftIdx > Leftmost & TeagerEnergy(LeftIdx)/SumEnergy > .005
                %fprintf('TE(%d)=%f/Sum=%f = %f\n', LeftIdx, TeagerEnergy(LeftIdx), ...
                %SumEnergy, TeagerEnergy(LeftIdx)/SumEnergy);
                SumEnergy = SumEnergy + TeagerEnergy(LeftIdx);
                LeftIdx = LeftIdx - 1;
            end
            ltime = LeftIdx/Fs;

            %       % Adding bit about cumulative energy to see derivative approaching 0
            %       % for an exteneded period will help split clicks to obtain only
            %       % initial click and no reverberations
            %         CumEn=0;
            %         clear CumulativeEnergy
            %         for c=1:midx-LeftIdx+1
            %             CumEn = CumEn + TeagerEnergy(LeftIdx+c-1);
            %             CumulativeEnergy(c) = CumEn;
            %         end

            % Find right edge of click don't go past halfway to next click
            if k == length(s_starts)
                Rightmost = N;
            else
                Rightmost = s_stops(k)+floor((s_starts(k+1)-s_stops(k))/2);
            end
            SumEnergy = TeagerEnergy(midx);
            RightIdx = midx+1;
            while RightIdx <= Rightmost & TeagerEnergy(RightIdx)/SumEnergy > .005
                %fprintf('TE(%d)=%f/Sum=%f = %f\n', RightIdx, TeagerEnergy(RightIdx), ...
                %    SumEnergy, TeagerEnergy(RightIdx)/SumEnergy);
                SumEnergy = SumEnergy + TeagerEnergy(RightIdx);
                RightIdx = RightIdx+1;
                %             c=c+1;
                %             CumEn = CumEn + TeagerEnergy(LeftIdx+c-1);
                %             CumulativeEnergy(c) = CumEn;
            end

            %        %Ditto about Cumulative Energy bit - plot for debugging
            %         figure(1)
            %         plot(LeftIdx:LeftIdx+c-1, CumulativeEnergy)
            %         pause

            %rtime = RightIdx/Fs;

            s_starts(k) = LeftIdx;
            s_stops(k) = RightIdx;

            %Repeat for complete clicks using running mean of Teager Energy

            if k == 1
                Leftmost = 2;
            else
                Leftmost = c_stops(k-1)+floor((c_starts(k)-c_stops(k-1))/2)+1;
            end
            %mSumEnergy = meanTeagerEnergy(midx);
            LeftIdx = midx - 1;
            while LeftIdx > Leftmost & meanTeagerEnergy(LeftIdx) > StopThreshold
                %mSumEnergy = mSumEnergy + meanTeagerEnergy(LeftIdx);
                LeftIdx = LeftIdx - 1;
            end

            % Find right edge of click don't go past halfway to next click
            if k == length(c_starts)
                Rightmost = N;
            else
                Rightmost = c_stops(k)+floor((c_starts(k+1)-c_stops(k))/2);
            end
            %mSumEnergy = meanTeagerEnergy(midx);
            RightIdx = midx+1;
            while RightIdx < Rightmost && meanTeagerEnergy(RightIdx) > StopThreshold
                %mSumEnergy = mSumEnergy + meanTeagerEnergy(RightIdx);
                RightIdx = RightIdx+1;
            end
            c_starts(k) = LeftIdx;
            c_stops(k) = RightIdx;


            peaks(k) = max(TeagerEnergy(LeftIdx:RightIdx));

            %Discard short signals or those that run past end of signal
            if c_stops(k) >= N-2 | s_stops(k) - s_starts(k) < MinClick_samples
                s_starts(k) = [];
                s_stops(k) = [];
                c_starts(k) = [];
                c_stops(k) = [];
                durations(k) = [];
                peaks(k) = [];
            else
                k=k+1;
            end
        else
            s_starts(k) = [];
            s_stops(k) = [];
            c_starts(k) = [];
            c_stops(k) = [];
            durations(k) = [];
        end
    end
    SingleClicksRel = [s_starts, s_stops];
    CompleteClicksRel = [c_starts, c_stops];
    
    % Check for more clicks than expected
    if LRClickLength_s && ~ isempty(SingleClicksRel)
        NClick = ceil(((Stop-Start)/Fs)/LRClickLength_s);
        
        % identify groups of clicks
        % for each group, create an entry in a cell array which lists the
        % elements of the starts/stops/peaks array that are contained
        % within a specific group.
        groups = {};
        previous_group_start = 1;
        for idx=2:length(peaks);
            if c_starts(idx) - c_stops(idx - 1) > 2*MinClickSeparation_samples
                groups{end+1} = [previous_group_start:idx - 1];
                % new group
                previous_group_start = idx;
            end
        end
        groups{end+1} = [previous_group_start:length(peaks)]; % final group

        % Determine the largest peak within each group.
        for g = 1:length(groups)
            max_peaks(g) = max(peaks(groups{g}));   % largest peak each group
        end

        % find N largest peaks
        [SortedGroups, GroupIndex] = sort(max_peaks, 'descend');
        TargetGroups = sort(GroupIndex(1:min(NClick, length(SortedGroups))));

        % The strongest peak is not necessarily the first in a quick
        % series which may be caused by echoes either from being close
        % to the surface/bottom or due to echoes in the melon or the
        % tube which contains the hydrophone.  In any case, we pick
        % the first click with a "big" peak in the series.    

        SingleClicksRel = [];
        CompleteClicksRel = [];
        for g=TargetGroups
            LargePeaks = find(peaks(groups{g}) > .15*max_peaks(g));
            SingleClicksRel(end+1,:) = ...
                [s_starts(groups{g}(LargePeaks(1))), s_stops(groups{g}(LargePeaks(1)))];
            CompleteClicksRel(end+1,:) = ...
                [c_starts(groups{g}(LargePeaks(1))), c_stops(groups{g}(LargePeaks(1)))];
        end
    end

   
    % Compute indices relative to whole signal (-1 due to Teager op delay)
    CandidatesAbs = CandidatesRel + Start - 1;
    SingleClicks = SingleClicksRel + Start - 1;
    CompleteClicks = CompleteClicksRel + Start - 1;
   

    % extend clicks to nearest zero crossing
    DCoffset = mean(Signal);
    if ~ isempty(SingleClicks)
        for c = 1:size(SingleClicks,1)
            Front = SingleClicks(c,1);
            Rear = SingleClicks(c,2);

            Sign = Signal(Front)-DCoffset;
            if Sign > 0
                while Signal(Front) > DCoffset & Front > 1
                    Front = Front - 1;
                end
            else
                while Signal(Front) < DCoffset & Front > 1
                    Front = Front - 1;
                end
            end
            Sign = Signal(Rear) - DCoffset;
            if Sign > 0
                while Signal(Rear) > DCoffset & Rear < N
                    Rear = Rear + 1;
                end
            else
                while Signal(Rear) < DCoffset & Rear < N
                    Rear = Rear + 1;
                end
            end
            % Pick sample closest to zero crossing
            [FrontSample, FrontIdx] = min(abs(Signal(Front:Front+1)-DCoffset));
            Front = Front + FrontIdx - 1;  % If Front+1 closest, move forward
            [RearSample, RearIdx] = min(abs(Signal(Rear-1:Rear)-DCoffset));
            Rear = Rear + RearIdx - 2;   % If Rear smaller dist, leave alone, else move forward
            SingleClicks(c,:) = [Front, Rear];
        end
        %attempt to deal with zero crossings in "cheating" way
        %CompleteClicks(:,1) = min([CompleteClicks(:,1), SingleClicks(:,1)],[],2);
        %CompleteClicks(:,2) = max([CompleteClicks(:,2), SingleClicks(:,2)],[],2);
    end
    
    %Display = 1;
    if ~ isempty(FigureH)
        t = Range/Fs;
        figure(FigureH);   % bring plot to front
        ax(1) = subplot(2,1,1);
        if ~ isempty(SingleClicks)
            plot(t, Signal(Range), t(CandidatesRel - Delay), Signal(CandidatesAbs ...
                - Delay), '.',    ... %'MarkerSize', 12,
                t(SingleClicks(:, [1 1])' - ones(size(SingleClicks))'*Delay), ...
                [min(Signal(Range)), max(Signal(Range))]'*ones(1,size(SingleClicks,1)), 'k:', ...
                t(SingleClicks(:, [2 2])' - ones(size(SingleClicks))'*Delay), ...
                [min(Signal(Range)), max(Signal(Range))]'*ones(1,size(SingleClicks,1)), 'k:',...
                t(CompleteClicks(:, [1 1])' - ones(size(CompleteClicks))'*Delay), ...
                [min(Signal(Range)), max(Signal(Range))]'*ones(1,size(CompleteClicks,1)), 'k-', ...
                t(CompleteClicks(:, [2 2])' - ones(size(CompleteClicks))'*Delay), ...
                [min(Signal(Range)), max(Signal(Range))]'*ones(1,size(CompleteClicks,1)), 'k-');
%                 t(SingleClicks' - Delay), Signal(SingleClicks(:, [1 1]) ...
%                 - Delay)', 'p-');
            hold on;
            for knoise = 1:size(Noise, 1);
                plot(t(Noise(knoise,1):Noise(knoise,2)), ...
                    mean(Signal(Range))*ones(diff(Noise(knoise,:))+1,1), ...
                    'c:');
            end
        else
            plot(t, Signal(Range));
        end
        ax(2) = subplot(2,1,2);
        title('Waveform')
        ylabel('Amplitude')
        xlabel('Time s.')

        if ~ isempty(SingleClicks)
            plot(t, TeagerEnergy(Range), ...
                t(CandidatesRel), TeagerEnergy(CandidatesAbs), '.', ...
                t, StartThreshold(ones(size(t))), 'g:', ...
                t, StopThreshold(ones(size(t))), 'c:', ...
                t, meanTeagerEnergy, 'r', ...
                t(SingleClicks(:, [1 1]))', [min(TeagerEnergy(Range)), ...
                    max(TeagerEnergy(Range))]'*ones(1,size(SingleClicks,1)), 'k:', ...
                t(SingleClicks(:, [2 2]))', [min(TeagerEnergy(Range)), ...
                    max(TeagerEnergy(Range))]'*ones(1,size(SingleClicks,1)), 'k:',...
                t(CompleteClicks(:, [1 1]))', [min(TeagerEnergy(Range)), ...
                    max(TeagerEnergy(Range))]'*ones(1,size(CompleteClicks,1)), 'k-', ...
                t(CompleteClicks(:, [2 2]))',[min(TeagerEnergy(Range)),...
                    max(TeagerEnergy(Range))]'*ones(1,size(CompleteClicks,1)), 'k-');
%                 t(SingleClicks'), TeagerEnergy(SingleClicks(:, [1 1]))', 'p-', ...
%                 t(CompleteClicks'), TeagerEnergy(CompleteClicks(:, [1 ...
%                 1]))', 'v-');
                
        else
            plot(t, TeagerEnergy(Range));
        end
        if ~isempty(SingleClicks) & LRClickLength_s
            % plot out groups
            hold on
            for g=1:length(groups)
                time = t(c_starts(groups{g}(1)):c_stops(groups{g}(end)));
                plot(time, ones(size(time))*max_peaks(g)*1.1, 'r-');
            end
        end
        hold(ax(1), 'off');
        hold(ax(2), 'off');
        title('Energy')
        xlabel('Time s.')
        ylabel('Teager Energy')
        linkaxes(ax, 'x');

        fprintf('SingleClicks %d Start %d StartAnalysis %d Stop %d\n', size(SingleClicks, 1), ...
            Start, StartAnalysis, Stop);
        dbg = input('Action:  d - debug, q - quit, else continue:  ', 's');
        if ~ isempty(dbg)
            if strcmp(dbg, 'd')
                keyboard
            elseif strcmp(dbg, 'q')
                return
            end
        end
        
    end
    
    if Delay
        SingleClicks = SingleClicks - Delay;    % account for filtering delay provided by user
        CompleteClicks = CompleteClicks - Delay;
    end
end

if ~ isempty(CompleteClicks)
    SNR = zeros(1, size(CompleteClicks, 1));
    mednoise = median(abs(Signal));
    for ksnr = 1:length(SNR)
        SNR(ksnr) = 20*log10(...
            max(abs(Signal(CompleteClicks(ksnr,1):CompleteClicks(ksnr,2)))) / mednoise);
    end
else
    SNR = [];
end


  



