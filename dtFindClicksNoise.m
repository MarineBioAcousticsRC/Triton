function [Absolute_Click_Indx ClickSeconds ...
		  Noise_Group_Indx Noise_Group_Averages...
          Click_WAV_data Click_Teager_data ...
          Sonar_Pings Clicks_to_reject] = ...
    dtFindClicksNoise(fid, hdr, channel, FileType, DataFile, LabelFile, constraints, Plot_info,...
					  window, SpecRange, AdjustedTransferFunction, SaveNoise)
% function [...] = dtFindClicksNoise(...)
%
%	Split up each file into appropriatly sized chunks for processing. For
%	each chunk, apply a High Pass Filter to the data to get the Teager
%	energy (use the HPF data for nothing else) and pass the data into
%	dtClickDetector to get the indicies of possible clicks and areas of
%	pure noise. Reject echo sounder pings with locateEchoSounder. Group
%	together noise areas to avoid using areas that are possibly
%	contaminated by large numbers of clicks around it. Normally, the
%	dolphin clicks are together; so by averaging the noise before and after
%	groups of clicks to an acceptable length, we can find a resonable noise
%	floor.
%
%	Input:
%		fid                      - ID of open WAV/XWAV file
%		hdr                      - File header information
%		channel                  - Channel recording is on
%		FileType                 - WAV or XWAV
%		DataFile                 - File name
%		constraints              - various click restraints
%			ClipThreshold
%			MinClickSeparation_us
%			MinGap_us
%			MinClick_us
%			MaxClick_us
%			FrameLength_samples
%			HPFilter
%			Noise_Buffer_Max_s
%			Noise_Buffer_Min_s
%		Plot_info                - Debugging info
%		window                   - for use with DFT
%		SpecRange                - Range of frequencies we care about
%		AdjustedTransferFunction - PreAmp for specific site
%		SaveNoise                - Do we want to save the noise?
%
%	Output:
%		Absolute_Click_Indx   - Indicies of accepted clicks, for reference
%		ClickSeconds          - Seconds of accepted clicks, for reference
%		Noise_Group_Indx      - Indicies of Noise areas, for reference
%		Noise_Group_Averages  - Average values of each group
%		Click_WAV_data        - Timeseries data of each click
%		Click_Teager_data     -	Teager data of each click, for reference
%		Sonar_Pings           - Index of each sonar ping, for reference
 
ClickSeconds = [];
Absolute_Click_Indx = [];
Noise_Group_Indx=[];
Noise_Group_Averages=[];
Absolute_Noise_Indx = zeros(0,2);
FrameLength_samples = constraints.FrameLength_samples;
Noise_Buffer_Max_s = constraints.Noise_Buffer_Max_s;
Noise_Buffer_Min_s = constraints.Noise_Buffer_Min_s;
Clicks_to_reject=[];

HPFilter = constraints.HPFilter;
HPTaps = length(HPFilter);

% Determin the length of the chunks to be evaluated at a time
LENGTH_OF_FILE_s = sum(hdr.xhd.byte_length)/hdr.xhd.ByteRate;
Reasonable_MB  = 45; %60
Reasonable_samples = Reasonable_MB * 1024 * 1024 / 8;  % assume type double
Reasonable_s = Reasonable_samples / hdr.fs;
NUM_CHUNKS = ceil(LENGTH_OF_FILE_s/Reasonable_s);
% ! Change name?
BREAKS_s = Reasonable_s*(0:NUM_CHUNKS);
BREAKS_s(end) = min(BREAKS_s(end),LENGTH_OF_FILE_s);

Sonar_Pings = [];

Click_WAV_data = [];
Click_Teager_data = [];

if Plot_info.Plot
	fprintf('Total chunks: %i\n', NUM_CHUNKS-1);
	fprintf('Chunk\tClicks\tNoise\tTime\n');
end

[Starts, Stops, ~] = ioReadLabelFile(LabelFile);
Start_idx = Starts*hdr.fs;
Stop_idx = Stops*hdr.fs;

for i = 1:NUM_CHUNKS
	data = ioReadXWAV(fid, hdr, BREAKS_s(i), BREAKS_s(i+1), channel, FileType, DataFile);
	
	% Apply High Pass Filter to data but ONLY for getting Teager Energy
	hpdata = filter(HPFilter, 1, data);
	hpdata = hpdata(round(HPTaps/2):end);    % discard start transient
	energy = spTeagerEnergy(hpdata');
	
	% Find the indicies of possible clicks
    [Clicks, Noise] = dtClickDetector(hdr.fs, energy, 0, data, 0.015, constraints);

	if ~isempty(Clicks)
		if length(Clicks) > 2
			% Locate possible sonary pings from echo sounders
			%   They are normally spaced equal distances apart to we look
			%   for the correlation between click times.
			Clicks_to_delete = ...
				locateEchoSounders(Clicks/hdr.fs,hdr.fs,data,BREAKS_s(i), Plot_info);
			peakFreqs = zeros(size(Clicks_to_delete, 1),1);
			
			for p=1:size(Clicks_to_delete,1)
				
				pingData = data(Clicks(Clicks_to_delete(p),1):Clicks(Clicks_to_delete(p),2));
				
				[Frames, WindowPwr] = dtExtractFrames2([1, length(pingData)], ...
					pingData, @blackmanharris, FrameLength_samples, FrameLength_samples/2, 1);
				
				fftcoef = fft(Frames);
				fftcoef(fftcoef == 0) = 10*eps;
				fftcoef = fftcoef(SpecRange,:)/constraints.binWidth_Hz;
				
				pwr = 20*log10(abs(fftcoef)) - WindowPwr + 3;
				
				[~, indx]=max(pwr);
				peakFreqs(p)=SpecRange(indx);
			end
			
			Sonar_Pings = [Sonar_Pings; ...
				BREAKS_s(i) + Clicks(Clicks_to_delete,:)/hdr.fs, peakFreqs];
			Clicks(Clicks_to_delete,:) = [];
		end
		durations = Clicks(:,2) - Clicks(:,1);
		MaxClick_samples = ceil(hdr.fs /1e6 * constraints.MaxClick_us);
		MinClick_samples = ceil(hdr.fs / 1e6 * constraints.MinClick_us);
		
		% Discard clicks that are too small or too large
		%   This is done after the echo-sounder because too-small or -large
		%   clicks can still be used for repetitiveness
		discard = durations > MaxClick_samples | durations <= MinClick_samples;
		Clicks(discard,:) = [];
	end
	
	if ~ isempty(Noise)
		% A block of noise can be split between two chuncks of data while
		% clicks, which are smaller, normally will not. Thus, if the first
		% index of the first noise section matches the last index of the
		% previous chunk, concatinate them.
		Noise_rel = length(data)*(i-1) + Noise;
		if ~isempty(Absolute_Noise_Indx) && Absolute_Noise_Indx(end,2) >= Noise_rel(1,1)-1
			Absolute_Noise_Indx(end,2) = Noise_rel(1,2);
			
			Noise_rel(1,:) = [];
		end
		Absolute_Noise_Indx = [Absolute_Noise_Indx; Noise_rel];
	end

	if ~isempty(Clicks)
		% Perform a series of tests to if clicks pass muster...
		ValidClicks = 1:size(Clicks,1);  % assume okay to begin

		Clicks_to_reject_temp = [];
		% Time domain tests (clipping)
		for c=1:size(Clicks, 1)
			if ~ isempty(constraints.ClipThreshold) && ...
				any(abs(data(Clicks(c,1):Clicks(c,2))) > ...
					constraints.ClipThreshold *(2^hdr.nBits)/2)
				ValidClicks(c) = 0;
			end
			
			% Checking position as in .c file
			if ~isempty(Start_idx) &&...
					isempty(find(Start_idx < length(data)*(i-1) + Clicks(c,1) & ...
							Stop_idx > length(data)*(i-1) + Clicks(c,2), 1))
						ValidClicks(c) = 0;
						Clicks_to_reject_temp(end+1) = c;
			end
		end

		Clicks = Clicks((ValidClicks > 0)',:);

		Clicks_idx = length(data)*(i-1) + Clicks;
		Clicks_s = BREAKS_s(i) + Clicks / hdr.fs;

		Clicks_to_reject = [Clicks_to_reject, Clicks_to_reject_temp + size(ClickSeconds,1)];
		ClickSeconds = [ClickSeconds; Clicks_s];
		Absolute_Click_Indx = [Absolute_Click_Indx; Clicks_idx];

		% Save the click time series and Teager data for further processing
		for x=1:size(Clicks_idx,1)
			Click_WAV_data{end+1} = data(Clicks(x,1):Clicks(x,2));
			Click_Teager_data{end+1} = energy(Clicks(x,1):Clicks(x,2))';
		end
	end
	
	if Plot_info.Plot
		fprintf('%i\t%i\t%i\t%s\n', i,size(ClickSeconds,1), size(Absolute_Noise_Indx,1), sectohhmmss(toc));
	end
end
if ~isempty(Absolute_Click_Indx)  && SaveNoise
	
	% Seperate by density.
	%  Represent the start-end noise number for each group
	Noise_Groups = findClickDensity(Absolute_Noise_Indx, Absolute_Click_Indx, ...
		BREAKS_s(end)*hdr.fs, hdr.fs, Noise_Buffer_Max_s, Noise_Buffer_Min_s);
	
	if size(Noise_Groups,2) < 1
		error('No discernable noise groups');
	end
	
	Noise_Group_Indx = [Absolute_Noise_Indx(Noise_Groups(:,1),1), ...
						Absolute_Noise_Indx(Noise_Groups(:,2),2)];


	% Now compute the average for each Noise group, so we wont need to save the
	% rest...
	Noise_Group_Averages = cell(size(Noise_Groups,1),1);
	
	if Plot_info.Plot
		fprintf('Total Noise groups: %i\n', size(Noise_Groups,1));
		fprintf('Group\tGroup Sz\tData Sz\tTime\n');
	end

	for i = 1:size(Noise_Groups,1)
		if Plot_info.Plot
			fprintf('%i\t%i\t\t', i, Noise_Groups(i,2)-Noise_Groups(i,1));
		end

		window_Num = 1;
		maxWindows = sum(floor(...
			(Absolute_Noise_Indx(Noise_Groups(i,1):Noise_Groups(i,2),2)-...
			Absolute_Noise_Indx(Noise_Groups(i,1):Noise_Groups(i,2),1))...
			/FrameLength_samples));
		Group_Specs = zeros(maxWindows,length(SpecRange));
		for j = Noise_Groups(i,1):Noise_Groups(i,2)
			st_sec = Absolute_Noise_Indx(j,1)/hdr.fs;
			sp_sec = Absolute_Noise_Indx(j,2)/hdr.fs;
			data = ioReadXWAV(fid, hdr, st_sec, sp_sec, channel, FileType, DataFile);

			start = 1;
			stop = FrameLength_samples;
			while stop < length(data)
				dftresult = ...
					fft(data(start:stop).*window, ...
					FrameLength_samples)';
				dft = dftresult(1:(FrameLength_samples/2+1));
				dft(dft == 0) = 10*eps;
				dft = dft/constraints.binWidth_Hz;	% Normalize by bin size

				mag = abs(dft);
				mag = mag(SpecRange,:);

				if ~isempty(AdjustedTransferFunction)
					%power = AdjustedTransferFunction.*mag.^2;
					power = (mag.^2).*(10.^(AdjustedTransferFunction/10));
				else
					power = (10^-3)*(mag.^2)/(sum(window)^2);
				end

				Group_Specs(window_Num,:) = power;
				window_Num = window_Num + 1;

				start = stop+1;
				stop = stop+FrameLength_samples;
			end
		end
		Group_Specs(window_Num:end,:)=[];
		Noise_Group_Averages{i} = noiseStatistic(Group_Specs,90);
		if Plot_info.Plot
			fprintf('%i\t%s\n', length(data), sectohhmmss(toc));
		end
	end
end

end