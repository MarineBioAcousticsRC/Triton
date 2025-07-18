function sm_calc_daily_1min_psd()
    % Calculate daily PSD averaged to 1 minute from 1-second PSDs using PARAMS
    % Saves output as NetCDF file: daily_psd_<date>.nc
    
    global PARAMS
    
    % Window and overlap for pwelch
    window = hanning(PARAMS.ltsa.nfft);
    noverlap = round(0.5 * PARAMS.ltsa.nfft); % 50% overlap
    nfft = PARAMS.ltsa.nfft;
    fs = PARAMS.ltsa.fs;
    ch = PARAMS.ltsa.ch;
    
    % Find wav files for the day in indir
    wavFiles = dir(fullfile(PARAMS.ltsa.indir, '*.wav'));
    if isempty(wavFiles)
        error('No WAV files found in %s', PARAMS.ltsa.indir);
    end
    
    % Preallocate containers for all 1-sec PSDs and time stamps (seconds from midnight)
    all_psd_1sec = [];
    all_time_sec = [];
    
    % Loop through all wav files
    for k = 1:length(wavFiles)
        filename = fullfile(PARAMS.ltsa.indir, wavFiles(k).name);
        
        % Read audio data
        [data, Fs_file] = audioread(filename);
        if Fs_file ~= fs
            error('Sample rate mismatch: expected %d, got %d', fs, Fs_file);
        end
        
        if size(data,2) > 1
            data = data(:,ch); % select channel
        end
        
        % Number of samples per 1 second window = nfft
        % pwelch parameters:
        step = nfft - noverlap;
        nSegments = floor((length(data) - nfft)/step) + 1;
        
        % PSD freq vector from first segment
        [~, freq] = pwelch(data(1:nfft), window, noverlap, nfft, fs);
        psd_1sec = zeros(length(freq), nSegments);
        
        % Calculate PSDs for all 1-sec segments
        for s = 1:nSegments
            idx_start = (s-1)*step + 1;
            idx_end = idx_start + nfft - 1;
            segment = data(idx_start:idx_end);
            pxx = pwelch(segment, window, noverlap, nfft, fs);
            psd_1sec(:, s) = pxx; % linear scale PSD V^2/Hz
        end
        
        % Get file datetime from wav file datenum (approximate)
        fileInfo = dir(filename);
        fileTimeNum = fileInfo.datenum;
        dayStartNum = floor(fileTimeNum);
        secondsFromMidnight = (fileTimeNum - dayStartNum) * 24 * 3600;
        
        % Calculate segment timestamps relative to midnight
        segTimes = secondsFromMidnight + ((0:nSegments-1)*step/fs);
        
        % Append results
        all_psd_1sec = [all_psd_1sec psd_1sec];
        all_time_sec = [all_time_sec segTimes];
    end
    
    % Sort PSD segments by time ascending
    [all_time_sec, sortIdx] = sort(all_time_sec);
    all_psd_1sec = all_psd_1sec(:, sortIdx);
    
    % Bin 1-second PSDs into 1-minute bins
    minuteBins = floor(all_time_sec / 60);
    nMinutes = max(minuteBins) + 1;
    
    psd_1min_avg = nan(length(freq), nMinutes);
    
    for m = 0:nMinutes-1
        idxs = minuteBins == m;
        if any(idxs)
            % Average linearly (V^2/Hz)
            psd_1min_avg(:, m+1) = mean(all_psd_1sec(:, idxs), 2);
        end
    end
    
    % Time vector for output (seconds from midnight)
    time_min = (0:nMinutes-1) * 60;
    
    % Save to NetCDF in PARAMS.ltsa.outdir
    dateStr = datestr(dayStartNum, 'yyyymmdd');
    ncfilename = fullfile(PARAMS.ltsa.outdir, ['daily_psd_' dateStr '.nc']);
    if exist(ncfilename, 'file')
        delete(ncfilename);
    end
    
    % Create NetCDF variables
    nccreate(ncfilename, 'freq', 'Dimensions', {'freq', length(freq)}, 'Datatype', 'double');
    ncwrite(ncfilename, 'freq', freq);
    
    nccreate(ncfilename, 'time_min', 'Dimensions', {'time_min', nMinutes}, 'Datatype', 'double');
    ncwrite(ncfilename, 'time_min', time_min);
    
    nccreate(ncfilename, 'psd_1min_avg', ...
        'Dimensions', {'freq', length(freq), 'time_min', nMinutes}, 'Datatype', 'single');
    ncwrite(ncfilename, 'psd_1min_avg', single(psd_1min_avg));
    
    fprintf('Daily 1-minute averaged PSD saved to %s\n', ncfilename);
end
