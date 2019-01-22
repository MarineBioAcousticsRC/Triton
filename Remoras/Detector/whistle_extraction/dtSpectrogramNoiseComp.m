function power_dB = dtSpectrogramNoiseComp(power_dB, frameAdv_s, ...
    useP, Method, varargin)
% snr_power = dtSpectrogramNoiseComp(power_dB, frameAdv_s, useP, ...
%              'Method', MethodArgs)
% Given a spectrogram in power_dB, compensate for noise.  
%
% frameAdv_s is the time in seconds between consecutive frames and
% is needed for converting noise compensation parameters (specified
% or defaults) from time into frames.  
%
% useP is an indicator function indicating which frames to use
% in the computation, permitting us to omit undesirable frames.  Only
% the mean subtraction and moving average compensation techniques make
% use of this, although many of the other techniques have a means
% subtraction component (see code).
%
% Methods:
%  'none' - no compensation
%  'wiener' - 2D Wiener filter followed by means subtraction
%  'median', [Rows Cols], MA_s
%       Run Rows x Cols median filter
%       followed by a moving average filter of size MA_s seconds.
%       Default:  [3 3], special
%  'meansub' - global means subtraction
%  'distributional' - Compute mean from the 25-75% interval of 
%           the CDF for each frequency bin
%  'MA', avg_s - moving average of specified number of s centered
%                on each bin.
%                Default:  5
%  'PSMF' - progressive switching median filter followed by means
%           subtraction
%  'kovesi' - Kovesi's wavelet denoising.  Require's Peter Kovesi's
%            code, see code for how to obtain it.  Effective but SLOW.
%  'powerlaw' - Helble et al power law normalization

switch Method
    case 'none'
        % do nothing
        
    case 'wiener'
        power_dB = wiener2(power_dB, region);
        % follow up by means subtraction
        power_dB = dtSNR_meanssub(power_dB, useP);
        
    case 'median'
        MA = false;
        if numel(varargin) > 0
            region = varargin{1};
            if numel(varargin) > 1
                avg_s = varargin{2};  % user wants moving average
                MA = true;
            end
        else
            % If this default is changed, it must be propagated
            % to dtSpectrogramNoisePad
            region = [3 3];
        end
        
        power_dB = medfilt2(power_dB, region);
        
        if MA
            % follow up by a moving average
            power_dB = movingAvgSNR(avg_s, frameAdv_s, useP, power_dB);
        else
            % follow up with block mean removal
            %power_dB = dtSNR_meanssub(power_dB, useP);
            power_dB = dtSpectrogramNoiseComp(power_dB, frameAdv_s, ...
                useP, 'distributional');
        end
    
    case 'meansub'
        % subtract mean of entire block
        power_dB = dtSNR_meanssub(power_dB, useP);

    case 'distributional'
        % Sort so that we can have an approximation of the cdf
        power = 10.^(power_dB./20);
        ordered = sort(power, 2);
        % find the smallest 50% interval
        [F, N] = size(ordered);
        N2 = floor(N/2);
        Last = N - rem(N, 2);  % ignore last column if odd
        interval = ordered(:, N2+1:Last) - ordered(:,1:N2);
        [best, bestIdx] = min(ordered, [], 2);
        % compute the noise estimate
        noise = ones(F, 1);
        for f=1:F
            noise(f) = mean(ordered(f, bestIdx(f):bestIdx(f)+N2));
            power_dB(f,:) = power_dB(f,:) - 20*log10(noise(f));
        end
        
        % follow up with a median filter
        region = [3 3];
        power_dB = medfilt2(power_dB, region);
        1;
        
    case 'MA'
        % moving average means subtraction
        if numel(varargin) > 0
            avg_s = varargin{1};
            if ~isscalar(avg_s) || ~ isa(avg_s, 'double')
                error('Expecting averaging window');
            end
        else
            avg_s = 5;
        end
        power_dB = movingAvgSNR(avg_s, frameAdv_s, useP, power_dB);

        
    case 'PSMF'
        % progressive switching median filter
        power_dB = PSMF(power_dB);
        power_dB = dtSNR_meanssub(power_dB, useP);
        
        
    case 'kovesi'
        % Requires:
        % P. D. Kovesi.  
        % MATLAB and Octave Functions for Computer Vision and Image Processing.
        % School of Computer Science & Software Engineering,
        % The University of Western Australia.   Available from:
        % <http://www.csse.uwa.edu.au/~pk/research/matlabfns/>
        % Last accessed May 12, 2009.
        power_dB = noisecomp(power_dB, 3, 6, 2.5, 6, 1);
        
    case 'minstat'
        % Minimum statistics noise estimation
        % Requires voicebox:
        % http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.html
        
        error('minstat noise subtraction not currently implemented');
        % would need to update for current variables, not worth it as
        % doesn't seem to work well
        
        % failed miserably - might be better with tuning but it does
        % not seem worth investing much time in for now.
        if StartBlock_s == Start_s
            % first invocation
            [noise_dB_T, noise_state] = estnoisem(power_dB', Advance_s);
        else
            [noise_dB_T, noise_state] = estnoisem(power_dB', noise_state);
        end
        power_dB = power_dB - noise_dB_T';
        
    case 'powerlaw'
            power_dB = powerlaw(power_dB);

 otherwise
        error('unknown noise subtraction technique')
end

function snr_dB = movingAvgSNR(avg_s, advance_s, useP, power_dB)
        
N = round(avg_s/advance_s);
if mod(N, 2)
    N = N - 1;  % ensure odd
end
Shift = (N-1)/2;
MA_dB = stMARestricted(power_dB', N, double(useP), Shift);
snr_dB = power_dB - MA_dB';

