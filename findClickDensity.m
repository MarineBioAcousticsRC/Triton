function NoiseGroups = findClickDensity(Noise_Indx, Click_Indx, lng, fs, max_s, min_s)
% function NoiseGroups = findClickDensity(Noise_Indx, Click_Indx, lng, fs, max_s, min_s)
% 
%	Find areas of noise that occur in times of few clicks. It should turn
%	out that large occurances of clicks have a noise group before and after
%	it that contains a good estimation of the relative noise floor.
%
%	Input:
%		Noise_Indx  - The start/stop indicies of noise areas
%		Click_Indx	- The start/stop indicies of possible clicks
%		lng			- Number of incidies total being processed; used to
%					  evaluate from the last click to the end of the
%					  recording
%		fs			- File sample rate
%		max_s		- Maximum number of seconds in a block of noise
%						too long takes unneccessary computation time
%		min_s		- Minimum number of seconds in a block of noise
%						too short is unreliable
%
%	Output:
%		NoiseGroups - Start/Stop indicies of each group of noise areas;
%					  IE- Group 1: 1-3, Group 2: 4-29 ...

	% Get the difference between the end of a previous click and the start
	% of the next, including the start and end of the "file"
	diffs = [Click_Indx(:,1); lng] - [1; Click_Indx(:,2)];

	% Sort all the values to determine the 3 * 90% threshold
	sorted_diffs = sort(diffs);
	threshold = sorted_diffs(round(length(sorted_diffs)*.9));

	% Determine the spaces that have a sufficiently small number of clicks;
	% if there are not such groups, designate the entire file to be broken
	% up later
	chunks = find(diffs >= threshold);
	if isempty(chunks) || length(chunks) < 2
		st = 1; sp = length(Click_Indx);
	else
		[st, sp, dur] = spDurations(chunks, 1);
	end
	
	% Grow the group boundaries until the distance between clicks is less
	% than half the threshold. Need to ensure there is no overlapping by
	% using the "unique" function
	for i = 1:length(st)
		while diffs(st(i)) > threshold/2 && st(i) > 1
			st(i) = st(i) - 1;
		end
		while diffs(sp(i)) > threshold/2 && sp(i) < length(Click_Indx)
			sp(i) = sp(i) + 1;
		end
	end
	[~, unq_c] = unique([st,sp],'rows');
	[~, unq_t] = unique(st);
	[~, unq_s] = unique(sp);
	unq = intersect(unq_c, intersect(unq_t, unq_s));
	st = st(unq);
	sp = sp(unq);
	
	% Find the nearest noise that mark the start and stop of each
	% "click-less" area, special attention given to the first and last.
	% Assure there are no blanks before converting to arrays
	st_noise = cell(length(st),1);
	sp_noise = cell(length(st),1);
	for i=1:length(st)
		st_noise{i} = find(Noise_Indx(:,1) >= Click_Indx(st(i)), 1, 'first');
		sp_noise{i} = find(Noise_Indx(:,2) <= Click_Indx(sp(i)), 1, 'last');
	end
	st_noise(st==1) = {1};
	sp_noise(sp > length(Click_Indx)) = {size(Noise_Indx,1)};
	
	to_remove = cellfun('isempty', st_noise) | cellfun('isempty', sp_noise);
	st_noise(to_remove) = [];
	sp_noise(to_remove) = [];

	st_noise = cell2mat(st_noise);
	sp_noise = cell2mat(sp_noise);
	
	if isempty(st_noise)
		st_noise = 1;
		sp_noise = size(Noise_Indx,1);
	end
	
	% Check noise blocks for size. If larger than the maximum allowed
	% seconds 'max_s', split in half until small enough.
	%	Also remove noise blocks that are too small -- less than min_s
	i=1;
	while i <= length(st_noise)
		if (Noise_Indx(sp_noise(i),2) - Noise_Indx(st_noise(i),1))/fs > max_s
			j = st_noise(i) + 1;
			if j < length(Noise_Indx)
				while (Noise_Indx(j,2) - Noise_Indx(st_noise(i),1))/fs < max_s
					j = j+1;
				end
				st_noise = [st_noise(1:i); ...
								j; ...
								st_noise(i+1:end)];
				sp_noise = [sp_noise(1:i-1); ...
								j-1; ...
								sp_noise(i:end)];
			end
		elseif (Noise_Indx(sp_noise(i),2) - Noise_Indx(st_noise(i),1))/fs < min_s
			sp_noise(i)=[];
			st_noise(i)=[];
			i=i-1;
		end
		i = i+1;
	end
	
	% Remove noise blocks that wouldn't be used-- i.e. those that do not
	% have clicks either within them or within their neighboring blocks.
	sec_len = (Noise_Indx(sp_noise,2) - Noise_Indx(st_noise,1))/fs;
	toremove = zeros(length(st_noise),1);
	
	if max(sec_len) < min_s
		min_s = 0;
	end
	
	for i=1:length(st_noise)
		prev = i;%max(1, i-1);
		next = min(i+1, length(st_noise));
		
		found_clicks = find(Click_Indx(:,2) <= Noise_Indx(sp_noise(next),2) &...
							Click_Indx(:,1) >= Noise_Indx(st_noise(prev),1), 1);
		
		if isempty(found_clicks) || sec_len(i) < min_s
			toremove(i) = i;
		end
	end
	toremove(toremove==0)=[];
	st_noise(toremove) = [];
	sp_noise(toremove) = [];
	
	NoiseGroups = [st_noise,sp_noise];

% Debugging Plot
% --------------
% 	figure; plot([0 0]); hold all; xlim([1 lng/fs]);
% 	for i=1:length(Click_Indx)
% 		line([1 1]*Click_Indx(i,1)/fs, [0 1], 'Color', 'cyan');
% 	end
% 	for i=1:length(st_noise)
% 		line([1 1]*Noise_Indx(st_noise(i),1)/fs, [0 1], 'Color', 'blue');
% 		line([1 1]*Noise_Indx(sp_noise(i),2)/fs, [0 1], 'Color', 'magenta');
% 		
% 		line([Noise_Indx(st_noise(i),1)/fs Noise_Indx(sp_noise(i),2)/fs],...
% 			 [1 1]*(i/length(st_noise)*0.8 + 0.1),'Color','black');
% 	end
% 	xlabel('seconds in file');
	
end