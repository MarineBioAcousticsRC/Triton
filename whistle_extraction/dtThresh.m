function thr = dtThresh(type)
% thr = dtThresh(type)
% Get common defaults for algorithm.
% type

% Settable Thresholds --------------------------------------------------

error(nargchk(0,1,nargin));  % Check input arguments

if nargin == 0
    type = 'odontocete';        % default
end
  
switch type
    case 'odontocete'
        thr.blocklen_s = 3;        % Data processed in N s blocks

        thr.whistle_dB = 10;       % SNR criterion for whistles
        thr.click_dB = 10;         % SNR criterion for clicks (frame skip)
        
        % Powerlaw noise parameters
        thr.freqContrast=1.5;
        thr.timeContrast=4;
        thr.whitener=1;

        % framing parameters
        thr.advance_ms = 2;
        thr.length_ms = 8;
        % Whistles whose duration is shorter than threshold will be discarded.
        thr.minlen_ms = 150;
        
        % Maximum gap in energy to bridge when looking for a tonal
        thr.maxgap_ms = 50;
        
        % Maximum difference in frequency to bridge when looking for a tonal
        thr.maxgap_Hz = 500;
        
        % define frequency range over which we search for tonals
        thr.high_cutoff_Hz = 50000;
        thr.low_cutoff_Hz = 5000;
        
        % When multiple peaks are less than N Hz away, we only process
        % the largest peak.
        thr.peak_separation_Hz = 250;
        
        % Decision for active / fragment (orphan) set
        % Graphs are placed in the active set if the earliest
        % ancestor is more than N s earlier from the current
        % processing time.
        thr.activeset_s = .15;
        
        % max time to look back when fitting polynomials for
        % active set growth.
        thr.prediction_lookback_s =  thr.advance_ms/1000 * 12;
        
        % Frames containing broadband signals will be ignored.
        % If more than broadand% of the bins exceed the threshold,
        % we consider the frame a click.
        thr.broadband = .05;
        
        % When extracting tonals from a subgraph, use up to thr.disambiguate_s
        % when computing the local polynomial fit.
        thr.disambiguate_s = .3;

        % ---------------------------------------------------------------
        % Parameters used for analyzing performance (see dtPerformance)
        
        % Our ground truth annotation tools fit tonals with cubic splines.
        % As a result, it is not uncommon for the tonal path to deviate
        % slightly from actual tonal.  As a consequence, we search up/down
        % for the strongest peak within a specified interval.
        thr.PeakTolerance_Hz = 500;
        
        % The adjusted ground truth peak (see thr.PeakTolerance_Hz) must
        % be within this distance of the detected frequency to be
        % considered a match.
        thr.MatchTolerance_Hz = 350;
        
 case 'mysticete'
        % very low frequency, we've been using this for blues and such
        
        thr.blocklen_s = 180;   % Data processed in N s blocks

        %Helble Noise parameters
        thr.freqContrast=1.5;
        thr.timeContrast=3;     % 3 for training. 5 test
        thr.whitener=1.2;       % 2;

        % Daniel's settings: for blue whale D calls
        % Settable Thresholds --------------------------------------------
        thr.advance_ms = 100;
        thr.length_ms = 250;
        
        % max time to look back when fitting polynomials for
        % active set growth.
        frames = 4; % Number of frames to look back
        thr.prediction_lookback_s =  1; %thr.advance_ms/1000 * frames;
        
        thr.whistle_dB = 10;      % SNR criterion for whistles
        thr.click_dB = 10;        % SNR criterion for clicks
        
        % Tonal whose duration is shorter than threshold will be discarded.
        thr.minlen_ms = 900;
        
        % Maximum gap in energy to bridge when looking for a tonal
        thr.maxgap_ms = 300;
        
        % Maximum difference in frequency to bridge when looking for a tonal
        thr.maxgap_Hz = 10;  % probably too large, Daniel had 20 Hz/s old code
        
        % define frequency range over which we search for tonals
        thr.high_cutoff_Hz = 300;
        thr.low_cutoff_Hz = 0;
        
        % When multiple peaks are less than N Hz away, we only process
        % the largest peak.
        thr.peak_separation_Hz = 10;
        
        % Decision for active / fragment (orphan) set
        % Graphs are placed in the active set if the earliest
        % ancestor is more than N s earlier from the current
        % processing time.
        thr.activeset_s = .5;
        
        % Frames containing broadband signals will be ignored.
        % If more than broadand% of the bins exceed the threshold,
        % we consider the frame a click.
        thr.broadband = .05;
        
        % When extracting tonals from a subgraph, use up to
        % thr.disambiguate_s when computing the local polynomial fit.
        thr.disambiguate_s = 0.5;

        % ---------------------------------------------------------------
        % Parameters used for analyzing performance (see dtPerformance)
        
        % Our ground truth annotation tools fit tonals with cubic splines.
        % As a result, it is not uncommon for the tonal path to deviate
        % slightly from actual tonal.  As a consequence, we search up/down
        % for the strongest peak within a specified interval.
        thr.PeakTolerance_Hz = 4;
        
        % The adjusted ground truth peak (see thr.PeakTolerance_Hz) must
        % be within this distance of the detected frequency to be
        % considered a match.
        thr.MatchTolerance_Hz = 4;
    otherwise
        error('Unknown parameter/threshold group:  %s', type);
end

