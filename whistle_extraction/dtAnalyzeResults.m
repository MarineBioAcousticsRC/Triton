function stats = dtAnalyzeResults(results, filename)
% stats = dtAnalyzeResults(results, filename)
% Write summary statistics on tonal detections to file.
%
% results - Structure produced by dtScoreAll
% filename - Write results table to specified filename.  If omitted
%    results are displayed on standard out (the Matlab console).


% Determine where the results will be written
stdout = 1;
if nargin < 2
    fileH = stdout;  % standard output (console)
else
    fprintf('Storing to %s\n', filename);
    fileH = fopen(filename, 'w');
    if fileH == -1
        error('Unable to open %s for writing', filename);
    end
end


falsePos = 0;

% Statistics are maintained for two groups:
% snr - Tonals that meet the selection criteria.  That is to say
%       that we expect our detector to find such tonals.
% all - All tonals.  We keep track of how we are doing on all tonals
%       even if they do not meet the selection criteria.
snr = initStats();
all = initStats();


% table header
fprintf(fileH, 'GT_N\tPrec\tRecall\tmuDev\tCover\t\tFrag\n');

% Process results for each file
for idx=1:length(results)
    % track false positives
    fileFalsePos = results(idx).falsePosN;   % false positives this file
    falsePos = falsePos + fileFalsePos;      % total # false positives
    
    % compute per file stats
    [snr, fileSNR] = perfile(fileFalsePos, snr, results(idx).snr);
    [all, fileAll] = perfile(fileFalsePos, all, results(idx).all);
    
    % show snr statistics
    %        Ngt  Prec   Rec    uDev(std) Cov(std)   Frag(std)   File
    fprintf(fileH, '%4d\t%3.1f\t%3.1f\t%3d±%d\t%.1f±%.1f\t%.1f±%.1f\t%s\n', ...
        results(idx).snr.gt_matchN + results(idx).snr.gt_missN, ...
        fileSNR.precision*100, fileSNR.recall*100, ...
        round(fileSNR.dev_mean), round(sqrt(fileSNR.dev_var)), ...
        fileSNR.coverage, sqrt(fileSNR.coverage_var), ...
        fileSNR.fragmentation, 0, ...%sqrt(fileSNR.fragmentation_var), ...
        results(idx).file);
    
    % save the statistics
    stats.snr(idx) = fileSNR;
    stats.all(idx) = fileAll;
end

% Compute overall statistics
stats.falsePos = falsePos;
stats.cumsnr = overall(falsePos, snr);
stats.cumall = overall(falsePos, all);

fprintf(fileH, '%4d\t%3.1f\t%3.1f\t%3d±%d\t%.1f±%.1f\t%.1f±%.1f\t%s\n', ...
        snr.gt_matchN + snr.gt_missN, ...
        stats.cumsnr.precision * 100, stats.cumsnr.recall*100, ...
        round(stats.cumsnr.dev_mean), round(sqrt(stats.cumsnr.dev_var)), ...
        stats.cumsnr.coverage, sqrt(stats.cumsnr.coverage_var), ...
        stats.cumsnr.fragmentation, 0, ... %sqrt(fileSNR.fragmentation_var), ...
        'Overall');
    
% all done, cleanup
if fileH ~= stdout
    fclose(fileH); 
end



function cumStats = initStats()
% cumStats = initStats()
% Counts and vectors for computing statistics
cumStats.detectionsN = 0;     % # detected
cumStats.gt_matchN = 0;       % # matched with 
cumStats.gt_missN = 0;
cumStats.deviations = [];
cumStats.covered_s = [];
cumStats.excess_s = [];
cumStats.length_s = [];


function [cumStats, fStats] = perfile(falsePos, cumStats, results)

% file precision & recall
fStats.precision = results.detectionsN / (results.detectionsN + falsePos);
fStats.recall = results.gt_matchN / (results.gt_matchN + results.gt_missN);
% deviations
fStats.dev_mean = mean(results.deviations);
fStats.dev_var = var(results.deviations);
% coverage - percentage of ground truth tonals that was detected
% truncate coverage at 100% to prevent tonals that go too long
% from biasing the statistics
coverage = min((results.covered_s ./ results.length_s), 1)*100;
fStats.coverage = mean(coverage);
fStats.coverage_var = var(coverage);
% excess
fStats.excess_mean = mean(results.excess_s);
fStats.excess_var = var(results.excess_s);
% fragmentation
fStats.fragmentation = results.detectionsN / results.gt_matchN;

% Number of good detections
cumStats.detectionsN = cumStats.detectionsN + results.detectionsN;
cumStats.gt_matchN = cumStats.gt_matchN + results.gt_matchN;
cumStats.gt_missN = cumStats.gt_missN + results.gt_missN;
cumStats.deviations = [cumStats.deviations results.deviations];
cumStats.covered_s = [cumStats.covered_s results.covered_s];
cumStats.length_s = [cumStats.length_s results.length_s];
cumStats.excess_s = [cumStats.excess_s results.excess_s];


function stats = overall(falsePos, stats)
% overall statistics
stats.precision = stats.detectionsN / (stats.detectionsN + falsePos);
stats.recall = stats.gt_matchN / (stats.gt_matchN + stats.gt_missN);
stats.dev_mean = mean(stats.deviations);
stats.dev_var = var(stats.deviations);
stats.fragmentation = stats.detectionsN / stats.gt_matchN;
coverage = min((stats.covered_s ./ stats.length_s), 1)*100;
stats.coverage = mean(coverage);
stats.coverage_var = var(coverage);
