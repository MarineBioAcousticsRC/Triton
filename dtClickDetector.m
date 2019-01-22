function [CompleteClicks, Noise] = ...
	dtClickDetector(Fs, TeagerEnergy, Delay, Signal, LRClickLength_s, constraints)
% function [CompleteClicks, Noise, SNR] = ...
%	dtClickDetector(Fs, TeagerEnergy, Delay, Signal, LRClickLength_s, constraints)
%
%		Receives the timeseries data and teager energy of a recording and
%		determines the start and stop times of possible clicks and areas of
%		pure noise. Parts of the teager energy that exceed a threshold are
%		thought to have an appropriate amount of energy to represent a
%		click. These areas are grown to encompass an entire click. Noise is
%		evaluated as values that fall under another threshold. Things that
%		exceed the noise threshold but do not exceed the click threshold
%		are ignored.
%
%	Input:
%		Fs              - File sample rate
%		TeagerEnergy    - Teager energy
%		Delay           - Delay in signal (if needed)
%		Signal          - Timeseries data
%		LRClickLength_s - Acceptable click length ! (Change name?)
%		constraints     - various constraints for a click (size, seperation, etc)
%
%	Output:
%		CompleteClicks - Start/stop indicies of possible clicks
%		Noise          - Start/stop indicies of areas of noise

MinClickSeparation_us=constraints.MinClickSeparation_us;
MinGap_us=constraints.MinGap_us; 
FrameLength_samples=constraints.FrameLength_samples;

MinClickSeparation_samples = ceil(Fs * MinClickSeparation_us/1e6);
MinGap_samples = ceil(Fs/1e6 * MinGap_us);
MinNoise_samples = FrameLength_samples;

N = length(TeagerEnergy);
TeagerEnergy = abs(TeagerEnergy);       % half wave rectify

Start = 1;
StartAnalysis = Start + Delay;
Stop = N;

CompleteClicks=[];
1;

SearchRange = StartAnalysis:Stop;
sorted_Teager = sort(TeagerEnergy);				% Sort to get percentiles
meanTeagerEnergy = stMA(TeagerEnergy, 11, 5);	% Get the moving average

Click_per = 0.95;		% Clicks must pass the threshold of 
High_mul = 5;			%  x higher than 95% of the teager energy
% Click_per = 0.4;
% High_mul = 50;

Noise_per = 0.6;		% Noise needs to fall under 
Noise_mul = 4;			%  x higher than 60% of the teager energy

Stop_per = 0.5;			% Both clicks and "not noise" stop at
Stop_mul = 2;			%  x higher than 60% of the teager energy
% Stop_per = 0.4;
% Stop_mul = 3;

HighThreshold = High_mul * sorted_Teager(ceil(N*Click_per));
StopThreshold = Stop_mul * sorted_Teager(ceil(N*Stop_per));

NoiseThreshold = Noise_mul * sorted_Teager(ceil(N*Noise_per));

% Debugging Plot
% --------------
% figure(9); 
% ln = probplot(TeagerEnergy);
% set(ln(1),'color','g');
% set(ln(2),'Visible','off');
% hasbehavior(ln(2), 'legend', false);
% hold all;
% plot([1 1]*HighThreshold, [-5 5], '-b');
% % plot([1 1]*NoiseThreshold, [-5 5], '-g');
% % plot([1 1]*StopThreshold, [-5 5], '--r');
% plot([1 1]*sorted_Teager(ceil(N*Click_per)), [-5 5], '--b');
% xlim('auto');%[0 2.2e5]);
% xlabel('Teager Energy t');
% ylabel('Probability T <= t');
% legend('Cumulative Distribution','Click Threshold','Noise Threshold','Stop Threshold');


% Find the indicies that may be clicks and those that may be noise
CandidatesRel = find(meanTeagerEnergy(SearchRange) > HighThreshold) + Delay;
CandidatesNoise = find(meanTeagerEnergy(SearchRange) <= NoiseThreshold); 

% Debugging Plot
% --------------
% figure(10); 
% % ax(1) = subplot(2,1,1);
% % plot((1:length(Signal))/Fs,Signal);
% % xlabel('Time in file (s)');
% % ylabel('Amplitude');
% % ax(2) = subplot(2,1,2);
% plot((1:length(meanTeagerEnergy))/Fs, meanTeagerEnergy); hold all; 
% plot([0 N/Fs],[1 1]*HighThreshold,'-r');
% plot([0 N/Fs],[1 1]*NoiseThreshold,'-g');
% plot([0 N/Fs],[1 1]*StopThreshold,'--r');
% % plot([1 N], [1 1]*sorted_Teager(ceil(N*.4))*50, '-k');
% % plot([1 N], [1 1]*sorted_Teager(ceil(N*.4))*3, '--k');
% ylim([0 max(HighThreshold)*1.1]);
% xlabel('Time in file (s)');
% ylabel('Teager Energy');
% % linkaxes(ax,'x');
% legend('mean energy','HighThreshold', 'NoiseThreshold',...
% 	'StopThreshold','50*40%', '3*40%'); hold off;

% Grow the Noise indicies until they are under the stopping threshold
if length(CandidatesNoise) < length(meanTeagerEnergy)
	[n_starts, n_stops, ~] = spDurations(CandidatesNoise, 1);
	
	% Left side
	for i = 1:length(n_starts)
		curr = n_starts(i);
		while curr < length(meanTeagerEnergy) && ...
				curr < n_stops(i) - MinNoise_samples-1 &&...
				meanTeagerEnergy(curr) > StopThreshold
			curr = curr + 1;
		end
		n_starts(i) = curr;
	end
	
	% Right side
	for i = 1:length(n_stops)
		curr = n_stops(i);
		while curr > 1 && ...
				curr > n_starts(i) + MinNoise_samples-1 && ...
				meanTeagerEnergy(curr) > StopThreshold
			curr = curr - 1;
		end
		n_stops(i) = curr;
	end
	
	discards = n_stops - n_starts < MinNoise_samples;
	n_starts(discards) = [];
	n_stops(discards) = [];
	
	Noise = [n_starts, n_stops];
else
	Noise = [1 length(Signal)];
end

% Debugging Plot
% --------------
% figure(10); hold on;
% for i=1:size(Noise,1); plot(Noise(i,1):Noise(i,2),meanTeagerEnergy(Noise(i,1):Noise(i,2)), '-c'); end;
% hold off;

if ~ isempty(CandidatesRel)
    % dist to next high energy sample
    [c_starts, c_stops, ~] = spDurations(CandidatesRel, MinGap_samples);
% Grow the Click indicies until they are under the stopping threshold
    k=1;
    peaks = zeros(length(c_starts),1);
    while k<=length(c_starts)
        range = c_starts(k):c_stops(k);

		if length(range) > 3
			[PeakList] = spPeakSelector(TeagerEnergy(range));
		else
			PeakList = [];
		end
        
		% Check for a peak value
        if ~isempty(PeakList)
            [m, ~] = max(TeagerEnergy(range(PeakList)));
            LargePeakList = sort(find(TeagerEnergy(range(PeakList)) > .5*m));
            midx = range(PeakList(LargePeakList(1)));
            
            % Left side
            if k == 1
                Leftmost = 2;
            else
                Leftmost = c_stops(k-1)+floor((c_starts(k)-c_stops(k-1))/2)+1;
            end
            LeftIdx = midx - 1;
            while LeftIdx > Leftmost && meanTeagerEnergy(LeftIdx) > StopThreshold
                LeftIdx = LeftIdx - 1;
            end

            % Right side
            if k == length(c_starts)
                Rightmost = N;
            else
                Rightmost = c_stops(k)+floor((c_starts(k+1)-c_stops(k))/2);
            end
            RightIdx = midx+1;
            while RightIdx < Rightmost && meanTeagerEnergy(RightIdx) > StopThreshold
                RightIdx = RightIdx+1;
            end
            c_starts(k) = LeftIdx;
            c_stops(k) = RightIdx;

            peaks(k) = max(TeagerEnergy(LeftIdx:RightIdx));
            
            % Discard short signals or those that run past end of signal
            if c_stops(k) >= N-2
                c_starts(k) = [];
                c_stops(k) = [];
                peaks(k) = [];
            else
                k=k+1;
            end
        else
            c_starts(k) = [];
            c_stops(k) = [];
            peaks(k) = [];
        end
    end
   
    CompleteClicksRel = [c_starts, c_stops];
 % Check for more clicks than expected; ie too close to each other
	if LRClickLength_s && ~isempty(CompleteClicksRel)
		NClick = ceil(((Stop-Start)/Fs)/LRClickLength_s);

		% identify groups of clicks
		% for each group, create an entry in a cell array which lists the
		% elements of the starts/stops/peaks array that are contained
		% within a specific group.
		groups = {};
		previous_group_start = 1;
		for idx=2:length(peaks);
			if c_starts(idx) - c_stops(idx - 1) > 2*MinClickSeparation_samples
				groups{end+1} = previous_group_start:(idx - 1);
				% new group
				previous_group_start = idx;
			end
		end
		groups{end+1} = previous_group_start:length(peaks); % final group

		% Determine the largest peak within each group.
		max_peaks = zeros(length(groups),1);
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

		CompleteClicksRel = [];
		for g=TargetGroups'
			LargePeaks = find(peaks(groups{g}) > .15*max_peaks(g));
			CompleteClicksRel(end+1,:) = ...
				[c_starts(groups{g}(LargePeaks(1))), c_stops(groups{g}(LargePeaks(1)))];
		end
	end
    
    CompleteClicks = CompleteClicksRel + Start - 1;
    
    if Delay
        CompleteClicks = CompleteClicks - Delay;
    end
end

end
