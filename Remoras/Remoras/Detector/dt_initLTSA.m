function dt = dt_initLTSA(ltsa)
% dt = dt_initLTSA(ltsa)
% Initialize LTSA detector parameters.
% If structure ltsa is provided, use parameters from ltsa to initialize
% some ranges such as detection band.  Otherwise, use defaults.

dt.ignore_periodic = 1;
dt.LowPeriod_s = 3*60;
dt.HighPeriod_s = 7*60;


dt.MeanAve_hr = 4;  % Spectral subtraction window
dt.Threshold_dB = 2;

dt.mean_selection = 0;  % Information for means
dt.selections = zeros(1,2);
dt.mean_enabled = false;

if nargin > 0
  dt.HzRange = [5000 ltsa.fs*.90];    % like to have signal
else
  dt.HzRange = [5000 90000];    % like to have signal
end
