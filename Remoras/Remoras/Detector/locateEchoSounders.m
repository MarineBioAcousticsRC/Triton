function Clicks_To_Delete_ret = locateEchoSounders...
	(Click_Pos_Sec, orig_Fs, data, start_sec, Plot_info)
% function Clicks_To_Delete_ret = locateEchoSounders...
%	(Click_Pos_Sec, hdr, data, start_sec, Plot_info)
%
%		Given the indicies of possible clicks, figure out which ones are
%		most likely to be echo sounders based on the distance all clicks
%		are from all other clicks. IE - if there seem to be clicks at each
%		1 second interval starting at second 5.2, among other clicks, those
%		are likely to be sonar pings. It may be that there are no sonar
%		pings in the recording, in which case the correlation would not
%		exceed the threshold and no clicks would be removed.
%
%	Input:
%		Click_Pos_Sec	- Possitions of possible clicks in seconds from the
%						  start of the file
%		orig_Fs			- File sample rate
%		data			- WAV data; used for plotting
%		start_sec		- Second relative the the beggining of the file
%		Plot_info		- Debugging information
%
%	Output:
%		Click_to_Delete_ret		- The click numbers of the possible echo
%								  sounders
%

% ---- Variable Setup
Plot = Plot_info.Plot;
pingH = Plot_info.pingH;
perH = Plot_info.perH;
remH = Plot_info.remH;


Clicks_To_Delete_ret = [];
Fs = 2000;
FFT = 500;
Corr_percentile = 0.95;
Corr_multi = .5;
pwr_percentile = 0.95;
pwr_multi = 2;
LagRange = Fs*3; % 3s shifts
remove_start_per = 0.05;
Remove_First_Indicies = floor(LagRange*remove_start_per);
min_samps = ceil(Fs/1e6 * 2000);
CLICK_PADDING = 500*1e-3*Fs;	% ms -> idx

LENGTH_OF_SEGMENT_s = length(data)/orig_Fs;
total_num_samples = ceil(LENGTH_OF_SEGMENT_s*Fs);

timeseries = zeros(total_num_samples, 1);

% ---- Convert click start times to samples
indices = round(Click_Pos_Sec *Fs)+1; 

% ---- Setup Click location bits
for idx = 1:size(indices, 1)
	timeseries(indices(idx,1):indices(idx,2)) = 1;
end

% ---- Setup correlation
ac = xcorr(timeseries, LagRange);

% Positive half, smoothed
ac_pos = ac(ceil(length(ac)/2):end);

% Seconds for each sample up to 3 seconds
x_times = linspace(0,3,length(ac_pos));

% The first few indicies are removed because they have no relevant data and
% may effect the thresholds
ac_pos = ac_pos(Remove_First_Indicies:end);
x_times = x_times(Remove_First_Indicies:end);

ac_sorted = sort(ac_pos);
threshold = Corr_multi*ac_sorted(round(length(ac_sorted)*Corr_percentile));


% ---- Find Correlation Times
indx_over_thresh = find(ac_pos >= threshold);
if isempty(indx_over_thresh) 
	return;
end
[starts, stops, durations] = spDurations(indx_over_thresh, min_samps);
discards = durations < min_samps;
starts(discards) = [];
stops(discards) = [];
durations(discards) = [];

peak_vals = zeros(length(durations),1);
peaks = zeros(length(durations),1);
for i=1:length(durations)
	[peak_vals(i) peaks(i)] = ...
		max(ac_pos(starts(i):stops(i),:));
	peaks(i) = starts(i) + peaks(i) - 1;
end

% ---- Removing duplicate peaks and those less than 0.4s
%	Duplicates are only looked for at 2 or 3 times
discard = zeros(length(peaks),1);
for i=1:length(peaks)
	discard(i) = i* (x_times(peaks(i)) < 0.4 || ~isempty(...
		find( round(x_times(peaks)*2 *100) == round(x_times(peaks(i)) *100) | ...
			  round(x_times(peaks)*3 *100) == round(x_times(peaks(i)) *100), 1)));
end
discard(discard==0)=[];
peaks(discard)=[];
peak_vals(discard)=[];

if isempty(peaks)
	return;
end

% ---- Displaying correlation information
if Plot > 2
	figure(pingH); 
	subplot(perH);
	plot(x_times, ac_pos); hold all;
	plot([x_times(1) x_times(end)],[threshold threshold], '-c');
	
	plot(x_times(indx_over_thresh),ac_pos(indx_over_thresh), '*g');
	plot(x_times(peaks),peak_vals,'xk', 'MarkerSize', 10, 'LineWidth', 2);
	
% 	axis tight;
	legend('Cross-correlation of click possitions', 'Threshold', ...
		'Indexes above threshold', 'Possible peaks');
	title('Cross-correlation of detected clicks looking for Echo-sounders');
	xlabel('Space between echos (s)');
	ylabel('Level of correlation');
	hold off;

	fprintf('Period of possible echo sounder is approximately ');
	fprintf('%.4fs ', x_times(peaks));
	fprintf('\n');
end
% ---- Investigate all possible time intervales (there may be more than one)

Clicks_To_Delete_ret = [];
for peak_idx = peaks'
	peak_sec = x_times(peak_idx);
	index_length_of_peak = ceil(peak_sec*Fs);
	
	% Split the timeseries into chunks of the size of the current
	% recurrance being tested for. Each ping from the echo sounder will be
	% at the same relative position in each chunk and summing all the
	% chunks will give us the appropriate starting value.
	height_reshape = ceil(length(timeseries)/index_length_of_peak);
	timeseries(length(timeseries)+1:height_reshape*index_length_of_peak) = 0;
	reshaped_matrix_of_ping_indexes = reshape(timeseries, index_length_of_peak, height_reshape);
	pwr = sum(reshaped_matrix_of_ping_indexes, 2);
	timeseries(total_num_samples+1:end) = [];
	
	% ---- Find the seconds that mark the ping intervals
	%  May be multiple pings with the same interval
	%  OR echos of the pings (which may be picked up)

	pwr_sorted = sort(pwr);
	pwr_thresh = pwr_multi*pwr_sorted(round(length(pwr)*pwr_percentile));
	pwr_over_thresh_idx = find(pwr > pwr_thresh);

	if isempty(pwr_over_thresh_idx)
		continue;
	end
	
	[p_str p_stp durations] = spDurations(pwr_over_thresh_idx, min_samps);
	discard = find(durations < min_samps);
	p_str(discard) = [];
	p_stp(discard) = [];

	% Index of each peak, indicating the starting time of repetition
	pwr_peaks = zeros(length(p_str),1);
	for i=1:length(p_str)
		[~, pwr_peaks(i)] = max(pwr(p_str(i):p_stp(i)));
		pwr_peaks(i) = p_str(i) + pwr_peaks(i) - 1;
	end

	Clicks_To_Delete = cell(size(pwr_peaks,1),1);
	for j = 1:size(pwr_peaks,1)
		First_Ping_s = pwr_peaks(j)/Fs;

		repeat_s = First_Ping_s:peak_sec:LENGTH_OF_SEGMENT_s;
		repeat_idx = zeros(total_num_samples,1);
		repeat_idx(round(repeat_s*Fs)) = 1;
		repeat_idx(total_num_samples+1:end) = [];

		pings_del_idx = find((timeseries & repeat_idx)>0);
		for i=1:length(pings_del_idx)
			Clicks_To_Delete{j} = [Clicks_To_Delete{j}; ...
				find(indices(:,1)-CLICK_PADDING <= pings_del_idx(i) & ...
					 indices(:,2)+CLICK_PADDING >= pings_del_idx(i))];
		end
	end
	Clicks_To_Delete_ret = [Clicks_To_Delete_ret; unique(cell2mat(Clicks_To_Delete))];
end
Clicks_To_Delete_ret = unique(Clicks_To_Delete_ret);

if Plot > 2
	[~,F,T,P] = spectrogram(data, hamming(FFT), 50, FFT, orig_Fs);

	figure(pingH);
	subplot(remH);
	surf(T+start_sec,F/1000,10*log10(P),'edgecolor','none');hold all;
	plot3(Click_Pos_Sec(:,1)+start_sec, ...
		  50*ones(size(Click_Pos_Sec,1)), ...
		  max(max(P))*ones(size(Click_Pos_Sec,1)), ...
		  'ok');
	
	if Clicks_To_Delete_ret
		plot3(Click_Pos_Sec(Clicks_To_Delete_ret,1)+start_sec, ...
			  50*ones(size(Clicks_To_Delete_ret,1)), ...
			  max(max(P))*ones(size(Clicks_To_Delete_ret,1)), ...
			  '*r');
	end
	
	surviving_idx = ones(length(Click_Pos_Sec),1);
	surviving_idx(Clicks_To_Delete_ret) = 0;
	surviving_idx = find(surviving_idx);
	surviving_clicks = Click_Pos_Sec(surviving_idx,1)+start_sec;
	for t=1:length(surviving_clicks)
		line([surviving_clicks(t) surviving_clicks(t)], [5 92], 'Color','b'); 
	end
	
	axis tight; colormap(jet); view(2);
	ylim([5 92]);
	xlabel('Time (s)'); ylabel('Frequency kHz');
	title('Possition of clicks in file and those marked for removal');

	hold off;
	
	fprintf('Removing clicks: ');
	fprintf('%i ', Clicks_To_Delete_ret);
	fprintf('\n');
	
	fprintf('Keeping clicks: ');
	fprintf('%i ', surviving_idx);
	fprintf('\n');
	
	next = input('Enter to continue, # to debug: ');
	if ~isempty(next)
		keyboard
	end
end
