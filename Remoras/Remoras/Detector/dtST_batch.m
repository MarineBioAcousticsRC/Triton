function dtST_batch(BaseDir, DataFiles, Labels, mode, params, varargin)
% dtST_batch(BaseDir, DataFiles, Patterns, mode, DetectionParams)
% Run the short time spectral detection algorithms on a set of files using
% the specified set of detection parameters.
%
% BaseDir - common prefix for all files, use '' or [] for no prefix
% DataFiles - List of files to be processed
% Labels - Use string Labels{i} as the label for DataFiles{i}
%       If Labels is a string instead of a cell array of strings, 
%       the same label will be used for all files.
% mode - Specified search strategy
%       'Blind search' - Assume no heuristics, search everything
%       'Long Term Spectral Avg (LTSA) detections' - Only search in regions
%               matching accompanying .lt detection files.  Skip any files
%               (produces warning) for which the long term spectral average
%               detections do not exist.
%
% Optional arguments:
% 'Viewpath', {'dir1', 'dir2', ... } 
%               List of directories to be viewpathed.  When searching
%               for files, each directory in the cell array is examined
%               for the file, and the first one encountered is used.
%               New files are always written relative to the first
%               directory in the viewpath.
%
% Do not modify the following line, maintained by CVS
% $Id: dtST_batch.m,v 1.29 2012/05/11 03:12:33 mroch Exp $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Regular expression to match .wav or .x.wav
REWavExt = '(\.x)?\.wav';

Viewpath = {BaseDir}; % default
vidx = 1;
while vidx < length(varargin)
    switch varargin{vidx}
        case 'Viewpath'
            if ~ iscell(varargin{vidx+1})
                error('Viewpath must have cell argument.');
            else
                Viewpath = varargin{vidx+1};
            end
            vidx = vidx+2;
        otherwise
            error('Bad optional argument');
    end
end

% Set up Labels cell array
if ~ iscell(Labels)
  if ~ ischar(Labels)
    error('Labels must be a cell array of strings or a a string')
  else
    if isempty(Labels)
      label = 'unknown';
    else
      label = Labels;
    end
    % copy string to each cell
    Labels = cell(size(DataFiles));
    for idx=1:length(Labels)
      Labels{idx} = label;
    end
  end
end

% Obtain data filenames and label filenames
switch mode
    case 'Long Term Spectral Avg (LTSA) detections'
        HeuristicFiles = regexprep(DataFiles, REWavExt, '.lt');
    case 'Blind search'
        HeuristicFiles = cell(size(DataFiles));       % empty matrices
    otherwise
        error('%s is not a valid mode', mode)
end

disp_msg(sprintf('Running short-time spectral detector:  %d files, %s', ...
                 length(DataFiles), mode));

% Set defaults 
if isempty(params.WhistlePos)
    WhistlePos=1;
else
    WhistlePos = params.WhistlePos;
end
if isempty(params.ClickPos)
    ClickPos=2;
else
    ClickPos = params.ClickPos;
end

% Set extensions for label writing
if WhistlePos
    extensions{WhistlePos} = '.w';
end
if ClickPos
    extensions{ClickPos} = '.c';
end

if length(DataFiles) ~= length(HeuristicFiles)
    error('Lengths of DataFiles and HeuristicFiles must match')
end

N = length(DataFiles);

FrameLength_s = .010;    % window for click/whistle detection (will be
                        % changed to meet next larger power of 2 in
                        % sample domain
ClickPad_s = 0.0075;
MinClickSep_s = 0.5;  

tic;  % Note start time
ProgressH = [];
for idx=1:N
    % information
    ProgressTitle = ...
        sprintf('Processing %d of %d - Matlab will be unresponsive', idx, N);
    if ~ isempty(ProgressH)
      waitbar((idx-1)/N, ProgressH, ProgressTitle);
    else
      ProgressH = waitbar(0, ProgressTitle, ...
                          'Name', 'Short Time spectral detection');
    end
    % process
    CurrentFile = fullfile(BaseDir, DataFiles{idx});

    ClipThresh = .80;
    if ~isempty(strfind(CurrentFile, '.x.wav'))
        ftype = 2;
        % HARP only uses half of dynamic range for high pass
        ClipThresh = ClipThresh/2;  
    else 
        ftype = 1;
    end
    hdr = ioReadXWAVHeader(CurrentFile, 'ftype', ftype);
    % Sum samples across each file embedded in xwav and determine length
    % in s
    FileLength_s = sum(hdr.xhd.byte_length)/hdr.xhd.ByteRate;
    % Don't really need a power of 2 as DFT routines use FFTW which
    % has efficient non power of 2 frames, but ...
    FrameLength_samples = 2^ceil(log2(hdr.fs * FrameLength_s));
    FrameLength_s = FrameLength_samples / hdr.fs;       % revised length
    FFTSize = FrameLength_samples;
    window = kaiser(FFTSize, 7.85);
    FrameAdvance_samples = FrameLength_samples/2;
    FrameAdvance_s = FrameLength_samples / hdr.fs;
           
    % Determine amount of padding that will be used for the MA process
    if isinf(params.MeanAve_s)
        pad_s = 0;  % don't bother padding the MA process, Inf = data block
    else
        % ensure padding on frame boundary
        pad_s = FrameAdvance_s * floor(params.MeanAve_s /2/FrameAdvance_s);
    end

    overlap = (FrameLength_samples - FrameAdvance_samples) / ...
           FrameLength_samples * 100;
       
    
    if ~isempty(HeuristicFiles{idx}) && exist(HeuristicFiles{idx}, 'file')
      % Read detection results from previous stage 
      [Starts, Stops, HeuristicLabels] = ...
          ioReadLabelFile(HeuristicFiles{idx});
    else
      % No previous stage specified or it does not exist.  
      if ~ isempty(HeuristicFiles{idx})
        disp_msg(sprintf(...
            ['Short Time Detector:  missing heuristic %s, ', ...
             'detecting entire file'], HeuristicFiles{idx}));
      end
      % Set to search entire file
      Starts = 0;
      Stops = FileLength_s;
      HeuristicLabels = {'NA'};
    end
           


    % Divide acoustic data into smaller chunks to prevent over committing memory
    % which results in thrashing or worse yet the dreaded out of memory
    % error
    
    % Find a reasonable length of data to handle taking into account that the
    % interleaved channels will also be read and that the data may be padded
    % to permit the moving average filter to fill.  To ensure that analysis
    % is continuous across a segment, we make sure that the time split
    % time is some multiple of the frame rate.  
    Reasonable_MB  = 45;        % Based upon empirical performance on a 1 GB
                                % machine.  Unclear why so low. 
    Reasonable_samples = Reasonable_MB * 1024 * 1024 / 8;  % assume type double
    Reasonable_s = Reasonable_samples / hdr.fs;
    MaxTime_s = FrameAdvance_s * floor((Reasonable_s - pad_s*2)/hdr.nch/FrameAdvance_s); 

    LabLength=Stops-Starts;
    SegmentsRequired = ceil(LabLength / MaxTime_s);  % # segments per interval
    NewStarts = zeros(sum(SegmentsRequired), 1);
    NewStops = zeros(sum(SegmentsRequired), 1);
    NewHeuristicLabels = cell(sum(SegmentsRequired), 1);
    newidx = 1;
    for oldidx = 1:length(Starts);
        for k=1:SegmentsRequired(oldidx)
            NewStarts(newidx) = Starts(oldidx) + (k-1)*MaxTime_s;
            NewStops(newidx) = min(NewStarts(newidx)+MaxTime_s-1/hdr.fs, Stops(oldidx));
            NewHeuristicLabels(newidx) = HeuristicLabels(oldidx);
            newidx = newidx+1;
        end
    end
    % Store start and stop times in s
    Starts_s = NewStarts;
    Stops_s = NewStops;
    HeuristicLabels = NewHeuristicLabels;
    
    for s=1:max(WhistlePos, ClickPos) % Reset detections for this file
        detections{s}=[];
    end
    fid = fopen(CurrentFile, 'r');   % Open audio data
    if fid == -1
        disp_msg(sprintf(['Short time detector: %s - unable to open,', ...
            ' skipping'], CurrentFile));
        continue  % move to next file
    end
    
    % Determine channel based on file characteristics
    % NOTE:  This is not automatically determined.  
    %        Examine channelmap to make certain that
    %        values are reasonable.
    channel = channelmap(hdr, DataFiles{idx});
    
    % Loop through search area, run short term detectors
    for k = 1:length(Starts_s)
       % Add padding for mean if necessary
       start_s = max(0, Starts_s(k)-pad_s);
       stop_s = min(Stops_s(k)+pad_s, FileLength_s);
       if ftype == 1
           data = ioReadWav(fid, hdr, start_s, stop_s, 'Units', 's', ...
               'Channels', channel)';
       else
           data = ioReadXWAV(fid, hdr, start_s, stop_s, ...
               channel, ftype, char(CurrentFile)) / 2^(hdr.nBits-1);
       end
       [dft,f] = specgram(data, FFTSize, hdr.fs, window, ...
           FrameLength_samples - FrameAdvance_samples);

       %Convert dft to pwr (from mkspecgram.m)
%       pwr = 20*log10(abs(dft))...		% counts^2/Hz
%             - 10*log10(sum(window)^2)...  % undo normalizing factor
%             + 3;      % add in the other side that matlab doesn't do
       % calcEndpoints2 just used the following
       pwr = 10*log10(abs(dft).^2);
       
       % Detect clipping
       if ClickPos
           % TODO make option to set clipping level
           Clipped_samples = find(abs(data) > ClipThresh);
           Clipped_frames = floor(Clipped_samples/FrameAdvance_samples)+1;
       else
           Clipped_frames = [];
       end
       [SignalBins]= dtST_signal(...
           pwr, hdr.fs, FFTSize, overlap, f, false, ...
           'Ranges', params.Ranges, ...
           'Thresholds', params.Thresholds, ...
           'MinClickSaturation', params.MinClickSaturation, ...
           'MaxClickSaturation', params.MaxClickSaturation, ...
           'WhistleMinLength_s', params.WhistleMinLength_s, ...
           'WhistleMinSep_s', params.WhistleMinSep_s, ...
           'MeanAve_s', params.MeanAve_s, ...
           'WhistlePos', params.WhistlePos, ...
           'ClickPos', params.ClickPos, ...
           'ClippedFrames', Clipped_frames);
       
       for s=1:max(WhistlePos, ClickPos)
         if ~ isempty(SignalBins{s})
           % translate time axis to account for starting time
           SignalBins{s}(:,1:2) = SignalBins{s}(:,1:2) + start_s;
           % prune any detections that occurred entirely in pad area
           prune = find(SignalBins{s}(:,2) <= Starts_s(k) | ...
                        SignalBins{s}(:,1) >= Stops_s(k));
           SignalBins{s}(prune,:) = [];
           
           % repair detections that occurred partially in overlap area
           repair = find(SignalBins{s}(:,1) < Starts_s(k));
           if ~ isempty(repair)
             SignalBins{s}(repair,1) = Starts_s(k)*ones(size(repair));
           end
           repair = find(SignalBins{s}(:,2) > Stops_s(k));
           if ~ isempty(repair)
             SignalBins{s}(repair,2) = Stops_s(k)*ones(size(repair));
           end
           
           % add current detections, taking into account offset into file
           if size(SignalBins{s}, 1)
             detections{s} = [detections{s}; SignalBins{s}];
           end
         end
       end
    end
    fclose(fid);    % done with current audio file
    
    % Post-process clicks to remove isolated clicks
    if ClickPos && ~isempty(detections{ClickPos})
      % How long between each set of clicks?
      Intervals = detections{ClickPos}(2:end,2)-detections{ClickPos}(1:end-1,1);
      % These ones are too close together and well be merged later.
      ShortIntervals = find(Intervals <= MinClickSep_s);
      % Now find anything that is long enough
      LongDurations = find((detections{ClickPos}(:,2) ...
          -detections{ClickPos}(:,1)) > 2.001*ClickPad_s);
      % We keep anything that is of long enough duration or merged.
      % Everything else is discarded.
      GoodDetections = union(union(ShortIntervals, ShortIntervals+1), ...
                             LongDurations);
      detections{ClickPos} = detections{ClickPos}(GoodDetections,:);
    end
    
    % Write out label files
    for s = 1:max(WhistlePos, ClickPos)
        OutLabel = regexprep(DataFiles{idx}, REWavExt, extensions{s}, ...
            'ignorecase');
        if strcmp(OutLabel, DataFiles{idx})
            error('Output label file and data file have same name');
        end
        FileName = ioGetWriteNameViewpath(OutLabel, Viewpath, true);
        ioWriteLabel(FileName, detections{s}, Labels{idx}); 
    end
end  
if ~ isempty(ProgressH)
  delete(ProgressH);
end

disp_msg(sprintf('Short-time spectral detections complete (%d files, %s)', ...
                 N, sectohhmmss(toc)));
