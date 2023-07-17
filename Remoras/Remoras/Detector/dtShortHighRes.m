function [hdr, ClickSeconds] = dtShortHighRes(DataFiles, varargin)
% dtShortHighRes(DataFiles, optional arguments)
% Given a list of data files, run the short term detection 
% algorithms on each.
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
%  'HighFreq', Hz - Set upper bound on frequency analysis
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
%  'LowFreq', Hz - Set lower bound on analysis frequency
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
% $Id: dtShortHighRes.m,v 1.7 2014/01/17 20:46:35 mroch Exp $

    function dtWriteEntry(StartFrame, StopFrame)
        % dtWriteEntry(StartFrame, StopFrame)
        % Given the starting and ending feature indices,
        % write appropriate entries to label/script files.
        %
        % Side effects:  Uses and increments LogicalFileIdx

        Token = sprintf('%s%s-T%05d', basename, FeatureId, ...
                        LogicalFileIdx);

        % Write MLF entry, adding logical file to script
        if MLFid ~= -1
            fprintf(MLFid, '"%s/%s*.lab"\n', MLFPrefix, Token);
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
        for idxP=1:length(varargin)
            if isa(varargin{idxP}, 'numeric')
                fprintf(handle, '%f ', varargin{idxP});
            elseif isa(varargin{idxP}, 'char')
                fprintf(handle, '''%s'' ', varargin{idxP});
            elseif isa(varargin{idxP}, 'struct')
                fprintf(handle, 'structure ');
            elseif isa(varargin{idxP}, 'cell')
                fprintf(handle, '[');
                printargs(handle, varargin{idxP}{:});
                fprintf(handle, '] ');
            else
                fprintf(handle, '%s ', disp(varargin{idxP}));
            end
        end
    end
    function closeFiles(handles)
        % Given a vector of files, close them as needed
        for idxC=1:length(handles)
            if handles(idxC) ~= -1
                fclose(handles(idxC));
            end
        end
	end

	function printClickDetails(accept)
		plot_data = data;
		click_start_s = Absolute_Click_Indx(c,1)/hdr.fs;
		click_end_s = Absolute_Click_Indx(c,2)/hdr.fs;

		figure(plotH);
		subplot(waveH);
		t = linspace(click_start_s,click_end_s,length(plot_data));
		plot(t, plot_data); hold on;
		plot([click_start_s click_start_s],[max(plot_data) min(plot_data)], '-r');
		plot([click_end_s click_end_s],[max(plot_data) min(plot_data)], '-r');
		xlim([click_start_s,click_end_s]);
		if accept
			title(sprintf(['Accepted Click # %i\n','%s'], c, DataFile),...
					'Interpreter', 'none', 'Color','green');
		else
			title(sprintf(['Rejected Click # %i\n','%s'], c, DataFile),...
				'Interpreter', 'none', 'Color','red');
		end
		xlabel('Seconds into file');
		set(gca,'XTick',linspace(click_start_s,click_end_s,10));

		subplot(teagH);
		plot_teag = Click_Teager_data{c};
		plot_teag_smooth = stMA(plot_teag', 11,5);
		t = linspace(click_start_s,click_end_s,length(plot_teag));
		plot(t, plot_teag, 'r'); hold on;
		plot(t, plot_teag_smooth, '--b');
		plot([click_start_s click_start_s],[max(plot_teag) min(plot_teag)], '-k');
		plot([click_end_s click_end_s],[max(plot_teag) min(plot_teag)], '-k');
		xlim([click_start_s,click_end_s]);
		ylim([min(plot_teag) max(plot_teag)]);
		title('Teager Energy');
		xlabel('Seconds into file');
		set(gca,'XTick',linspace(click_start_s,click_end_s,10));

		subplot(noiseH);
		if SaveNoise
			signal = normalized_pwr;
			[~, peak_f_idx] = max(signal);
			bottom = min([MeanNoise; pwr; signal]);
			top = max([MeanNoise; pwr; signal]);
			plot(freq_kHz, pwr, '-b', ...
				 freq_kHz, MeanNoise, '--g', ...
				 freq_kHz, signal, '-r',...
				 freq_kHz([1,end]),[Threshold_dB Threshold_dB],':k',...
				 freq_kHz(peak_f_idx), signal(peak_f_idx), '*k',...
				 LowPeakLimitHz/1000*[1 1], [bottom top],'-k',...
				 HighPeakLimitHz/1000*[1 1],[bottom top],'-k');
			legend('click+noise','noise','click', 'threshold', 'Peak Frequency');
		else
			signal = pwr;
			[~, peak_f_idx] = max(signal);
			bottom = min(pwr);
			top = max(pwr);
			plot(freq_kHz, pwr, '-b', ...
				 freq_kHz([1,end]),[Threshold_dB Threshold_dB],':k',...
				 freq_kHz(peak_f_idx), signal(peak_f_idx), '*k',...
				 LowPeakLimitHz/1000*[1 1], [bottom top],'-k',...
				 HighPeakLimitHz/1000*[1 1],[bottom top],'-k');
			legend('click', 'threshold', 'Peak Frequency');
		end
		[peak_pow, peak_idx] = max(signal);
		xlabel(sprintf(...
			'\\Delta = %.1f kHz, peak %.1f=%.1f', ...
			hdr.fs / (diff(Absolute_Click_Indx(c,1:2)/hdr.fs)+1) / 1000, ...
			freq_kHz(peak_idx), ...
			peak_pow));
		ylabel('dB Re. counts^2');
		title(sprintf(...
			['Bins over Threshold: %i {Min: %i, Max: %i}\n'],...
			BinsOverThreshold, MinBins, MaxBins));
		hold off;
		next = input(sprintf('Click # %i: enter->next, Num->debug: ', c));
		if ~isempty(next)
			keyboard
		end
	end
% Start main function --------------------------------------------
     
    error(nargchk(5,Inf,nargin));
    
    % Default values for optional arguments
    FeatureExt = '.czcc';
	NoiseExt = [];
    Append = 0;
    MaxSep_s = 60;
    MaxClickGroup_s = 2;
    TritonLabelFile = [];
    FeatureId = '';
    HTKConfigFile = [];
    Plot =0;
	ShowClickProgression=1;
    MeansSub = 'cepstral';
    LabelMatch = '';
    LabelReplace = '';
    FrameLength_us = 1000;
    FrameAdvance_us = [];  % indicates option not set
    MaxCep = 20;
    ClickAnnotExt = [];
    GroupAnnotExt = [];
	PingAnnotExt = [];
    DurAnnotExt = 'us';
    DateRE = [];
    ClipThreshold = .95;
    Overwrite = true;
    MaxFramesPerClick = 1;
    Viewpath = {};
    MLFname = [];              % HTK defaults (do not process)
    SCPname = [];
	MinClickSeparation_us = 250;
	MinGap_us = 50;
	MinClick_us = 40;
	MaxClick_us = 500;
	pingH = [];
	perH = [];
	remH = [];

    % Bandpass filter edges.  Filtering implemented via DFT (FFT)
    % and the cepstrum is of DFT(LowFreq : HighFreq)
    LowFreq = 10000;      % had hardcoded to 5K for DCMMPA2007
    HighFreq = 92000;
	LowPeakLimitHz = 10000;
	HighPeakLimitHz = 90000;
	
	Noise_Buffer_Max_s= 3;
	Noise_Buffer_Min_s = 1;

    % Teager energy high pass filter edges
    TransitionBand = [3000 8000];

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
            error(['LabelTranslation requires a cell array:  ',...
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
		 case 'PingAnnotExt'
		  PingAnnotExt = varargin{vidx+1};
		  vidx = vidx+2;
         case 'Overwrite'
          Overwrite = varargin{vidx+1};
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
         case 'MinSaturationPerc'
                MinSaturationPerc = varargin{vidx+1}; vidx = vidx+2;
         case 'MaxSaturationPerc'
                MaxSaturationPerc = varargin{vidx+1}; vidx = vidx+2;
         case 'ClickThreshold'
                Threshold_dB = varargin{vidx+1}; vidx = vidx+2;
		 case 'MinClickSeparation_us'
				MinClickSeparation_us = varargin{vidx+1}; vidx = vidx+2;
		 case 'MinGap_us'
			 MinGap_us = varargin{vidx+1}; vidx = vidx+2;
		 case 'MinClick_us'
			 MinClick_us = varargin{vidx+1}; vidx = vidx+2;
		 case 'MaxClick_us'
			 MaxClick_us = varargin{vidx+1}; vidx = vidx+2;
		 case 'ClipThreshold'
			 ClipThreshold = varargin{vidx+1}; vidx = vidx+2;
		 case 'LowFreq'
			 LowFreq = varargin{vidx+1}; vidx = vidx+2;
		 case 'HighFreq'
			 HighFreq = varargin{vidx+1}; vidx = vidx+2;
		 case 'LowPeakLimitHz'
			 LowPeakLimitHz = varargin{vidx+1}; vidx = vidx+2;
		 case 'HighPeakLimitHz'
			 HighPeakLimitHz = varargin{vidx+1}; vidx = vidx+2;
		 case 'NoiseBufferMaxS'
			 Noise_Buffer_Max_s = varargin{vidx+1}; vidx = vidx+2;
		 case 'NoiseBufferMinS'
			 Noise_Buffer_Min_s = varargin{vidx+1}; vidx = vidx+2;
		 case 'NoiseExt'
			 NoiseExt = varargin{vidx+1}; vidx = vidx+2;
		 case 'ShowClickProgression'
			 ShowClickProgression = varargin{vidx+1}; vidx = vidx+2;
         otherwise
          error('Optional argument %s not recognized', varargin{vidx});
        end
    end

    if isempty(FrameAdvance_us)
        % default to half of the frame length.  Could not do this prior
        % to getting the frame length
        FrameAdvance_us = FrameLength_us / 2;
    end
    FrameAdvance_ms = FrameAdvance_us / 1000;

	if Plot
	  plotH = figure;
	  waveH = subplot(3,1,1);
	  teagH = subplot(3,1,2);
	  noiseH = subplot(3,1,3);

	  if Plot > 2
		  pingH = figure;
		  perH = subplot(2,1,1);
		  remH = subplot(2,1,2);
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
	
	SpectralMeansSub = strcmp(MeansSub,'spectral');
	CepstralMeansSub = strcmp(MeansSub,'cepstral');

	% Save noise for means subtraction/plotting?
	SaveNoise = ~ strcmp(MeansSub, 'none');  

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
        TritonLabelFile =  ioGetWriteNameViewpath(TritonLabelFile, Viewpath, true);
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
	ProgressC = [];
    tic;
    [FileTypes, FileExtensions] = ioGetFileType(DataFiles);
    if find(FileTypes == 0)
      errordlg(sprintf('Cannot determine file type for: %s',  ...
          sprintf('%s ', DataFiles{FileTypes == 0})));
    end
    disp_msg(sprintf('Running high resolution click detector %d files', N));
	
	average_leading_noise = [];
	average_following_noise = [];
	last_outing = [];
	
	%log_fid = fopen(...
	%	sprintf('/zal/johanna/matlab/watch_log_%s.log', datestr(now, 'YYmmDD-HHMMss')),...
	%	'a');
    log_fid = 1;  % Write to standard output
	fprintf(log_fid, 'Starting run of %i files at %s...\n', N,...
		datestr(now, 'mm/DD/YYYY HH:MM:ss PM'));
	fprintf(log_fid, '\tFeatureExt: %s\n', FeatureExt);
	fprintf(log_fid, '\tMeansSub: %s\n', MeansSub);
	
    for idx=1:N; % for each data file
% 		try
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
			fprintf(log_fid, '\nFile #%i {%s}: ', idx, DataFile);
			if ~DataFile
				fprintf('File [%i] %s not found!\n', idx, DataFiles{idx});
				fprintf(log_fid, 'Not Found!');
				continue;
			end

			% break up data file name 
			% There is probably a better way to deal with this; full path may not
			% be appropriate in all cases, but it works well for Windows issues
			[~, DataFileInfo]=fileattrib(DataFile);

			% Strip out extension
			[pathstr, basename, ext] = fileparts(DataFileInfo.Name);

			% Matlab extension may not be correct due to files with multiple dots
			% in the extension (e.g. .x.wav).  Strip out based upon known extension
			basename2 = [basename, ext];
			basename2(end-length(FileExtensions{idx})+1:end) = [];
			basename = basename2;

			file_save_path = [Viewpath{1}, pathstr(length(Viewpath{2})+1:end)];

			% Determine output file names
			FeatureFile = ioGetWriteNameViewpath(...
				fullfile(file_save_path, [basename, FeatureId, FeatureExt]), Viewpath(1), true);
			FeatureFile2 = ioGetWriteNameViewpath(...
				fullfile(file_save_path, [basename, FeatureId, '.ccc']), Viewpath(1), true);

			if ~ Overwrite   % If feature file exists, skip when Overwrite enabled
				if exist(FeatureFile, 'file')
					fprintf('%s - skipping as features exist\n', FeatureFile);
					fprintf('Feature file {%s} already exists', FeatureFile);
					continue
				end
			end

			% Open annotation files as needed:
			% individual click start/stop
			ClkAnnotH = openAnnot(file_save_path, basename, FeatureId, ClickAnnotExt, Viewpath(1));
			% groups of clicks start/stop
			GrpAnnotH = openAnnot(file_save_path, basename, FeatureId, GroupAnnotExt, Viewpath(1));
			% duration of each click in us
			DurAnnotH = openAnnot(file_save_path, basename, FeatureId, DurAnnotExt, Viewpath(1));
			% locations of pings from an echo-sounder
			PingAnnotH = openAnnot(file_save_path, basename, FeatureId, PingAnnotExt, Viewpath(1));

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

			% Retrieve header information for this file
			if FileTypes(idx) == 1
				hdr = ioReadWavHeader(DataFile, DateRE);
			else
				hdr = ioReadXWAVHeader(DataFile, 'ftype', FileTypes(idx));
			end
			if ~ isfield(hdr, 'fs')
				fprintf('Skipping bad file %s', DataFiles{idx});
				fprintf(log_fid, 'Bad File');
				% close annotation files if opened
				closeFiles([ClkAnnotH, GrpAnnotH, DurAnnotH, PingAnnotH]);
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
			  % If pulling out framed signal, use rectangular window.
			  % For spectral analysis use a better one.
			  ExtractPcm = max(dtOptionCheck(options, 'pcm', 'c'), ...
								dtOptionCheck(options, 'pcm', 's'));
			  if ExtractPcm
				window = rectwin(FFTSize)';
			  else
				window = blackmanharris(FFTSize)';
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
				  disp_msg('MLF - Single label produced for each click group')
			  end
			  LowSpecIdx = round(LowFreq/hdr.fs*FFTSize)+1;
			  HighSpecIdx = round(HighFreq/hdr.fs*FFTSize)+1;
			  SpecRange = LowSpecIdx:HighSpecIdx;
			  binWidth_Hz = hdr.fs / FFTSize;
			  freq_kHz = ((SpecRange-1)*binWidth_Hz)/1000;  % frequency axis
				MinBins = round(MinSaturationPerc*length(freq_kHz));
				MaxBins = round(MaxSaturationPerc*length(freq_kHz));
			end

			% Determine channel based on file characteristics
			% NOTE:  This is not automatically determined.  
			%        Examine channelmap to make certain that
			%        values are reasonable.
			channel = channelmap(hdr, DataFileInfo.Name);
			
			% Determine which frequencies for which we need the transfer
			% function
			TransferFunction = [];
			AdjustedTransferFunction = [];
            1;
            
			try
				[TransferFunction, id] = retrieveTransferFunction(DataFile, freq_kHz);
				U = sum(window.^2)/FrameLength_samples;
				Adjust = 1/(hdr.fs*FrameLength_samples*U);
 				%AdjustedTransferFunction = Adjust.*(10.^(TransferFunction'/10));
				AdjustedTransferFunction = TransferFunction';
			catch err
				error_message = err.message;
				fprintf(log_fid, '\n\t%s\n\t', error_message);
			end
			

			fid = ioOpenViewpath(DataFiles{idx}, Viewpath, 'r');

				if ShowClickProgression
					ProgressTitle = ...
						sprintf('Processing %d of %d - Matlab will be unresponsive', idx, N);
					if ~ isempty(ProgressH)
					  % display progress bar, turning off LaTeX string extensions
					  waitbar((idx-1)/N, ProgressH, ProgressTitle);
					else
					  ProgressH = waitbar(0, ProgressTitle, 'Name', 'Short & High Res Click Detection');
					  Pos = get(ProgressH, 'Position');
					  ProgressC = waitbar(0, 'Processing 0 of ?', 'Name', ...
						  'Number of Clicks', 'Position', ...
						  [Pos(1), Pos(2)-Pos(4)*1.5, Pos(3), Pos(4)]);
				end
			end
	% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
	% ----------------------------------- Find Position of Clicks ---------------------%
	% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
            % Determine the label file from the low-resolution click
            % detection pass
            [dirpath, basename, ext] = fileparts(DataFile);
            % 2nd time in case there is a .x.wav extension
            [dontcare, basename, dontcare] = fileparts(basename);
            LabelName = [basename, '.c'];
            LabelFile = ioSearchViewpath(LabelName, Viewpath);
            if isempty(LabelFile)
                fprintf('Skipping %s, no label file found\n', LabelName);
                continue;
            end
			clear Absolute_Click_Indx ClickSeconds
			clear Noise_Group_Indx Noise_Group_Averages
			clear Click_WAV_data Click_Teager_data

			% Filling contstraints structs to cut down on the number of inputs
			constraints.ClipThreshold =			ClipThreshold;
			constraints.MinClickSeparation_us = MinClickSeparation_us;
			constraints.MinGap_us =				MinGap_us;
			constraints.MinClick_us =			MinClick_us;
			constraints.MaxClick_us =			MaxClick_us;
			constraints.FrameLength_samples =	FrameLength_samples;
			constraints.HPFilter =				HPFilter;
			constraints.Noise_Buffer_Max_s =	Noise_Buffer_Max_s;
			constraints.Noise_Buffer_Min_s =	Noise_Buffer_Min_s;
			constraints.binWidth_Hz =			binWidth_Hz;

			Plot_info.Plot=Plot;
			Plot_info.pingH=pingH;
			Plot_info.perH=perH;
			Plot_info.remH=remH;

			[Absolute_Click_Indx ClickSeconds ...
			 Noise_Group_Indx Noise_Group_Averages...
			 Click_WAV_data Click_Teager_data ...
			 Sonar_Pings Clicks_to_reject] = ...
					dtFindClicksNoise(fid, hdr, channel, FileTypes(idx), DataFile,...
						LabelFile, constraints, Plot_info, window,SpecRange,...
						AdjustedTransferFunction, SaveNoise);
	% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
	% -------------------------------- END Find Possition of Clicks --------------------%
	% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

			if isempty(Absolute_Click_Indx)
				continue;
			end

			if isempty(Noise_Group_Indx) && SaveNoise
				fprintf('File #%i %s has no discernable noise groups\n', idx, DataFile);
				continue;
			end
			fprintf(log_fid, '%i --> ', size(Absolute_Click_Indx,1));

			if ~isempty(NoiseExt) && SaveNoise
				NoiseFile = ioGetWriteNameViewpath(...
					fullfile(file_save_path, [basename, FeatureId, NoiseExt]), Viewpath, true);
				SpecFile = ioGetWriteNameViewpath(...
					fullfile(file_save_path, [basename, FeatureId, '.czpwr']), Viewpath, true);
			end

			if ShowClickProgression
				waitbar(0,ProgressC,sprintf('Processing 0 of %d',size(Absolute_Click_Indx,1)));
			end
			% Saving artificial ping locations if requested
			if PingAnnotH ~= -1
				for i=1:size(Sonar_Pings,1)
					fprintf(PingAnnotH, '%f %f %f\n', Sonar_Pings(i,1), Sonar_Pings(i,2), Sonar_Pings(i,3));
				end
			end

			LowResClickCount = length(Absolute_Click_Indx);
			if LowResClickCount == 0
			  disp_msg(sprintf('HighRes detection: no clicks in file %s', DataFile));
			  % close annotation files if opened
			  closeFiles([ClkAnnotH, GrpAnnotH, DurAnnotH, PingAnnotH]);
			  continue;
			end


			% Run detector on each click
			pcmFrames = [];             % Framed signal (when ExtractPcm true)
			Features = [];           % Spectra of each frame (always, but uses
										% rectangular window when ExtractPcm true)
			Features2 = [];
			Noise_Spectrums = [];
			SpecFeatures = [];
			ClicksInFile = 0;      % Number detected clicks in this file
			ClicksInToken = 0;   % Number detected clicks relative to
										% current token
			ClippedClickCount = 0;      % Number of "clipped" clicks in file, used 1235

			NumberStarts = size(Absolute_Click_Indx,1);
			current_noise_group = 1;

            % Todo - Retrieve the project and site in a more elegant
            % fashion.  
			slash = strfind(DataFile,'/');
			try
				begin_out = strfind(DataFile(slash(end)+1:end),'CAL')+3+slash(end);
				end_out = strfind(DataFile(begin_out:end),'_')-1 + begin_out;
				outting_site = DataFile(begin_out:end_out(1)-1);
			catch e
				% If the filename does not contain the site information
				%  use the file index number
				outting_site = char(idx);
			end

			% Can features be continued from the previous file?
            % todo:  Note that this should perhaps take into account time
            % differences etc.
			if ~strcmp(outting_site, last_outing)
				last_outing = outting_site;
				average_following_noise = [];
			end
			if SaveNoise
				average_leading_noise = Noise_Group_Averages{current_noise_group};
			end
% 			AcceptedClicks = [];
% 			RejectedClicks = [];
	% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
	% --------------------------------- START PROCESSING EACH CLICK ---------------------%
	% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
		for c = 1:NumberStarts
				if ShowClickProgression
					waitbar((c-1)/size(Absolute_Click_Indx,1), ProgressC, ...
						sprintf('Processing %d of %d', c, size(Absolute_Click_Indx,1)));
				end
				% Extract feature data from noise frames for noise compensation
				if SaveNoise 
					while Absolute_Click_Indx(c,1) > Noise_Group_Indx(current_noise_group,2) &&...
							current_noise_group < size(Noise_Group_Indx,1)
						current_noise_group = current_noise_group+1;
						average_following_noise = average_leading_noise;
						average_leading_noise = ...
							Noise_Group_Averages{current_noise_group};
					end
				end % If SaveNoise


				% Frequency domain tests ---------------------
				% Extract frequency information from clicks and decide whether or
				% not to prune

				% Extract frames
				data = Click_WAV_data{c};

				[Frames, WindowPwr] = dtExtractFrames2([1, length(data)], ...
					data, @blackmanharris, FFTSize, FrameAdvance_samples, MaxFramesPerClick);

				% Need dft for power and cepstral coefficients
				% process the click
				fftcoef = fft(Frames);
				% Set a minimum floor so we don't end up with
				% any log 0 values.
				fftcoef(fftcoef == 0) = LogFloor;
				fftcoef = fftcoef(SpecRange,:)/binWidth_Hz;

				%Convert fftcoef to pwr (from mkspecgram.m)
				% removed +/- 3
				if ~isempty(TransferFunction)
					%pwr = 10*log10(AdjustedTransferFunction.*abs(fftcoef).^2);
					pwr = 10*log10(abs(fftcoef).^2) + AdjustedTransferFunction;
				else
					pwr = 20*log10(abs(fftcoef)) - WindowPwr + 3;
				end

				% Check "Saturation" of click
				if SaveNoise
					MeanNoise =  10*log10(mean([average_leading_noise, average_following_noise],2));
					normalized_pwr = pwr - MeanNoise;
				else
					normalized_pwr = pwr;
					MeanNoise = [];
				end
				BinsOverThreshold = sum(normalized_pwr > Threshold_dB);

				[~, pfIdx] = max(normalized_pwr);
				peakFreq_Hz = freq_kHz(pfIdx)*1000;

				GoodClickPass = ...
					BinsOverThreshold >= MinBins && BinsOverThreshold <= MaxBins && ...
					peakFreq_Hz >= LowPeakLimitHz && peakFreq_Hz <= HighPeakLimitHz && ...
					isempty(find(Clicks_to_reject == c, 1));

				if ~GoodClickPass
% 					RejectedClicks(:,end+1) = normalized_pwr;
					if Plot > 1
						printClickDetails(0);
					end
					continue; 
				end
				% end check saturation

% 				AcceptedClicks(:,end+1) = normalized_pwr;
				if Plot  % Show spectrum of signal and noise
					printClickDetails(1);
				end

			  LogicalStopFrame = size(Features, 2) - 1;
			  if LogicalStopFrame > LogicalStartFrame
				dtWriteEntry(LogicalStartFrame, LogicalStopFrame);
				LogicalStartFrame = LogicalStopFrame + 1;
				LogicalStart_s = CurrentClick_s;
			  end

				% process clicks not marked to be skipped
				CurrentClick_s = ClickSeconds(c,1);%ClickRegion_s + Absolute_Click_Indx(c,1)/hdr.fs; % start time
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
						dtWriteEntry(LogicalStartFrame, LogicalStopFrame);
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

			  LogicalLast_s = ClickSeconds(c,2);
			  if ClkAnnotH ~= -1  % write individual click annotations?
				% More likely to examine unfiltered data
				% Account for filter delay in timings
				fprintf(ClkAnnotH, '%f %f C%dT%d\n', ...
						CurrentClick_s, ...
						LogicalLast_s, ...
						ClicksInToken, LogicalFileIdx);
			  end

			if ~ isempty(Frames)
				% Compute duration of click in microsec
				us = (diff(Absolute_Click_Indx(c,:), [], 2)+1) * (us_per_s / hdr.fs);
				Durations_us(end+1) = us;
				% Cumulative counts across all files
				CumClicksProcessed = CumClicksProcessed + 1;
				FramesN = size(Frames, 2);
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
						packets = FWT_ATrou(Frames(:,1), SplitLevel);
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
					case 'pwr'
						if SpectralMeansSub
							Features = [Features,  pwr - MeanNoise];
						else
							Features = [Features,  pwr];
						end
					case 'cc'
						if CepstralMeansSub
							Features = [Features, ...
								gencepstra(pwr) - gencepstra(MeanNoise)];
						elseif SpectralMeansSub
							Features = [Features, ...
								gencepstra(pwr - MeanNoise)];
						else
							Features = [Features, ...
								gencepstra(pwr)];
						end

				end
				Features2 = [Features2, gencepstra(pwr)];

				if ~isempty(NoiseExt) && SaveNoise
					Noise_Spectrums = [Noise_Spectrums,  MeanNoise];
					SpecFeatures = [SpecFeatures,  pwr - MeanNoise];
				end

				if ExtractPcm
				pcmFrames = [pcmFrames, Frames];
				end
			else
				ClicksInToken = ClicksInToken - 1;
			end
		end 
	% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
	% ---------------------------------- END PROCESSING EACH CLICK -----------------------------------%
	% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% figure; subplot(3,1,1); imagesc(RejectedClicks); title(sprintf('Rejected Clicks - %i', size(RejectedClicks,2)));
% 		subplot(3,1,2); imagesc(AcceptedClicks); title(sprintf('Accepted Clicks - %i', size(AcceptedClicks,2)));
% 		subplot(3,1,3); imagesc(Features(1:10,:)); title(sprintf('Features - %i', size(Features,2)));
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
				if strcmp(options.type, 'cc')
					if length(SpecRange)-1 > MaxCep
						CepRange = 1:MaxCep;
					else
						CepRange = 1:length(SpecRange)-1;
					end
					Features = Features(CepRange,:);
				end

				spWriteFeatureDataHTK(FeatureFile, Features', FrameAdvance_ms, 'USER');
				spWriteFeatureDataHTK(FeatureFile2, Features2', FrameAdvance_ms, 'USER');

				if ~isempty(NoiseExt) && SaveNoise
					spWriteFeatureDataHTK(NoiseFile, Noise_Spectrums', FrameAdvance_ms, 'USER');
					spWriteFeatureDataHTK(SpecFile, SpecFeatures', FrameAdvance_ms, 'USER');
				end
			end  % if ClicksInFile

			if isempty(Features)
				FrameCount = 0;
			else
				% Write out last logical file if multiple clicks found since
				% last logical file written
				LogicalLastFrame = size(Features, 2) - 1;
				if LogicalStopFrame > LogicalStartFrame
					dtWriteEntry(LogicalStartFrame, LogicalLastFrame);
				end
				FrameCount = size(Features, 2);
			end

			% set up for using Triton disp_msg
			msg = sprintf(['%s - high res %d, low res %d, delta %d, ', ...
						  'clip %d, frames %d, tokens %d'], ...
						  DataFile, ClicksInFile, LowResClickCount, ClicksInFile - LowResClickCount,...
						  ClippedClickCount, FrameCount, LogicalFileIdx);
			disp_msg(msg);
			% close annotation files if opened
			if ClkAnnotH ~= -1, fclose(ClkAnnotH); end
			if GrpAnnotH ~= -1, fclose(GrpAnnotH); end
			if PingAnnotH ~= -1, fclose(PingAnnotH); end
			if DurAnnotH ~= -1
				fprintf(DurAnnotH, '%f\n', Durations_us);
				Durations_us = [];
				fclose(DurAnnotH);
			end


			fprintf('File #%i : %s - %i / %i\n',idx, sectohhmmss(toc), size(Features,2), NumberStarts);
			fprintf(log_fid, '%i -- %s\n', size(Features,2), sectohhmmss(toc));

		
% 		catch err
% 			fprintf(log_fid, 'ERROR!\n');
% 			fprintf(log_fid, '\tID: [%s] %s\n', err.identifier, err.message);
% 			fprintf(log_fid, '\tLine %i in file %s\n', err.stack(1).line, err.stack(1).name);
% 		end
    end  % end of all files
		
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
	fprintf(log_fid, 'All finished!!!');
    if log_fid ~= 1  
        fclose(log_fid);  % close if not sent to Matlab window
    end
	if ShowClickProgression
		delete(ProgressH);    % remove progress bar
		delete(ProgressC);
	end

    disp_msg(sprintf('Total clicks %d, Frames/click: %.2f ',  ...
        CumClicksProcessed,  CumFrames/CumClicksProcessed));
    if HTKConfigFile
        HTK = ioOpenViewpath(HTKConfigFile, Viewpath, 'w');
        fprintf(HTK, '#Extraction Options: %s\n', FeatureExt);
        fprintf(HTK, 'TARGETKIND = USER\n');
        fprintf(HTK, 'NUMCEPS = %d # Means subtraction: %s\n',  ....
            min(length(SpecRange)-1,MaxCep), MeansSub);
        fprintf(HTK, 'TARGETRATE = %d  # Frame Advance %f us, Length %f us,',  ...
            FrameAdvance_us*10, FrameAdvance_us, FrameLength_us);
        fprintf(HTK, 'Group MaxSep %f s MaxLen %f s\n',  MaxSep_s, MaxClickGroup_s);
        if ~isempty(varargin)
            fprintf(HTK, '# dtHighResClickBatch OptArgs: ');
            printargs(HTK, varargin{:});
            fprintf(HTK, '\n');
        end
        fclose(HTK);
    end

    disp_msg(sprintf(['High resolution click detections complete ',  ...
        '(%d files, %s)'], N, sectohhmmss(toc)));
end
