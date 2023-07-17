function dtHighResClickBatch(DataFiles, LabelFiles, varargin)
% dtHighResClickBatch(DataFiles, optional arguments)
% Given a list of data and label files, run the short term detection 
% algorithms on each DataFile. The LabelFiles contain the short-time
% detections.
%
% Optional arguments:
%  'ClipThreshold', N - Normalized clipping threshold.  Set to empty for no
%       clipping, otherwise typically in [0, 1].  When nonempty, checks if
%       high pass version of normalized signal exceeds +/- N*100% of the
%       min/max possible value.  Note that due to filtering, artifacts, it
%       is possible that the maximal absolute value in the high pass
%  'DateRegexp', RegexpString - Regular expression used to extract the
%       timestamp from filenames.  See dateregexp.m for details
%       and datepatterns.m for sample regular expressions.
%  'TritonLabelFile', filename - Create output file which maps each
%       token (set of calls) to times that Triton uses to display
%       classifications.
%  'FeatureExt', string
%       Specification of feature extraction and feature file extension.
%       Valid types:
%               .cc - Cepstral coefficients
%               .pwr - Spectra
%               .pcm - Matrix of framed waveform data saved
%                      as Matlab file
%               .wvt - wavelet packet transform
%       These types can be modifed with the following prefixes:
%               c - complete with reverberations
%               s - single click
%               z - means subtraction, type of Means subtraction
%                  is specified by 'MeansSub'
%       Examples:
%          '.spwr' - single click (no reverb) spectral power
%          '.czcc' - complete click (reverb) with means subtraction,
%                    cepstral coefficients
%       The option 'MeansSub' controls the manner in which the means
%       are subtracted.
%       When LabelFilter is supplied, only detections whose label
%          contains the substring will be used.
%  'FeatureID', String - Appended to each file before the
%       feature extension.  Allows multiple features to reside in the
%       same directories.
%  'FilterNarrowband', [K, D] - Remove any narrowband signals whose
%       bandwidth is less than K kHz when measured at D dB from the 
%       peak frequency.  Default [0, 6]
%  'FrameLength_us', N - Length of frame in microseconds (default 1000)
%  'FrameAdvance_us', N - Time between successive frame in microseconds.
%       (default Framelength_us/2)
%  'MaxFramesPerClick', N - Permit at most N frames for each click.
%       Defaults to Inf.
%  'HPTransition' [Low_kHz, High_kHz] - Echolocation clicks are detected 
%       from the Teager energy of the highpass filtered time series.  This
%       allows the specification of the filter transition band.  Remember
%       that the narrower the transition, the longer the FIR filter will be
%       and that this will slow down the code and increase the filter
%       ramp up and ramp down where no clicks may be detected.
%       Defaults:  [3, 10]
%  'HTKConfigFile', String - Write an HTK configuration file
%  'LabelTranslation', {Match, Replace} - Regular expression to match and
%       replace labels.  Consecutive click regions are only grouped into
%       similar tokens if they contain the same label.  As some labels
%       may contain call specific information, this provides a method
%       to extract information relevant to the class being decided.  As
%       an example, the label 'Dc-SC-32.8' may mean Delphis capensis
%       recorded in Southern California with an SNR of 32.8 (application
%       specific example).  By providing a match string of:
%               '(?<species>[^-]+)-?(?<location>[^-]+)?-?(?<snr>[^-]+)?'
%       and a replace string of:  '$<species>',
%       the label would be mapped to 'Dc' which would make all similarly
%       labeled calls be marked as having been produced by Dephis
%       capensis.  By default, no label translation is done.  Labels that
%       do not match the regular expression are not modified.
%  'LabelFilter', string - Only process clicks whose label matches string.
%       Filtering is applied after LabelTranslation.
%  'Append', N - Label/Script files etc. are overwritten (N=0) or appended (N=1).
%  'MaxSep_s', N - Calls that are less than N s apart will be grouped
%       as a single token.
%  'MaxClickGroup_s, N - Clicks will be grouped into segments no longer
%       than N s provided that they all have the same label after 
%       label processing (LabelTranslation & LabelFilter).
%  'MaxFramesPerClick', N - Regardless of the pulse length, no more than
%       N frames of feature data will be generated.
%  'Plot', N - Plotting control
%       0 - no plot
%       1 - plot detected clicks
%       2 - plot detected clicks & Teager energy
%  'MeansSub', 'spectral'|'cepstral' - What type of means
%       subtractions should be used when FeatureExt contains
%       the means subtraction option 'z'.  Default is 'cepstral'.
%  'ClickAnnotExt', ExtString - Create Wavesurfer style annotation
%       for each click.  Entry is created for each extracted click
%       in a file whose name differs from the source information
%       only by the extension.  E.g. 'cTg' will create '2008-09-27.cTg'
%       for '2008-09-27.wav'.
%  'GroupAnnotExt', ExtString - Create Wavesurfer style annotation
%       for each group.  Similar to ClickAnnotExt, but writes
%       labels for click groups.  Note that the Wavesurfer format
%       does not permit overlapping labels and we cannot create
%       both formats in the same file.
%   'Overwrite', bool - Permit overwriting of files (false)
%       false - do not overwrite existing files
%       true - permit overwriting
%   'Viewpath', Viewpath - Use viewpath.  See
%       ioSearchViewpath/ioOpenViewpath for details.
%   HTK (hidden Markov model toolkit) options
%   'LabelFiles', Labels - Cell array of labels for each file
%   'MLFname', File - Output master label file
%   'SCPname', File - Output script listing feature files
%
% Do not modify the following line, maintained by CVS
% $Id: dtHighResClickBatch.m,v 1.54 2012/04/10 19:26:02 mroch Exp $

    function dtWriteEntry(StartFrame, StopFrame, Label)
        % dtWriteEntry(StartFrame, StopFrame, Label)
        % Given the starting and ending feature indices,
        % write appropriate entries to label/script files.
        %
        % Side effects:  Uses and increments LogicalFileIdx

        Token = sprintf('%s%s-T%05d', basename, FeatureId, ...
                        LogicalFileIdx);

        % Write MLF entry, adding logical file to script
        if MLFid ~= -1
            fprintf(MLFid, '"%s/%s*.lab"\n', MLFPrefix, Token);
            if PerClickLabels
                for clickidx=1:ClicksInFile
                    fprintf(MLFid, '%s\n', Label);
                end
            else
                fprintf(MLFid, '%s\n', Label);
            end
            fprintf(MLFid, '.\n');
        end

        % Output script entry
        if SCPid ~= -1
            % Logical filename.  Important to have an extension (or at least a
            % trailing . as HTK strips off the last extension.  When there's
            % no dots in the name, this is fine, but filename's that have dots
            % multiple dots (e.g. Raven's default naming scheme [or at least
            % Raven data we've seen from Jay Barlow's group]) will cause
            % HTK to break.  e.g.  ".../raven.070911.172808.30min.ChanX.czcc"
            % maps to ".../raven.070911.172808.30min.ChanX".  If we don't
            % add a final ".", the ChanX will be stripped.
            fprintf(SCPid, '%s.grp=%s[%d,%d]\n', ...
                fullfileUx(ScriptPrefix, Token), ...
                fullfileUx(ScriptPrefix, [basename, FeatureId, FeatureExt]),  ...
                StartFrame, StopFrame);
        end

        % Add token timings if user requested them
        % Currently shut off as writing both the click group source range
        % and the individual clicks creates overlaps in the label file.
        if GrpAnnotH ~= -1
            % offsets in s into current file
            fprintf(GrpAnnotH, '%f %f T%d\n', LogicalStart_s, LogicalLast_s, ...
                LogicalFileIdx);
        end
        if TritonLabelFile
            % Compute dates ignoring possible skips due to duty cycling
            dStart = hdr.start.dnum + ...
                datenum([0, 0, 0, 0, 0, LogicalStart_s]);
            dStop = hdr.start.dnum + ...
                datenum([0, 0, 0, 0, 0, LogicalLast_s]);
            % Write out serial dates in binary format.
            ioWriteLabelEntry(TLFid, [dStart dStop], Token, true);
        end

        LogicalFileIdx = LogicalFileIdx + 1;

    end  % end nested function


    function options = dtParseOpts(FeatureExt)
        % options = dtParseOpts(FeatureExt, MeansSub)
        % Populate a structure indicating what type of processing
        % will be done and filename extensions

        % determine if feature is spectra or cepstra
        % Look for cc, pwr, or wav at end of string
        start = regexp(FeatureExt, '(cc|pwr|pcm|wvt)$');
        if isempty(start)
            error('Must specify: cc, pwr, pcm, or wvt');
        else
            flags = FeatureExt(1:start-1);
            options.type = FeatureExt(start:end);
            options.single = ismember('s', flags);
            options.complete = ismember('c', flags);
            options.meanssub = ismember('z', flags);
            if ~ xor(options.single, options.complete)
                error('Must specify single "s" or complete "c" in %s', ...
                    FeatureExt);
            end
        end
    end % end nested function

    function idx = dtOptionCheck(options, type, varargin)
        % idx = dtOptionCheck(options, type, flags)
        % Given an option structure, a specified feature type, and a list of options
        % from 's', 'c', or 'z', check if the specified type is present along with
        % the requested combination of options.  Returns the idx which matches the
        % specified conditions or 0 if there are no matches.

        idx = 0;  % Assume we don't find anything
        % Look for types that match what user specified
        candidates = find(strcmp(type, options.type));
        for cidx = candidates
            ok = true;
            flags_unseen = 'szc';
            % Check if options match...
            for opidx = 1:length(varargin)
                flags_unseen = setdiff(flags_unseen, varargin{opidx});
                switch varargin{opidx}
                    case 's'
                        ok = ok & options.single(cidx);
                    case 'c'
                        ok = ok & options.complete(cidx);
                    case 'z'
                        ok = ok & options.meanssub(cidx);
                    otherwise
                        error('bad option %s', varargin{idx});
                end
            end
            % Make sure options that were not set are not present
            if ~ isempty(flags_unseen)
                for opidx=1:length(flags_unseen)
                    switch flags_unseen(opidx)
                        case 's'
                            ok = ok & ~ options.single(cidx);
                        case 'c'
                            ok = ok & ~ options.complete(cidx);
                        case 'z'
                            ok = ok & ~ options.meanssub(cidx);
                    end
                end
            end
            if ok
                idx = cidx;  % found idx, store it
                break;
            end
        end
    end % end nested fn

    function path = fullfileUx(varargin)
        % path = fullfileUx(arg1, arg2, ..., argN)
        % Equivalent to fullfile, except always uses forward slashes.
        % Useful for tools like HTK that expect / file separators.
        path = fullfile(varargin{:});
        path = strrep(path, '\', '/');
    end

    function cepstra = gencepstra(features, range)
        % cepstra = gencepstra(features, range)
        % Generate a set of cepstra given column vector features
        % Optional vector range only computes the cepstrum of
        % features(range)

        if nargin < 2
            cepstra = spDCT(features);
        else
            cepstra = spDCT(features(range,:));
        end
        % not appropriate if energy over a freq band
        % cepstra(1,:) = [];      % remove energy
    end

    function handle = openAnnot(pathstr, basename, FeatureId, Ext, Viewpath)
        % handle = openAnnot(pathstr, basename, FeatureId, Ext, Viewpath)
        % Open an annotation file based upon the current path, the file
        % basename, the FeatureId string (distinguishes multiple feature
        % sets), and the annotation extension.
        if ~ isempty(Ext)
            AnnotFilename = ...
                fullfile(pathstr, sprintf('%s%s.%s', basename, ...
                    FeatureId, Ext));
            handle = ioOpenViewpath(AnnotFilename, Viewpath, 'w');
        else
          handle = -1;   % treat as if error, writes will test
        end
    end
    
    function printargs(handle, varargin)
        for idx=1:length(varargin)
            if isa(varargin{idx}, 'numeric')
                fprintf(handle, '%f ', varargin{idx});
            elseif isa(varargin{idx}, 'char')
                fprintf(handle, '''%s'' ', varargin{idx});
            elseif isa(varargin{idx}, 'struct')
                fprintf(handle, 'structure ');
            elseif isa(varargin{idx}, 'cell')
                fprintf(handle, '[');
                printargs(handle, varargin{idx}{:});
                fprintf(handle, '] ');
            else
                fprintf(handle, '%s ', disp(varargin{idx}));
            end
        end
    end

    function closeFiles(handles)
        % Given a vector of files, close them as needed
        for idx=1:length(handles)
            if handles(idx) ~= -1
                fclose(handles(idx));
            end
        end
    end
        
% Start main function --------------------------------------------
  
  error(nargchk(4,Inf,nargin));

  % Default values for optional arguments
  FeatureExt = '.czcc';
  LabelFilter = '';
  Append = 0;
  MaxSep_s = 60;
  MaxClickGroup_s = 2;
  TritonLabelFile = [];
  FeatureId = '';
  HTKConfigFile = [];
  Plot =0;
  MeansSub = 'cepstral';
  LabelMatch = '';
  LabelReplace = '';
  FrameLength_us = 1000;
  FrameAdvance_us = [];  % indicates option not set
  MaxCep = 20;
  PerClickLabels = false;
  ClickAnnotExt = [];
  GroupAnnotExt = [];
  DurAnnotExt = 'us';
  DateRE = [];
  ClipThreshold = .95;
  Overwrite = true;
  MaxFramesPerClick = 1;
  TransferFn = false;        % process transfer fn if known
  Viewpath = {};
  StripPrefix = [];
  NdB = 6;                   % for spectrum plots, report NdB bandwidth
  minbandwidth_kHz = 0;
  MLFname = [];              % HTK defaults (do not process)
  SCPname = [];
  
  % Bandpass filter edges.  Filtering implemented via DFT (FFT)
  % and the cepstrum is of DFT(LowFreq : HighFreq)
  LowFreq = 5000;      % had hardcoded to 5K for DCMMPA2007
  HighFreq = 92000;
  
  % Teager energy high pass filter edges
  TransitionBand = [3000 10000];
  
  % Echolocation clicks will be pruned if their peak frequence
  % does not fall within [CutPeakBelow_Hz, CutPeakAbove_Hz]
  CutPeakBelow_Hz = LowFreq; % discard click if peak frequency below X 
  CutPeakAbove_Hz = HighFreq; % discard click if peak frequenc above X

  vidx=1;
  while vidx <= length(varargin)
    switch varargin{vidx}
     case 'DateRegexp'
      DateRE = varargin{vidx+1};
      vidx=vidx+2;
     case 'TritonLabelFile'
      TritonLabelFile = varargin{vidx+1};
      vidx=vidx+2;
     case 'FeatureExt'
      FeatureExt = varargin{vidx+1};
      vidx=vidx+2;
     case 'FeatureId'
      FeatureId = varargin{vidx+1};
      vidx=vidx+2;
     case 'FilterNarrowband'
      args = varargin{vidx+1};
      if length(args) ~= 2
          error('%s requires argument [kHz, dB]', varargin{vidx});
      end
      minbandwidth_kHz = args(1);
      NdB = args(2);
      vidx = vidx+2;
     case 'FrameLength_us'
      FrameLength_us = varargin{vidx+1}; vidx = vidx + 2;
     case 'FrameAdvance_us'
      FrameAdvance_us = varargin{vidx+1}; vidx = vidx + 2;
     case 'MaxFramesPerClick'
      MaxFramesPerClick = varargin{vidx+1}; vidx = vidx + 2;
     case 'HPTransition'
      TransitionBand = varargin{vidx+1}; vidx = vidx + 2;
      if diff(TransitionBand) <= 0
          error('HPTransition:  Low edge must be lower than high edge');
      end
     case 'HTKConfigFile'
      HTKConfigFile = varargin{vidx+1}; vidx = vidx + 2;
     case 'LabelTranslation'
      if iscell(varargin{vidx+1}) && length(varargin{vidx+1}) == 2
        LabelMatch = varargin{vidx+1}{1};
        LabelReplace = varargin{vidx+1}{2};
      end
      if ~ ischar(LabelMatch) || ~ ischar(LabelReplace)
        error(['LabelTranslation requires a cell array:  ' ...
               '''MatchRegExp'', ''ReplaceExp''']);
      end
      vidx = vidx+2;
     case 'LabelFilter'
      LabelFilter = varargin{vidx+1};
      if ~ischar(LabelFilter)
        error('LabelFilter requires a character argument');
      end
      vidx=vidx+2;
     case 'Append'
      Append = varargin{vidx+1};
      vidx=vidx+2;
     case 'MaxSep_s'
      MaxSep_s = varargin{vidx+1};
      vidx = vidx+2;
     case 'MaxClickGroup_s'
      MaxClickGroup_s = varargin{vidx+1};
      vidx = vidx+2;
     case 'Plot'
      Plot = varargin{vidx+1};
      vidx = vidx+2;
     case 'MaxCep'
      MaxCep = varargin{vidx+1};
      vidx = vidx+2;
     case 'MeansSub'
      MeansSub = varargin{vidx+1};
      if ~ sum(strcmp(MeansSub, {'cepstral', 'spectral'}))
        error('Invalid MeansSub argument "%s"', MeansSub);
      end
      vidx = vidx+2;            
     case 'ClickAnnotExt'
      ClickAnnotExt = varargin{vidx+1};
      vidx = vidx+2;
     case 'GroupAnnotExt'
      GroupAnnotExt = varargin{vidx+1};
      vidx = vidx+2;
     case 'Overwrite'
      Overwrite = varargin{vidx+1};
      vidx = vidx+2;
     case 'PeakFreqLim'
      if length(varargin{vidx+1}) ~= 2 || ~isnumeric(varargin{vidx+1})
          error('%s requires argument [LowFreq, HighFreq]', varargin{vidx});
      end
      CutPeakBelow_Hz = varargin{vidx+1}(1);
      CutPeakAbove_Hz = varargin{vidx+1}(2);
      vidx = vidx+2;
     case 'Viewpath'
      if ~ iscell(varargin{vidx+1})
          error('Viewpath must have cell argument.');
      else
          Viewpath = varargin{vidx+1};
      end
      vidx = vidx+2;
     case 'MLFname'
         MLFname = varargin{vidx+1}; vidx = vidx+2;
     case 'SCPname'
         SCPname = varargin{vidx+1}; vidx = vidx+2;
     case 'LabelFiles'
         LabelFiles = varargin{vidx+1}; vidx = vidx+2;            
     otherwise
      error('Optional argument %s not recognized', varargin{vidx});
    end
  end
  
  CutPeakBelow_kHz = CutPeakBelow_Hz / 1000;
  CutPeakAbove_kHz = CutPeakAbove_Hz / 1000;

  if isempty(FrameAdvance_us)
    % default to half of the frame length.  Could not do this prior
    % to getting the frame length
    FrameAdvance_us = FrameLength_us / 2;
  end
  FrameAdvance_ms = FrameAdvance_us / 1000;

  teagerH = []; % default to no Teager energy plot
  if Plot
      waveH = figure;   % Create windows for plots
      noiseH = figure;
      if Plot > 1
        teagerH = figure;
      end
  end
  
  if ~ isempty(FeatureId)
    % Adjust contents of each output file variable 
    % to include the feature identifier
    outputs =  {'TritonLabelFile', 'HTKConfigFile', 'MLFname', 'SCPname'};
    for v = 1:length(outputs)
      oldv = eval(outputs{v});
      if ~ isempty(oldv)
        [base, name, ext] = fileparts(oldv);
        newv = fullfile(base, [name, FeatureId, ext]);
        eval(sprintf('%s = ''%s'';', outputs{v}, newv));
      end
    end
  end
  
  options = dtParseOpts(FeatureExt);
  if ~ options.meanssub
      % User does not desire means subtraction
      MeansSub = 'none';
  end
  
  if ~isempty(LabelFiles) && length(DataFiles) ~= length(LabelFiles)
    error('Lengths of DataFiles and LabelFiles must match')
  end
  
  N = length(DataFiles);

  us_per_s = 1000000;
  PreviousFs = 0; % make sure we build filters on first pass
  
  LogFloor = 10*eps;	% Not sure what the best amount is, this seems to work well
  
  if Append
      mode = 'a';
  else
      mode = 'w';
  end
  
  % Open files that contain information for all files
  ErrorStr = '';
  if ~ isempty(MLFname)
      MLFname = ioGetWriteNameViewpath(MLFname, Viewpath, true);
      MLFid = fopen(MLFname, mode);  % master label file
      if MLFid == -1
          ErrorStr = sprintf('%s %s', ErrorStr, MLFname);
      elseif strcmp(mode, 'w')
          fprintf(MLFid, '#!MLF!#!\n');
      end
  else
      MLFid = -1;
  end

  if ~ isempty(SCPname)
      SCPname = ioGetWriteNameViewpath(SCPname, Viewpath, true);
      SCPid = fopen(SCPname, mode);
      if SCPid == -1
          ErrorStr = sprintf('%s %s', ErrorStr, SCPname);
      end
  else
      SCPid = -1;
  end
  
  if TritonLabelFile    %Open Token Label File for Triton
    TritonLabelFile = ...
        ioGetWriteNameViewpath(TritonLabelFile, Viewpath, true);
    TLFid = fopen(TritonLabelFile, mode);
    if TLFid == -1
      ErrorStr = sprintf('%s %s', ErrorStr, TritonLabelFile);
    end
  else
      TLFid = -1;
  end
  
  if ~ isempty(ErrorStr)
      error('Unable to open:  %s', ErrorStr);
  end
  
  Durations_us = [];
  
  % Cumulative counts across all files
  CumClicksProcessed = 0;
  CumFrames = 0;

  ProgressH = [];
  tic;
  [FileTypes, FileExtensions] = ioGetFileType(DataFiles);
  if find(FileTypes == 0)
      errordlg(sprintf('Cannot determine file type for: %s', ...
          sprintf('%s ', DataFiles{FileTypes == 0})));
  end
  disp_msg(sprintf('Running high resolution click detector %d files', N));
  
  DefaultDate = datenum([0 1 1 0 0 0]);
  % HARP XWavs are offset from this date, do same for wav files
  OffsetFromDate = datenum([2000 0 0 0 0 0]);
  
  for idx=1:N; % for each data file
    
    % Files that are too large to be read into memory are split
    % into logical files of smaller durations
    LogicalFileIdx = 1;     % first logical file
    LogicalStartFrame = 0;
    LogicalStopFrame = 0;
    
    % The following are times associated with the current logical file
    LogicalStart_s = [];       % start time, offset from file start
    LogicalLast_s = [];        % last detected click in current group

    % Source files we excpect to see in the list of viewpath'd directories
    % or directly present.
    DataFile = ioSearchViewpath(DataFiles{idx}, Viewpath);  % source audio

    % break up data file name 
    % There is probably a better way to deal with this; full path may not
    % be appropriate in all cases, but it works well for Windows issues
    [temp, DataFileInfo]=fileattrib(DataFile);
    
    % Strip out extension
    [pathstr, basename, ext] = fileparts(DataFileInfo.Name);

    % Matlab extension may not be correct due to files with multiple dots
    % in the extension (e.g. .x.wav).  Strip out based upon known extension
    basename = [basename, ext];
    basename(end-length(FileExtensions{idx})+1:end) = [];

    % Determine output file names
    LabelFile = ioSearchViewpath(LabelFiles{idx}, Viewpath);  % metadata
    FeatureFile = ioGetWriteNameViewpath(...
        fullfile(pathstr, [basename, FeatureId, FeatureExt]), Viewpath, true);

    if ~ Overwrite   % If feature file exists, skip when Overwrite enabled
        if exist(FeatureFile, 'file')
            fprintf('%s - skipping as features exist\n', FeatureFile);
            continue
        end
    end

    % Open annotation files as needed:
    % individual click start/stop
    ClkAnnotH = openAnnot(pathstr, basename, FeatureId, ClickAnnotExt, Viewpath);
    % groups of clicks start/stop
    GrpAnnotH = openAnnot(pathstr, basename, FeatureId, GroupAnnotExt, Viewpath);
    % duration of each click in us
    DurAnnotH = openAnnot(pathstr, basename, FeatureId, DurAnnotExt, Viewpath);

    % Pesky Windows/UNIX issues - HTK does not like backslash (\)
    FeaturePath = fileparts(FeatureFile);
    FeaturePath = strrep(FeaturePath, '\', '/');  
    if ~ isempty(FeaturePath)
        ScriptPrefix = [pathstr, '/'];
        MLFPrefix = '*';
    else
        ScriptPrefix = '';
        MLFPrefix = '';
    end
   1;
   
    % Retrieve header information for this file
    if FileTypes(idx) == 1
        hdr = ioReadWavHeader(DataFile, DateRE);
    else
        hdr = ioReadXWAVHeader(DataFile, 'ftype', FileTypes(idx));
    end
    if ~ isfield(hdr, 'fs')
        fprintf('Skipping bad file %s', DataFiles{idx});
        % close annotation files if opened
        closeFiles([ClkAnnotH, GrpAnnotH, DurAnnotH]);
        continue
    end

    if hdr.fs ~= PreviousFs
      % construct high pass filter
      HPFilter = spBuildEquiRippleFIR(TransitionBand, [0, 1], 'Fs', hdr.fs);
      HPTaps = length(HPFilter);
      PreviousFs = hdr.fs;
      
      % We don't need to worry about power of 2 for DFT size.  Modern
      % implementations of non power of 2 sized transforms are 
      % very fast and the zero padding introduces harmonics.
      FrameLength_samples = ceil(hdr.fs * FrameLength_us / us_per_s);
      if rem(FrameLength_samples, 2) == 1
        FrameLength_samples = FrameLength_samples - 1;  % Avoid odd length
      end

      FFTSize = FrameLength_samples;
      NyqRange = 1:floor(FFTSize/2)+1;
      % If pulling out framed signal, use rectangular window.
      % For spectral analysis use a better one.
      ExtractPcm = max(dtOptionCheck(options, 'pcm', 'c'), ...
                        dtOptionCheck(options, 'pcm', 's'));
      if ExtractPcm
        window = rectwin(FFTSize)';
      else
        window = hanning(FFTSize)';
      end
      
      % update FrameLength as specgram does not permit zero padding
      % removing - no longer using specgram
      FrameLength_samples = FFTSize;
      
      FrameAdvance_samples = ceil(hdr.fs * FrameAdvance_us / us_per_s);

      disp_msg(sprintf(['Frame length %f us (%d samples), ' ...
                        'advance %f us (%d samples)'], ...
                       FrameLength_us, FrameLength_samples, ...
                       FrameAdvance_us, FrameAdvance_samples));
      disp_msg(sprintf('Click groups: %f max length, %f max separation', ...
                       MaxClickGroup_s, MaxSep_s));
      if MLFid ~= -1
        if PerClickLabels
          disp_msg('MLF - Multiple labels produced for each group (1 label/click)')
        else
          disp_msg('MLF - Single label produced for each click group')
        end
      end
      LowSpecIdx = round(LowFreq/hdr.fs*FFTSize)+1;
      HighSpecIdx = round(HighFreq/hdr.fs*FFTSize)+1;
      SpecRange = LowSpecIdx:HighSpecIdx;
      binWidth_Hz = hdr.fs / FFTSize;
      binWidth_kHz = binWidth_Hz / 1000;
      freq_kHz = ((SpecRange-1)*binWidth_Hz)/1000;  % frequency axis
    end
    
    % Determine channel based on file characteristics
    % NOTE:  This is not automatically determined.  
    %        Examine channelmap to make certain that
    %        values are reasonable.
    channel = channelmap(hdr, DataFileInfo.Name);
        
    % Get the transfer function for this file if appropriate
    if TransferFn
        % Determine which frequencies for which we need the transfer
        % function
        xfr_f = ...
            (SpecRange(1)-1)*binWidth_Hz:binWidth_Hz:(SpecRange(end)-1)*binWidth_Hz;
        [xfr_f, xfr_offset] = ...
            tfmap(DataFileInfo.Name, channel, hdr.nch, xfr_f);
        xfr_offset = xfr_offset';
    else
        xfr_f = []; xfr_offset = [];
    end

    [Starts, Stops, Labels] = ...
        ioReadLabelFile(LabelFile, 'LabelTranslation', {LabelMatch ...
                        LabelReplace}, 'LabelFilter', LabelFilter);
    LowResClickCount = length(Starts);
    
    if LowResClickCount == 0
      disp_msg(sprintf('HighRes detection: empty file %s', LabelFiles{idx}));
      % close annotation files if opened
      closeFiles([ClkAnnotH, GrpAnnotH, DurAnnotH]);
      continue
    end
    % For each detected segment from the high level search, determine
    % if it needs to be broken up into small chunks to avoid thrashing
    % the memory.
    LabLength=Stops-Starts;  % size each segment in s
    MaxTime_s = 30;  % max chunk size
    SegmentsRequired = ceil(LabLength / MaxTime_s);
    TotalSegments = sum(SegmentsRequired);
    NewStarts = zeros(TotalSegments, 1);
    NewStops = zeros(TotalSegments, 1);
    NewLabels = cell(TotalSegments, 1);
    newidx = 1;
    % Breakup starts/stops/lables when the segment size is too long, e.g.
    % idx       Starts(idx)   Stops(idx)        Labels(idx)
    %  3        27            59                Gg-SC-32.9
    % If MaxTims_s == 30, it is rewritten to:
    %  3        27            57                Gg-SC-32.9
    %  4        57            59                Gg-SC-32.9
    for oldidx = 1:length(Starts);
      for k=1:SegmentsRequired(oldidx)
        NewStarts(newidx) = Starts(oldidx) + (k-1)*MaxTime_s;
        NewStops(newidx) = min(NewStarts(newidx)+MaxTime_s, Stops(oldidx));
        NewLabels(newidx) = Labels(oldidx);
        newidx = newidx+1;
      end
    end
    Starts = NewStarts;
    Stops = NewStops;
    Labels = NewLabels;
    
    fid = ioOpenViewpath(DataFiles{idx}, Viewpath, 'r');
    
    % Run detector on each click
    pcmFrames = [];             % Framed signal (when ExtractPcm true)
    Features = [];           % Spectra of each frame (always, but uses
                                % rectangular window when ExtractPcm true)
    SNRs = [];           % SNR est. from Teager high res detector
    ClicksInFile = 0;      % Number detected clicks in this file
    ClicksInToken = 0;   % Number detected clicks relative to
                                % current token
    ClippedClickCount = 0;      % Number of "clipped" clicks in file  

    % Accumulators for noise compensation
    % We build the noise model cumulatively over each file.  To move to
    % a more local or global model, move this initialization code to
    % the appropriate place.
    SumSpecNoise = zeros(length(SpecRange), 1);
    SumCepNoise = zeros(length(gencepstra(zeros(length(SpecRange), 1))), 1);
    NoiseVectors = 0;
    
    NumberStarts = length(Starts);
    ProgressTitle = ...
        sprintf('Processing %d of %d - Matlab will be unresponsive', idx, N);
    if ~ isempty(ProgressH)
      % display progress bar, turning off LaTeX string extensions
      waitbar((idx-1)/N, ProgressH, ProgressTitle);
    else
      ProgressH = waitbar(0, ProgressTitle, 'Name', 'High Res Click Detection');
    end
    
    % Save noise for means subtraction/plotting?
    SaveNoise = ~ strcmp(MeansSub, 'none') | Plot;  
    
    
        
    PreviousLabel = Labels{1};
    for k = 1:NumberStarts
      %fprintf('Processing: [%f %f]\n', Starts(k), Stops(k))
      duration = Stops(k) - Starts(k);
      duration_samples = duration * hdr.fs;
      if duration_samples < 3*length(HPFilter)
          % data is too short for our filter, read a little more
          % on either side making sure not to go past the beginning/
          % end of file.
          pad_s = length(HPFilter) / hdr.fs;
          Starts(k) = max(0, Starts(k) - pad_s);
          Stops(k) = Stops(k) + pad_s;
          if hdr.start.dnum + datenum([0 0 0 0 0 Stops(k)]) > hdr.end.dnum
              Stops(k) = (hdr.end.dnum - hdr.start.dnum) * 24*3600;
          end
      end

      data = ioReadXWAV(fid, hdr, Starts(k), Stops(k), channel, ...
          FileTypes(idx), DataFiles{idx});
      
      % find click on time domain data
      hpdata = filter(HPFilter, 1, data);
      hpdata = hpdata(HPTaps+1:end);    % discard start transient
      
      energy = spTeagerEnergy(hpdata');
      % Since we are operating on the high pass data, we'll
      % set the delay to zero.
      [SClicks, CClicks, noise, SNR] = dtHighResClick(hdr.fs, energy, 0, hpdata, ...
                                                 teagerH, 0.015);
      % Store the type of clicks the user is interested in and whether
      % we will start framing at the start of of the click and work
      % forward or at the end of the click and work backwards.
      if options.complete
        Clicks = CClicks;       % Click + resonances
        Direction = 1;          % Partial frames on trailing edge
        ClickType = 'pulse+resonances';
      else
        Clicks = SClicks;       % initial pulse
        Direction = -1;         % Partial frames before initial pulse.
        ClickType = 'initial pulse';
      end
      
      if ~ isempty(Clicks)
        % Compute the 10 ms starting frame indices associated with this set
        ClickRegion_s = Starts(k);

        % Extract feature data from noise frames for noise compensation
        if SaveNoise
            for noiseseg = 1:size(noise, 1)
                start = noise(noiseseg, 1);
                stop = start + FrameLength_samples - 1;
                % Extract for each frame
                while stop < noise(noiseseg, 2)
                    dftresult = fft(hpdata(start:stop).*window, FFTSize)';
                    dft = dftresult(1:(FFTSize/2+1));
                    dft(dft == 0) = LogFloor;
                    noisePower = 20*log10(abs(dft)) ...
                        - 10*log10(sum(window)^2) + 3;
                    noisePower = noisePower(SpecRange,:);
                    if ~ isempty(xfr_f)
                        noisePower = noisePower - ...
                            xfr_offset(:, ones(size(noisePower, 2), 1));
                    end
                    
                    SumSpecNoise = SumSpecNoise + noisePower;
                    SumCepNoise = SumCepNoise + gencepstra(noisePower);
                    NoiseVectors = NoiseVectors + 1;
                    start = stop+1;   % move to next frame (no overlap)
                    stop = stop+FrameLength_samples;
                end
            end
        end
        
        % Perform a series of tests to if clicks pass muster...
        ValidClicks = ones(1, size(Clicks,1));  % assume okay to begin
        
        % Time domain tests (clipping) -------------------
        for c=1:size(Clicks, 1);
          %SHOULD THIS BE RELATED TO MAX AMP INSTEAD???  Consider 
          %reading in amplitudes for a complete file and plotting 
          %amplitude distribution to determine if skewed or normal?
          if ~ isempty(ClipThreshold) && ...
                any(abs(hpdata(Clicks(c,1):Clicks(c,2))) > ...
                    ClipThreshold *(2^hdr.nBits)/2)
            ValidClicks(c) = 0;
          end
        end
        
        % Frequency domain tests ---------------------
        % Extract frequency information from clicks and decide whether or
        % not to prune
        
        % Estimate the power spectrum for each click...
        if NoiseVectors > 0
            MeanSpecNoise = SumSpecNoise / NoiseVectors;
        else
            MeanSpecNoise = [];
        end
        pwr = cell(size(ValidClicks));
        Frames = cell(size(ValidClicks));
        for c = find(ValidClicks)
            % Extract frames.
            % When processing the initial pulse only, the last complete
            % frame will be at the end of the click.  For a click and
            % resonances, we start framing at the beginning of the click
            % and partial frames are at the trailing edge of the click.
            [Frames{c}, WindowPwr] = dtExtractFrames2(Clicks(c,:), hpdata, @hanning, ...
                FFTSize, FrameAdvance_samples, MaxFramesPerClick);
            
            % Need dft for power and cepstral coefficients
            % process the click
            fftresult = fft(Frames{c});
            fftcoef = fftresult(SpecRange,:);
            % Set a minimum floor so we don't end up with
            % any log 0 values.
            fftcoef(fftcoef == 0) = LogFloor;
            
            %Convert fftcoef to pwr (from mkspecgram.m)
            pwr{c} = 20*log10(abs(fftcoef))...% counts^2/Hz
                - WindowPwr + 3; % undo normalizing factor + other side
            
            if ~ isempty(xfr_f)
                pwr{c} = pwr{c} - xfr_offset(:, ones(size(pwr{c}, 2), 1));
            end            % prune check based on freq
            
            % noise compensation is based on the file mean, but use
            % the mean so far to determine whether to prune this detection
            % or not.
            if isempty(MeanSpecNoise)
                signal = pwr{c};
            else
                signal = pwr{c} - MeanSpecNoise(:, ones(size(pwr{c}, 2)));
            end
            
            % compute peak freq and bandwidth N dB down from peak freq
            [peak_pow, peak_idx] = max(signal);
            peak_freq = freq_kHz(peak_idx);
            % If the smoothing works, rewrite in terms of spectra
            [bandwidth_kHz, low_freq, high_freq] = ...
                spNdB_Bandwidth(spEnvelope(signal), NdB, binWidth_kHz);

            % get rid of me later...
            clickstr = sprintf('HR %d LR %d Delta = %.1f kHz, peak(%.1f kHz)=%.1f dB, %d dB BW: %.1f (%.1f - %.1f) kHz\n', ...
                c, k, hdr.fs / (diff(Clicks(c,:))+1) / 1000, ...
                peak_freq, peak_pow, NdB, bandwidth_kHz, ...
                low_freq, high_freq);
            % Prune sonar, bad clicks 
            % ineffective 29 50.3 87.5 37 79 
%             if peak_freq >23.5 && peak_freq < 26.5
%                 1;
%             end
            % was testing for peak freq, eg min(abs(peak_freq - [29])) < 3
            % bandwidth seems more effective
            if 0 && min(peak_freq - [56]) <= 3
                ValidClicks(c) = 0;
            end
            % min(peak_freq - [38 56]) <= 3
            if (  bandwidth_kHz < minbandwidth_kHz || ...
                  peak_freq < CutPeakBelow_kHz || peak_freq > CutPeakAbove_kHz)
                ValidClicks(c) = 0;
                %fprintf('Pruned %s\n', clickstr);
            else
                %fprintf('Retained %s\n', clickstr);
            end
        end
                 
        ClickInd = find(ValidClicks == 1);  % process these click indices
        if Plot
          figure(waveH)
          t=(1:length(hpdata))./hdr.fs;
          dataLineH = plot(t, hpdata, 'k');  % signal
          hold on
          % click bounds
          clickboundLineH = plot(t(Clicks(:, [1 1]))', ...
               [min(hpdata), max(hpdata)]'*ones(1,size(Clicks,1)), 'g-.', ...
               t(Clicks(:, [2 2]))', ...
               [min(hpdata), max(hpdata)]'*ones(1,size(Clicks,1)), 'g-.');

          PrunedI = find(ValidClicks == 0);  % show pruned detections
          if ~ isempty(PrunedI)
              set(clickboundLineH([PrunedI, PrunedI+length(ValidClicks)]), ...
                  'Color', 'r');
          end

          for m = 1:size(noise,1)  % plot noise
            nrange = noise(m,1):noise(m,2);
            % only need to keep last handle
            noiseLineH = plot(nrange./hdr.fs, hpdata(nrange), 'c:');
          end

          legend([dataLineH; clickboundLineH(1); noiseLineH], ...
              'signal',  ClickType, 'noise')
          xlabel('time (s.)');
          ylabel('counts');
          title(sprintf('LR Click %d in %s', k, DataFile))
          hold off
          %next = input('enter for next click, type a number for debug mode');
          %if ~isempty(next)
          %  keyboard
          %end
        end  % Plot
        
        if ~ strcmp(PreviousLabel, Labels{k})
          % Label has changed, write label/script information 
          % for current features.  Note that embedded function
          % has side effects
          LogicalStopFrame = size(Features, 2) - 1;
          if LogicalStopFrame > LogicalStartFrame
            dtWriteEntry(LogicalStartFrame, LogicalStopFrame, ...
                        PreviousLabel);
            PreviousLabel = Labels{k};
            LogicalStartFrame = LogicalStopFrame + 1;
            LogicalStart_s = CurrentClick_s;
          end
        end
        
        % process clicks not marked to be skipped
        for c = ClickInd
          CurrentClick_s = ClickRegion_s + Clicks(c,1)/hdr.fs; % start time
          if isempty(LogicalStart_s)
            % New logical file, note start of first click
            LogicalStart_s = CurrentClick_s;
            LogicalStartFrame = size(Features, 2);
            ClicksInToken = 1; % first one in group
          elseif (CurrentClick_s - LogicalStart_s) > MaxClickGroup_s || ...
                (CurrentClick_s - LogicalLast_s) > MaxSep_s
            if LogicalStartFrame ~= size(Features, 2)
              % At least one new click was detected, write it out
              LogicalStopFrame = size(Features, 2) - 1;
              
              % Save information about feature entries
              dtWriteEntry(LogicalStartFrame, LogicalStopFrame, ...
                           PreviousLabel);
            end
            % reset for new logical file
            LogicalStartFrame = size(Features, 2);
            LogicalStart_s = CurrentClick_s;
            ClicksInFile = ClicksInFile + ClicksInToken;
            ClicksInToken = 1;
          else
            % add to existing logical file's clicks
            ClicksInToken = ClicksInToken + 1;
          end
          
          LogicalLast_s = ClickRegion_s + Clicks(c, 2)/hdr.fs;
          if ClkAnnotH ~= -1  % write individual click annotations?
            % More likely to examine unfiltered data
            % Account for filter delay in timings
            fprintf(ClkAnnotH, '%f %f C%dT%d\n', ...
                    CurrentClick_s + HPTaps/2/hdr.fs, ...
                    LogicalLast_s+ HPTaps/2/hdr.fs, ...
                    ClicksInToken, LogicalFileIdx);
          end
            
          if ~ isempty(Frames{c})
            % Compute duration of click in microsec
            us = (diff(Clicks(c,:), [], 2)+1) * (us_per_s / hdr.fs);
            Durations_us(end+1) = us;
            % Cumulative counts across all files
            CumClicksProcessed = CumClicksProcessed + 1;
            FramesN = size(Frames{c}, 2);
            CumFrames = CumFrames + FramesN;
            
            switch options.type
             case 'wvt'
              % wavelet packet decomposition
              % only use the first frame regardless of how
              % many were extracted.
              % packets contains SplitLevel + 1 columns
              % column 1 contains the original signal
              % columns 2:SplitLevel contain the decomposed
              % signals.  
              atrous = true;
              if atrous
                  packets = FWT_ATrou(Frames{c}(:,1), SplitLevel);
              else
                  packets = WPAnalysis(Frames{c}(:,1), SplitLevel, ...
                      QuadMirrorFilt);
              end
              % Determine the basis set to use
              if 1
                basis = zeros(1, 2*size(packets, 1)-1);
                % Construct basis for 0 to SplitLevel-1
                for level = 0:size(packets, 2)-2
                  % figure out what we are doing here...
                  % other than constructing the basis set of course
                  for unknown = 0:1
                    basis(node(level, unknown)) = 1;
                  end
                end
                Features = [Features, packets];
              else
                % debug feature exploration
                ent_tree = CalcStatTree(packets, 'Entropy');
                [basisBest, basisValues] = ...
                    BestBasis(ent_tree, SplitLevel);
                whichSpecies = 9;
                basisHist{whichSpecies} = basisHist{whichSpecies} + ...
                    basisBest;
              end
             case {'pwr', 'cc'}
              
              if Plot  % Show spectrum of signal and noise
                figure(noiseH)
                signal = pwr{c} - SumSpecNoise(:, ones(size(pwr{c},2), 1))/NoiseVectors;
                plot(freq_kHz, pwr{c}, '-', freq_kHz, SumSpecNoise/NoiseVectors, '--', ...
                    freq_kHz, signal, ':');
                legend('click+noise','noise', 'click');

                [peak_pow, peak_idx] = max(signal);
                xlabel(sprintf('\\Delta = %.1f kHz, peak %.1f=%.1f', ...
                    hdr.fs / (diff(Clicks(c,:))+1) / 1000, ...
                    freq_kHz(peak_idx), peak_pow));
                ylabel('dB Re. counts^2');
                title(sprintf('HR Click Group %d, LR Click %d in %s', ...
                              c, k, DataFile));
                hold off
                next = input(sprintf('HR Click Group %d, LR Click %d: enter->next, Num->debug', c, k));
                if ~isempty(next)
                  keyboard
                end
              end
              Features = [Features,  pwr{c}];
              SNRs = [SNRs, SNR(c)];
            end
            if ExtractPcm
              pcmFrames = [pcmFrames, Frames{c}];
            end
          else
            ClicksInToken = ClicksInToken - 1;
          end
        end  % single clicks loop
      end % ~isempty(single clicks)
    end % all starts processed
    fclose(fid);        % close this file
    ClicksInFile = ClicksInFile + ClicksInToken;  % add in last logical file 
    
    % perform postprocessing and write requested features
    if ClicksInFile
      
      if ExtractPcm
        save(FeatureFile, 'pcmFrames', 'FFTSize', 'Durations');
      end
      
      % Ready to write out features for the current file for 
      % wavelets and spectral power (when means subtraction
      % is not included).
      switch options.type
       case 'wvt'
        write = true;
       case 'pwr'
        write = max(dtOptionCheck(options, 'pwr', 'c'), ...
                    dtOptionCheck(options, 'pwr', 's'));
       otherwise
        write = false;
      end
      if write
        spWriteFeatureDataHTK(FeatureFile, ...
            Features', FrameAdvance_ms, 'USER');
      end
      
      % Compute cepstra without means subtraction when requested by caller.
      % single clicks
      saveidx = max(dtOptionCheck(options, 'cc', 'c'), ...
                    dtOptionCheck(options, 'cc', 's'));
      if saveidx
        ccFeatures = gencepstra(Features);  % Compute cepstra
        spWriteFeatureDataHTK(FeatureFile, ...
            ccFeatures', FrameAdvance_ms, 'USER');
      end
      
      % TODO:  STILL NEED TO STRAIGHTEN OUT CEPSTRAL SUBSTRACTION 
      
      % spectral means subtraction
      if strcmp(MeansSub, 'spectral')
        % compute means and subtract
        % Note that we perform spectral means subtraction even if 
        % none of the spectral means features are being used as the
        % user may have wanted to have spectral subtraction in 
        % a cepstral (or other) feature set.

        MeanNoise = SumSpecNoise / NoiseVectors;
        Features = Features - ...
            MeanNoise(:, ones(1, size(Features, 2)));
        
        % Write out means subtracted spectral feature vectors if requested
        saveidx = max(dtOptionCheck(options, 'pwr', 's', 'z'), ...
                      dtOptionCheck(options, 'pwr', 'c', 'z'));
        if saveidx
          spWriteFeatureDataHTK(FeatureFile, ...
              Features', FrameAdvance_ms, 'USER');
        end
      end
      
      % Determine number of cepstra to use if we write them out
      if length(SpecRange)-1 > MaxCep
        CepRange = 1:MaxCep;
      else
        CepRange = 1:length(SpecRange)-1;
      end
      
      % cepstra
      saveidx =max(dtOptionCheck(options, 'cc', 's', 'z'), ...
                   dtOptionCheck(options, 'cc', 'c', 'z'));
      if saveidx
        ccFeatures = gencepstra(Features);
        % Either means have been subtraced already for the spectral
        % features or we do it now if we want the means subtracted.
        if strcmp(MeansSub, 'cepstral')
          MeanNoise = SumCepNoise / NoiseVectors;
          ccFeatures = ccFeatures - ...
              MeanNoise(:, ones(1, size(ccFeatures, 2)));
        end
        spWriteFeatureDataHTK(FeatureFile, ...
            ccFeatures(CepRange,:)', FrameAdvance_ms, 'USER');
      end
      
    end  % if ClicksInFile
    
    if isempty(Features)
      FrameCount = 0;
    else
      % Write out last logical file if multiple clicks found since
      % last logical file written
      LogicalLastFrame = size(Features, 2) - 1;
      if LogicalStopFrame > LogicalStartFrame
        dtWriteEntry(LogicalStartFrame, LogicalLastFrame, ...
                     Labels{k});
      end
      FrameCount = size(Features, 2);
    end
    
    % set up for using Triton disp_msg
    msg = sprintf(['%s - high res %d, low res %d, delta %d, ', ...
                   'clip %d, frames %d, tokens %d'], ...
                  LabelFiles{idx}, ClicksInFile, LowResClickCount, ...
                  ClicksInFile - LowResClickCount, ClippedClickCount,...
                  FrameCount, LogicalFileIdx);
    % just print for now
    fprintf('%s\n', msg)
    
    % close annotation files if opened
    if ClkAnnotH ~= -1, fclose(ClkAnnotH); end
    if GrpAnnotH ~= -1, fclose(GrpAnnotH); end
    if DurAnnotH ~= -1
        fprintf(DurAnnotH, '%f\n', Durations_us);
        Durations_us = [];
        fclose(DurAnnotH);
    end
    
  end  % end for idx over logical files
  
  % Plot histograms of click durations 
  % We can only do this if we are not writing them out as the duration
  % array is at the end of each file.
  if ~isempty(Durations_us) && 0
    figure, hist(Durations_us(:,1)./Durations_us(:,2),60),
    title(sprintf('Click Durations, N = %d', length(Durations_us)));
    xlabel('duration s');
    ylabel('counts')
    % What name should we save to, this is outside the main loop
    %save(mfilename, 'Durations', 'Durations', '-append');
  end
  
  if MLFid ~= -1, fclose(MLFid); end
  if SCPid ~= -1, fclose(SCPid); end
  if TLFid ~= -1, fclose(TLFid); end
  delete(ProgressH);    % remove progress bar
  
  disp_msg(sprintf('Total clicks %d, Frames/click: %.2f ', ...
                   CumClicksProcessed, ...
                   CumFrames/CumClicksProcessed));
  if HTKConfigFile
    HTK = ioOpenViewpath(HTKConfigFile, Viewpath, 'w');
    fprintf(HTK, '#Extraction Options: %s\n', FeatureExt);
    fprintf(HTK, 'TARGETKIND = USER\n');
    fprintf(HTK, 'NUMCEPS = %d # Means subtraction: %s\n', ...
        min(length(SpecRange)-1,MaxCep), MeansSub);
    fprintf(HTK, 'TARGETRATE = %d  # Frame Advance %f us, Length %f us,', ...
            FrameAdvance_us*10, FrameAdvance_us, FrameLength_us);
    fprintf(HTK, 'Group MaxSep %f s MaxLen %f s\n', ...
            MaxSep_s, MaxClickGroup_s);
    if ~isempty(varargin)
        fprintf(HTK, '# dtHighResClickBatch OptArgs: ');
        printargs(HTK, varargin{:});
        fprintf(HTK, '\n');
    end
    fclose(HTK);
  end
  
  disp_msg(sprintf(['High resolution click detections complete ', ...
                    '(%d files, %s)'], N, sectohhmmss(toc)));
end

