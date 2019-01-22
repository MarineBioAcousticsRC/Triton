function [waits, stats] = gamma_tests(N, statfn, plotstatic)

if nargin < 3
    plotstatic = true;
    if nargin < 2
        statfn = @mean;
        if nargin < 1
            N = 1;
        end
    end
end

dur = .4;
type = {'*.d-', 'false positives'
        '*_s.d+', 'correct detections'};
if plotstatic
    ha = figure('Name', sprintf('wait times N = %d', N));
    hc = figure('Name', 'Sample counts');
end

hb = figure('Name', sprintf('%s N=%d', char(statfn), N));
bins = 300;
wait_counts = zeros(2, bins);
stats_counts = zeros(2, bins);
sample_counts = cell(2,1);

for k=1:size(type, 1)
    files = utFindFiles(type{k,1}, '.',  1);
    [waits{k}, stats{k}, sample_counts{k}] = process(N, files, statfn, dur);

    if plotstatic
        figure(ha);
        axa(k) = subplot(2,1,k);
        [wait_counts(k,:), bincenters] = hist(axa(k), waits{k}, bins);
        bar(bincenters, wait_counts(k,:));
        title(sprintf('\\mu %f \\sigma^2 %f %s N=%d', ...
            mean(waits{k}), var(waits{k}), type{k,2}, N));
        xlabel(sprintf('Wait time for N=%d events', N))
        ylabel('Frequency')

        figure(hc);
        axc(k) = subplot(2,1,k);
        hist(axc(k), sample_counts{k}, bins);
        title(sprintf('%s C(waits)=%d N=%d ', type{k,2}, length(sample_counts{k}), N));
        xlabel('Number of peaks in whistle')
        ylabel('Frequency')
    end
    
    
    figure(hb);
    axb(k) = subplot(2,1,k);
    [stats_counts(k,:), bincenters] = hist(axb(k), stats{k}, bins);
    bar(bincenters, stats_counts(k,:));
    xlabel(sprintf('%s wait time to %d events)', char(statfn), N));
    ylabel('Frequency')
end

if plotstatic
    linkaxes(axa);
    set(axa, 'YLim', [0, max(max(wait_counts))]);
    linkaxes(axc);
end

linkaxes(axb);
set(axb, 'YLim', [0, max(max(stats_counts))]);


% As low scores are good, we negate them to make the smallest
% number best
sign=-1;
[Pmiss, Pfa, Thresh] = Compute_DET(sign*stats{2}, sign*stats{1});
figure('Name', sprintf('DET Plot %s N=%d', char(statfn), N));
Plot_DET(Pfa, Pmiss, 'r', 2);
1;



function [wait_times, stat, sample_counts] = process(diffN, detections, statfn, dur)

% Compute wait time to next peak detection in tonal
import tonals.*
wait_times = [];
stat = [];
sample_counts = [];
for idx=1:length(detections)
    fprintf('%s %d/%d\n', detections{idx}, idx, length(detections));
    ton = dtTonalsLoad(detections{idx});
    ton_it = ton.iterator();  % iterate across all tonals
    while ton_it.hasNext();
        t = ton_it.next();  % get next tonal
        if t.get_duration() > dur
            continue
        end
        times = t.get_time();
        switch diffN
            case 1
               waits = diff(times);
            otherwise
                N = length(times);
                Rng1 = 1:N-diffN;
                Rng2 = 1+diffN:N;
                if ~ isempty(Rng1)
                    waits = times(Rng2) - times(Rng1);
                end
        end
        wait_times = [wait_times; waits];
        stat(end+1) = statfn(waits);
        sample_counts(end+1) = length(waits);
    end
end


