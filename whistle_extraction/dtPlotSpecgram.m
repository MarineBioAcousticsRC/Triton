function [AxisH, ImageH, ColorbarH] = dtPlotSpecgram(File, Start_s, Stop_s, varargin)
% dtPlotSpecgram(File, Start_s, Stop_s, OptionalArgs)
% Plot spectrogram for specified file between start and stop time in s.
%
% Optional arguments
%   'Axis', AxisHandle - Plot on specified axis.  Otherwise use the 
%        current axis (e.g. default Matlab plotting behavior)
%   'AxisColor', Color - Axis and labels in specified color, e.g. 'c'
%       (cyan)%   'BlockSize_s', N - process in blocks of N seconds (default 3 s)
%   'Brightness_dB', N_dB - Brightness of spectrogram energy, 
%        N dB additive offset.  Default 10
%   'Contrast_Pct', N - Percentage scaling of spectrogram energy.
%       Default 200.
%   'Framing', [Advance_ms, Length_ms] - frame advance and length in ms
%       Defaults to 1 and 2 ms respectively
%   'Threshold', N_dB - Threshold in dB, only applicable when
%       Type is binary or thresholded.
%   'Click_dB', N_dB - Threshold in dB for clicks, a certain percentage
%       of the bins must exceed this.  This is used for excluding clicks
%       from the noise floor computation.
%   'Noise', String|cell array - 
%        String - noise estimation method (default 'none')
%        Cell Array - {NoiseMethod, NoiseMethodArguments...}
%        See dtSpectrogramNoiseComp for details.
%   'ParameterSet', String or struct
%       Default set of parameters.  May either be a string
%       which is passed to dtThresh or a parameter structure
%       that has been loaded from dtThresh and possibly modified.
%       This argument is processed before any other argument, and other
%       arguments may override these values.
%   'Range' [lowHz highHz]
%   'Render', String - How image should be rendered
%       'grey' - grey scale image.  Note that this does not literally
%                mean grey, the current colormap will be used.  Rather
%                colors are picked from the active color map using the
%                spectral power.
%       'binary' - index 0 below threshold, 1 above
%       'floor' - index 0 below threshold, power above
%   'TransferFn', true|false - enable transfer function if available
%
% Returns:
% AxisH - axis handle to which plots were made
% ImageH - A set of image handles into which the spectrogram was
%   partitioned.  This prevents us from requiring large pieces of
%   contiguous memory
% ColorbarH - handle to the colorbar associated with the spectrogram


error(nargchk(3,Inf,nargin));  % check arguments

% defaults
AxisH = [];
AxisColor = [];
NoiseComp = {'none'};
Render = 'grey';
bright_dB = 10;
contrast_Pct = 200;
TransferFn = false;
RemoveTransients = false;

thr = dtParseParameterSet(varargin{:});  % retrieve parameters
block_len_s = thr.blocklen_s;        % process how much at a time


k = 1;
while k <= length(varargin)
    switch varargin{k}
        case 'Axis'
            AxisH = varargin{k+1}; k=k+2;
            if ~ ishandle(AxisH)
                error('Axis argument requires valid axis handle')
            end
        case 'Brightness_dB'
            bright_dB = varargin{k+1}; k=k+2;
        case 'Contrast_Pct'
            contrast_Pct = varargin{k+1}; k=k+2;
        case 'BlockSize_s'
            block_len_s = varargin{k+1}; k=k+2;
            if ~isscalar(block_len_s) || ~isnumeric(block_len_s)
                error('BlockSize must be a scalar value')
            end
        case 'Framing'
            if length(varargin{k+1}) ~= 2
                error('%s must be [Advance_ms, Length_ms]', varargin{k});
            else
                thr.advance_ms = varargin{k+1}(1);
                thr.length_ms = varargin{k+1}(2);
            end
            k=k+2;
        case 'Range'
            Range_Hz = varargin{k+1};
            if length(Range_Hz) ~= 2 || ~ isnumeric(Range_Hz) ...
                    || diff(Range_Hz) <= 0;
                error('%s arg must be [LowHz, HighHz]', varargin{k});
            end
            thr.low_cutoff_Hz = Range_Hz(1);
            thr.high_cutoff_Hz = Range_Hz(2);
            k=k+2;
        case 'Render'
            Render = varargin{k+1}; k=k+2;
        case 'RemoveTransients'
            RemoveTransients = varargin{k+1}; k=k+2;
        case 'Threshold'
            thr.whistle_dB = varargin{k+1}; k=k+2;
        case 'Click_dB'
            thr.click_dB = varargin{k+1}; k=k+2;
        case 'Noise'
            NoiseComp = varargin{k+1}; k=k+2;
            if ~iscell(NoiseComp)
                NoiseComp = {NoiseComp};
            end
        case 'ParameterSet'
            k=k+2;  % processed earlier            
        case 'AxisColor'
            AxisColor =  varargin{k+1}; k=k+2;
            
        otherwise
            try
                if isnumeric(varargin{k})
                    errstr = sprintf('Bad option %f', varargin{k});
                else
                    errstr = sprintf('Bad option %s', char(varargin{k}));
                end
            catch
                errstr = sprintf('Bad option in %d''optional argument', k);
            end
            error('Detector:%s', errstr);
    end
end


header = ioReadWavHeader(File);
handle = fopen(File, 'rb', 'l');
% Select channel as per Triton
channel = channelmap(header, File);

Stop_s = min(Stop_s, header.Chunks{header.dataChunk}.nSamples/header.fs);
if (Start_s >= Stop_s)
    error('Stop_s should be greater then Start');
end

Nyquist = header.fs / 2;
if thr.high_cutoff_Hz > Nyquist
    thr.high_cutoff_Hz = Nyquist;
end

% Frame length and advance in samples
Length_s = thr.length_ms / 1000;
Length_samples = round(header.fs * Length_s);
Advance_s = thr.advance_ms / 1000;
Advance_samples = round(header.fs * Advance_s);
bin_Hz = 1 / Length_s;

Nyquist_bin = floor(Length_samples/2);

% If low cutoff > high cutoff, set to 0
if thr.high_cutoff_Hz < thr.low_cutoff_Hz
    thr.low_cutoff_Hz = 0;
end
% Determine which bins to use and build frequency axis
thr.high_cutoff_bins = min(ceil(thr.high_cutoff_Hz/bin_Hz)+1, Nyquist_bin);
thr.low_cutoff_bins = ceil(thr.low_cutoff_Hz / bin_Hz)+1;

% save indices of freq bins that will be plotted
range_bins = thr.low_cutoff_bins:thr.high_cutoff_bins; 
range_binsN = length(range_bins);  % # freq bin count

fHz = thr.low_cutoff_Hz:bin_Hz:thr.high_cutoff_Hz;
fkHz = fHz / 1000;

% determine transfer function if available
if TransferFn
    [xfr_f, xfr_offset] = tfmap(File, channel, header.nch, fHz);
    xfr_offset = xfr_offset';
else
    xfr_offset = [];
    xfr_f = [];
end

% offset the first window by this many samples
shift_samples = floor(header.fs / thr.high_cutoff_Hz);
shift_samples_s = shift_samples / header.fs;

% Determine what padding is needed.
% padding will be added to each side of the current
% audio data block and removed after the spectrogram
% is computed.
[block_pad_s, block_pad_frames] = ...
    dtSpectrogramNoisePad(Length_s, Advance_s, NoiseComp{:});

% Pad stopping point or set to end of file
Stop_s = min(Stop_s + block_pad_s, ...
    header.Chunks{header.dataChunk}.nSamples/header.fs);

blkstart_s = Start_s;


done = false;
hidx = 1;

if isempty(AxisH)
    AxisH = gca;
end

while ~ done
    
    % Read in the block and compute spectra
    [Signal, snr_dB, Indices, dft, clickP] = ...
        dtProcessBlock(handle, header, channel, ...
        blkstart_s, block_len_s, [Length_samples, Advance_samples], ...
        'Pad', block_pad_s, 'Range', range_bins, ...
        'Shift', shift_samples, ...
        'ClickP', [thr.broadband * range_binsN, thr.click_dB], ...
        'RemoveTransients', RemoveTransients, ...
        'Noise', NoiseComp);

    switch Render
       case {'grey', 'gray'}
           % do nothing
       case 'binary'
           snr_dB(snr_dB < thr.whistle_dB) = 0;   % Threshold image
           snr_dB(snr_dB >= thr.whistle_dB) = 1;
       case 'floor'
           snr_dB(snr_dB < thr.whistle_dB) = 0;   % Threshold image
       otherwise
           error('Bad render type %s', Render);
    end
    
%     % Trim to last complete frame
%     if Indices.FrameLastComplete < length(Indices.timeidx)
%         Indices.timeidx(FrameLastComplete+1:end) = [];
%         snr_dB(:,Indices.FrameLastComplete+1:end) = [];
%     end
    % plot the block
    ImageH(hidx) = image(Indices.timeidx, fkHz, snr_dB, 'Parent', AxisH);  
    colorData = (contrast_Pct/100) .* snr_dB + bright_dB;
    set(ImageH(hidx), 'CData', colorData);
    
    % Store the snr, brightness and contrast in UserData structure
    % associated with the image
    pwr_brt_cont.snr_dB = snr_dB;
    pwr_brt_cont.bright_dB = bright_dB;
    pwr_brt_cont.contrast_Pct = contrast_Pct;
    pwr_brt_cont.threshold_dB = -Inf;
    set(ImageH(hidx), 'UserData', pwr_brt_cont);
    
    hidx = hidx + 1;
    datacursorH = datacursormode(gcf);
    set(datacursorH, 'UpdateFcn', @dtTFNodeDatatip);

    hold on;

    % set start to next frame
    blkstart_s = Indices.timeidx(end) + Advance_s - shift_samples_s;
    done = blkstart_s + Length_s >= Stop_s;
end

fclose(handle);
set(AxisH, 'XLim', [Start_s, Stop_s]);
set(AxisH, 'YDir', 'normal');
set(AxisH, 'YLim', [fkHz(1), fkHz(end)]);
set(AxisH, 'fontsize', 12, 'fontweight', 'b');
xlabel('time (s)', 'fontsize', 12, 'fontweight', 'b');
ylabel('freq (kHz)', 'fontsize', 12, 'fontweight', 'b');

ColorbarH = colorbar('peer', AxisH);
set(get(ColorbarH, 'YLabel'), ...
    'String', 'Spectrum Level (rel dB)', 'fontsize', 12,...
    'fontweight', 'b');

if ~ isempty(AxisColor)
    set(AxisH, 'XColor', AxisColor);
    set(AxisH, 'YColor', AxisColor);
    set(get(AxisH, 'XLabel'), 'Color', AxisColor);
    set(get(AxisH, 'YLabel'), 'Color', AxisColor);
    set(ColorBarH, 'YColor', AxisColor);
    set(get(ColorBarH, 'YLabel'), 'Color', AxisColor);
end
% We have modified the plot.  If the user has zoomed in before, we need
% to let zoom know that the zoom limits have changed.
zoom reset;

