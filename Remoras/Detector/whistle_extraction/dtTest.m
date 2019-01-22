function dtTest
% Run the system from detecting tonals step to obtaining results.
% Results are written to the text file in the respective directories. Name
% of the result file is the taken from directory name.

% Directories containing the recordings
directory = {'/cache/usr/bhaveshp/bottlenose/'...
    '/cache/usr/bhaveshp/long_beaked/'...
    '/cache/usr/bhaveshp/melon_headed/'...
    '/cache/usr/bhaveshp/short_beaked/'...
    '/cache/usr/bhaveshp/spinner/'};

start_s = 0;
stop_s = Inf;
grnd_thrLen_s = 0.15; % Threshold length for ground truth tonals.
SNR_dB = 8; % Desired threshold for discarding unwanted ground truth tonals.
for didx = 1 : length(directory)
    format_ext = 'ton';    
    absolute_path = strcat(directory{didx}, '*.wav');
    files = dir(absolute_path);
    split = regexp(directory{didx}, '/', 'split');
    
    filename = strcat(split{end-1}, '.txt');
    Filename = fullfile(directory{didx}, filename);
    fid = fopen(Filename, 'w');
    
    for idx = 1:length(files)
        filename = files(idx).name;
        file_path = strcat(directory{didx}, filename);
        
        % Detect tonals
        [tonals graphs] = dtTonalsTracking_1({file_path}, start_s, stop_s, ...
            'Framing', [2 8], 'Threshold', 8);
        load_file_path = strrep(file_path, 'wav', format_ext);
        
        % Load ground truth tonals
        [ground_truth_tonals] = dtTonalsLoad(load_file_path, false);
        grndTonals_N = ground_truth_tonals.size();
        
        % Discard short ground truth tonals
        [ground_truth_tonals] = dtDiscardShortGround(ground_truth_tonals, ...
            grnd_thrLen_s);
        grndShort_N = grndTonals_N - ground_truth_tonals.size();
        
        %Discard ground truth tonals below SNR
        [ground_truth_tonals discarded_tonals] = ...
            dtSNR_groundtruth(file_path, ground_truth_tonals, start_s, ...
            stop_s, SNR_dB);
        grndBelowSNR_N = discarded_tonals.size();
        
        % Performance measure
        [Recall Precision tonals_frag_cnt frag_cnt cov_mean cov_median cov_std] ...
            = dtPerformance(file_path, tonals, ground_truth_tonals);
        
        % Write to file
        fprintf(fid, '%s:\nTonals in recordings:%d\n',...
            filename, grndTonals_N);
        
        fprintf(fid, 'Short ground tonals discarded:%d\n', grndShort_N);
        fprintf(fid, 'Tonals in recordings below SNR after discarding short tonals:%d\n', grndBelowSNR_N);
        
        detTonalsN = tonals.size();
        fprintf(fid, 'Tonals extracted:%d\n', detTonalsN);
        fprintf(fid, '%s: %.2f%%\n%s: %.2f%%\n', 'Recall', Recall,...
            'Precision', Precision);
        fprintf(fid, 'Tonals fragmented:%d\n', tonals_frag_cnt);
        fprintf(fid, 'Number of fragments:%d\n', frag_cnt);
        fprintf(fid, 'Mean Coverage:%.2f%%\n', cov_mean);
        fprintf(fid, 'Median Coverage:%.2f%%\n', cov_median);
        fprintf(fid, 'Standard deviation Coverage:%.2f%%\n\n', cov_std);
        
    end
    fclose(fid);
end