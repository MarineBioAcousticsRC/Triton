function [DataFiles LabelFiles] = dtLTSA_batch(LTSAHdr, DetParams, Files)

% [DataFiles LabelFiles] = dtLTSA_batch(LTSAHdr, DetParams, Files)
%
% Given data structures representing an LTSA, long term detection
% parameters, and a list of files which are members of the LTSA,
% run batch mode LTSA detection. 
%
% Returns a list of the audio source files for the spectral
% averages and a list of label files that are created by
% this function indicating where signal has been detected.
%
% Maintained by CVS - do not modify
% $Id: dtLTSA_batch.m,v 1.5 2007/09/05 23:53:32 mroch Exp $

global PARAMS

DataExt = '(\.x)?\.wav';   % data files must end in this regular expression
LabelExt = '.lt';   % Long term detection label extension

SecPerHr = 3600;    % secs per hour

% Not sure we need this, find out from Sean what it does
% Initial times for both formats:
LTSAHdr.ltsa.save.dnum = LTSAHdr.ltsa.start.dnum;
LTSAHdr.ltsa.start.dvec = datevec(LTSAHdr.ltsa.start.dnum);

% Set5 up optional detection arguments based upon parameters
if DetParams.ignore_periodic
  args = {'LowPeriod_s', DetParams.LowPeriod_s, ...
          'HighPeriod_s',DetParams.HighPeriod_s };
else 
  args = {};
end

MeanAve_s = DetParams.MeanAve_hr * SecPerHr;
MeanPad_s = MeanAve_s / 2;       % s of padding on either side

% Find indices of files in the LTSA
% Some of the wave formats (xwav) support multiple internal "raw files".
% Find the physical files which all have raw file ids of 1.   
FileStarts = find(LTSAHdr.ltsahd.rfileid == 1);
FileEnds = [FileStarts(2:end) - 1, size(LTSAHdr.ltsahd.rfileid, 2)];
processed = 0;
N = length(Files);
disp_msg(sprintf('Running LTSA batch detection: %d files', N));
tic;  % Note start time
ProgressH = [];
for idx = 1:length(FileStarts)
  
  if isempty(find(strcmp(LTSAHdr.ltsahd.fname{idx}, Files)))
    continue    % Not in list of files to process, skip
  end
  
  processed = processed + 1;
  ProgressTitle = sprintf('LTSA batch detection: %d of %d: %s', ...
                          processed, N, ...
                          strrep(LTSAHdr.ltsahd.fname{idx}, '_', '\_'));
  if ~ isempty(ProgressH)
    waitbar((idx-1)/N, ProgressH, ProgressTitle);
  else
    ProgressH = waitbar(0, ProgressTitle);
  end
  % Although we are only interested in processing the current file,
  % to estimate noise properly we may need to look at the file before and
  % after.
  EstNoiseAcrossFiles = true;   % kludge for now...
  if EstNoiseAcrossFiles
    CumPrev = 0;        % Cumulative time previous to segment of interest
    StartIdx = idx;
    while StartIdx > 1 && CumPrev < MeanPad_s
      CumPrev = CumPrev + LTSAHdr.ltsa.dur(StartIdx);
      StartIdx = StartIdx - 1;
    end
    StopIdx = idx;
    CumPast = 0;  % Cumulative time past the segment of interest
    while StopIdx < length(FileEnds) && CumPast < MeanPad_s
      CumPast = CumPast + LTSAHdr.ltsa.dur(StopIdx);
      StopIdx = StopIdx + 1;
    end
    
  else
    StartIdx = idx;
    StopIdx = idx;
  end
  % Read the spectral data
  fid = fopen(fullfile(LTSAHdr.ltsa.inpath, LTSAHdr.ltsa.infile));
  fseek(fid, LTSAHdr.ltsa.byteloc(StartIdx), -1);    % position for read
  pwr = fread(fid, [LTSAHdr.ltsa.nf, ...
                    sum(LTSAHdr.ltsa.nave(StartIdx:StopIdx))], 'int8');
  % LTSA Detector
  candidates = ...
      dtLT_signal(pwr, ...
                  DetParams.ignore_periodic,...
                  DetParams.HzRange,...
                  LTSAHdr.ltsa.f, ...
                  LTSAHdr.ltsa.tave, ...
                  DetParams.Threshold_dB,...
                  DetParams.MeanAve_hr, ...
                  false, args{:});
 
  % Detections will have been run on entire spectrogram loaded which may
  % contain padding for the rolling mean.
  
  % Determine range over which interesting (no padding) candidates lie
  StartCFrame = sum(LTSAHdr.ltsa.nave(StartIdx:FileStarts(idx))) - ...
      LTSAHdr.ltsa.nave(FileStarts(idx))+1;
  EndCFrame = sum(LTSAHdr.ltsa.nave(StartIdx:FileEnds(idx)));
  
  % Remove candidates from extra mean frames
  % convert candidates from frames to s
  % Don't add one frame to candidate starts to handle 0/1 (htk/matlab) index issue
  % (Adjusted when subtracting off StartCFrame)
  % Add one frame to end frame as we want starting time of one frame
  % past the last detected frame.
  
  CurrentFrames=find(candidates(:,2)>StartCFrame & candidates(:,1)<EndCFrame);
   
  candidates_s = candidates(CurrentFrames,:);
  if ~isempty(candidates_s)
    candidates_s(:,2) = candidates_s(:,2) + 1; % This used to be after the
                                               %subtraction of StartCFrame,
                                               %but there were problems if
                                               %the last candidate occurred
                                               %at the end of the file.  Not
                                               %sure if this needed to occur
                                               %later.
    % Prune candidates lying beyond the start/end of the file
    if candidates_s(1,1)<StartCFrame, candidates_s(1,1)=StartCFrame; end
    if candidates_s(end,2)>EndCFrame, candidates_s(end,2)=EndCFrame; end
    candidates_s=candidates_s-StartCFrame;
    
    candidates_s = candidates_s * LTSAHdr.ltsa.tave;
  end
  % write out HTK label file
  DataFiles{idx} = LTSAHdr.ltsahd.fname{FileStarts(idx)};
  LabelFiles{idx} = regexprep(DataFiles{idx}, DataExt, LabelExt);
  if strcmp(DataFiles{idx}, LabelFiles{idx})
    error('Unable to write label file for %s, would overwrite file', ...
          LabelFiles{idx});
  end
  ioWriteLabel(LabelFiles{idx}, candidates_s, 'ltsa', 'Binary', true);
end
if ~ isempty(ProgressH)
  delete(ProgressH);
end
disp_msg(sprintf('LTSA batch detection complete (%d files, %s)', ...
                 N, sectohhmmss(toc)));
