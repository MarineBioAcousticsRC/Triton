function [bins lags] = spFindPeriodic(spectrogram, ...
                                     min_cycle_s, max_cycle_s, ...
                                     window_advance_s)
% [bins, lags] = spFindPeriodic(spectrogram, min_cycle_s, max_cycle_s, 
%                              time_per_bin)
% Given a spectrogram (bin X frame), find bins with recurring periodic
% patterns that occur no less frequently than every min_cycle_s s. and no
% more frequently than every max_cycle_s.  window_advance_s indicates how
% often a new frame is formed in s.  
%
% Returns the associated bins and optionally the lag time in frames.

% Note:  Triton:  PARAMS.ltsa.tave contains Triton's window advance in s.

% Don't need to compute any more lags than this:
maxlags = round(max_cycle_s / window_advance_s);
% determine minimum period in lags
minlags = round(min_cycle_s / window_advance_s);


MinVariance_dB = .01;

% Matlab's cross correlation function computes from -maxlags:maxlags.
bin_k_lag0 = maxlags+1;       % Index of lag 0

spectrogram_bins = size(spectrogram, 1);
autocorr = zeros(maxlags, spectrogram_bins);
peaks = cell(spectrogram_bins, 1);
bins = [];
lags = [];
for k=1:spectrogram_bins
  % compute autocorrelation of each bin
  autocorr_bin_k = xcorr(spectrogram(k,:), maxlags, 'unbiased')';
  % don't worry about negative lags
  autocorr(:,k) = autocorr_bin_k(bin_k_lag0+1:end)';
  if var(autocorr(:,k)) > MinVariance_dB
    peaks{k} = spPeakSelector(autocorr(:,k), 'Method', 'regression', ...
          'RegressionOrder', 2);    
    % see if a peak exists in the desired range
    lags_in_range = find(peaks{k} >= minlags & peaks{k} <= maxlags);
    if ~ isempty(lags_in_range)  % if we found peaks
       bins(end+1) = k;
       lags(end+1) = peaks{k}(lags_in_range(1));
    end
  end
end
1;
% find periodic bins - look for highest lag for each
% bin then find those lags which meet the criterion
% for periodicity.
%[%maxval, peak_lag] = max(autocorr);
%bins = find(peak_lag >= minlag);

% Some frequency bins may be nearly constant with very small variances,
% resulting in misleading peaks, filter these out.  Rather than looking
% at the spectrogram directly, we consider the variances of the
% autocorrelations which should give us similar information while
% operating on a smaller matrix.
%remove_bins = find(var(autocorr) < eps);
%bins = setdiff(bins, remove_bins);

%lags = peak_lag(bins);




