function [Signal]=dtST_signal(Specgram, fs, nfft, overlap, freqs, Plot, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [Signal]=dtST_signal(Specgram, fs, nfft, overlap, freqs, Plot, varargin)
% Interactive detection on the current spectrogram
% 
% Output:
% Signal: Cell array of start and stop times of detected signals.  By
% default, cell 1 contains tonals and cell 2 contains broadband clicks.
% See optional arguments WhistlePos/ClickPos for possible changes.
%
% Inputs:
% Specgram: power matrix
% fs: sampling frequency
% nfft: FFT length
% overlap: percent overlap [1:100]
% freqs: vector of center frequencies of each spectrogram bin
% Plot: true/false
%
% Optional arguments: Ranges, MinClickSaturation, MaxClickSaturation, WhistleMinLength_s,
% WhistleMinSep_s, Thresholds, MeanAve_s, WhistlePos, ClickPos
%
% 'Ranges', R: R is a matrix indicating minimum and maximum frequency range 
%   the detector will search within whistles (row 1) and clicks (row 2).
%   row numbers can be affected by 'WhistlePos'/'ClickPos'
% 'MinClickSaturation', N:  clicks must have a bandwidth of N Hz to be detected
% 'MaxClickSaturation', N:  clicks can have a bandwidth no more than N Hz to be
%       detected
% 'WhistleMinLength_s', N: whistles must have a duration of N s to be
%       detected
% 'WhistleMinSep_s', N: whistles with a separation duration less than N s
%       will be merged 
% 'Thresholds', T: T is a vector indicating minimum SNR threshold for
%       detection and follow same format as other whistle and click options
% 'MeanAve_s', N: noise estimation window in seconds
% 'WhistlePos' and 'ClickPos' are optional arguments which indicate whether
%       or not you look for whistles or clicks, respectively.  The value 
%       indicates the position within cell arrays Ranges, Thresholds
%       and Signal.  To disable either detector, enter 0 as the value for 
%       optional argument.
% 'ClippedFrames', C:  C is a vector indicating which frames are likely 
%       to be clipped.  If click detection is enabled, those frames and
%       their neighbors will not be selected as containing clicks in
%       spite of high energy.
%
% $Id: dtST_signal.m,v 1.9 2008/05/01 14:52:58 mroch Exp $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Set Default Values

%Signal = {};

% symbolic names for positions in arrays
WhistlePos = 1;
ClickPos = 2;
% subbands to detect various types of events
Ranges = [5500 22000;          % whistles
        10000 fs/2*0.995];     % clicks


MinClickSaturation = 10000; % don't count as click unless has bandwidth of...
MaxClickSaturation = [];
ClippedFrames = [];
WhistleMinLength_s = .25;
WhistleMinSep_s = .0256;
Thresholds = [12, 12];
MeanAve_s = Inf;

WhistlePad_s = 0.15;
ClickPad_s = 0.0075;



k = 1;
while k < length(varargin)
    switch varargin{k}
        case 'Ranges'
            Ranges = varargin{k+1};
            k = k + 2;
        case 'MinClickSaturation'
            MinClickSaturation = varargin{k+1};
            k = k + 2;
        case 'MaxClickSaturation'
            MaxClickSaturation = varargin{k+1};
            k = k + 2;
        case 'WhistleMinLength_s'
            WhistleMinLength_s = varargin{k+1};
            k = k + 2;
        case 'WhistleMinSep_s'
            WhistleMinSep_s = varargin{k+1};
            k = k + 2;
        case 'Thresholds'
            Thresholds = varargin{k+1};
            k = k + 2;
        case 'MeanAve_s'
            MeanAve_s = varargin{k+1};
            k = k + 2;
        case 'WhistlePos'
            WhistlePos = varargin{k+1};
            k = k + 2;
        case 'ClickPos'
            ClickPos = varargin{k+1};
            k = k + 2;
        case 'ClippedFrames'
            ClippedFrames = varargin{k+1};
            k = k + 2;
        otherwise
            error('Bad optional argument:  %s', varargin{k})
    end
end

if isempty(MaxClickSaturation) & ClickPos
    MaxClickSaturation = diff(Ranges(ClickPos,:));
end

if WhistlePos | ClickPos
    Subbands = size(Ranges, 1);

    for s=1:Subbands
        % todo - restore >=,<=, changed to > < to match Melissa's code
        BinRanges{s} = find(freqs > Ranges(s,1) & ...
            freqs < Ranges(s,2));
    end

    binwidth_Hz = freqs(2) - freqs(1);   

    % Determine frame advance in samples and seconds
    FrameAdvance_samples = round((1 - overlap/100)* nfft);
    FrameAdvance_s = FrameAdvance_samples / fs;
    MeanAve_frames = floor(MeanAve_s/FrameAdvance_s - 1);

    if WhistlePos
        PlotHeights(WhistlePos) = max(Ranges(WhistlePos,:)) *.9;
        MinThresholdFreqBins{WhistlePos} = 1;
        MaxThresholdFreqBins{WhistlePos} = Inf;
        PlotSymbols{WhistlePos} = 'wv-';
    end
    if ClickPos
        PlotHeights(ClickPos) = mean(Ranges(ClickPos,:));
        MinThresholdFreqBins{ClickPos} = round(MinClickSaturation/binwidth_Hz);
        MaxThresholdFreqBins{ClickPos} = round(MaxClickSaturation/binwidth_Hz);
        PlotSymbols{ClickPos}='wo-';
    end
    
    for s=1:Subbands
        Thresholds_cell{s} = Thresholds(s);
    end
    
    % find signals
    [Detections, SNRs] = spDetectEnergy(Specgram, 'UseBins', BinRanges,  ...
        'MeanFrames', MeanAve_frames, ...
        'Threshold_dB', Thresholds_cell, ...
        'MinThresholdFreqBins', MinThresholdFreqBins, ...
        'MaxThresholdFreqBins', MaxThresholdFreqBins, 'Display', 0);

    if ClickPos && ~ isempty(ClippedFrames)
        % pick up surrounding frames.  As 
        RemoveFrames = union(union(ClippedFrames, ClippedFrames+1), ...
            ClippedFrames-1);
        % Remove bad start and end if past spectrogram boundaries
        Del = [];
        if RemoveFrames(1) < 1
            Del = [Del; 1];
        end
        if RemoveFrames(end) > size(Specgram, 2)
            Del = [Del; length(RemoveFrames)];
        end
        if Del
            RemoveFrames(Del) = [];
        end
        % Remove clipped clicks
        Detections(RemoveFrames, ClickPos) = zeros(length(RemoveFrames),1);
    end
    % Find continuous segments
    for s = 1:Subbands
        [Start, Label, Length] = spRunLengthAnalysis(Detections(:,s)');
        SignalPresent = find(Label == 1);
        Signal{s} = [Start(SignalPresent)', ...
            Start(SignalPresent)'+Length(SignalPresent)'-1];

        %get max SNR for each signal and add to Signal matrix
        if size(Signal{s},1)==0     
            %Deal with case where there are no detections and add third column
            Signal{s}=[0 0 0];
            Signal{s}(1,:)=[];
        else
            for snrIdx=1:size(Signal{s},1)
                Signal{s}(snrIdx,3) = ...
                    max(SNRs(Signal{s}(snrIdx,1):Signal{s}(snrIdx,2),s));
            end
        end
        
        % Convert to seconds
        Signal{s}(:,1:2) = Signal{s}(:,1:2) .* FrameAdvance_s;
        LastFrame_s = size(Specgram,2) * FrameAdvance_s;
        
        % postprocessing to pad, merge segments, delete < min segments etc.
        switch s
            case WhistlePos
                % Find and eliminate short segments before padding
                durations = Signal{s}(:,2) - Signal{s}(:,1);
                Signal{s}(durations < WhistleMinLength_s, :) = [];
                
                Signal{s}(:,1) = Signal{s}(:,1)-WhistlePad_s;
                Signal{s}(:,2) = Signal{s}(:,2)+WhistlePad_s;
                Signal{s} = dtMergeSegments(Signal{s}, ...
                    WhistleMinLength_s, WhistleMinSep_s);
            case ClickPos
                Signal{s}(:,1) = Signal{s}(:,1)-ClickPad_s;
                Signal{s}(:,2) = Signal{s}(:,2)+ClickPad_s;
                Signal{s} = dtMergeSegments(Signal{s}, 0, 0); % merge overlapping clicks
        end
        
        % Convert detection locations to relative time from start of plot
        % and display
        if Plot && ~ isempty(Signal{s})
            % Our centering here is different than how we handled
            % things in the long term plot.  Talk to Sean about why.  
            PlotSignal{s}=Signal{s}(:,[1 2])-FrameAdvance_s;
            PlotSignal{s}(1,1) = max(PlotSignal{s}(1,1),0);
            PlotSignal{s}(end,2) = min(PlotSignal{s}(end,2), LastFrame_s);
            dtPlotDetections(PlotSignal{s}(:,1:2), ...
                PlotHeights(s), PlotSymbols{s});
        end
    end
end

