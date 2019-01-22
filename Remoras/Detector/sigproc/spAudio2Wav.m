function spAudio2Wav(ConversationIds, varargin)
% spAudio2Wav(ConversationIds, OptionalArguments)
% Convert audio files in InDir to Wav files in OutDir with possible
% reprocessing.
%
% OptionalArguments
%       'InFormatString', String - printf style string to format
%               ConversationIds for reading.  default '%s'
%               Example: '/lab/speech/corpora/timit/sphere/%s.sph'
%       'OutFormatString', String - printf style string to
%             format ConversationIds for writing.  default '%s'.
%             Example:  '/lab/speech/corpora/timit/mono/%s.wav'
%       'Lowpass', [PassBandEnd, PassRippledB, StopBandStart,
%               StopRippledB]
%       'Resample', Fs - Change sampling rate to Fs.  Note that
%               you need not provide a Lowpass argument for
%               resampling as this is done separately using
%               the Matlab resample function.
%       'Merge' - Merge channels by averaging.
%

InFormat = '%s';    % defaults
OutFormat = '%s';
FilterArgs = [];
Channel = 'separate';
ResampleFs = [];

k=1;
while k <= length(varargin)
  switch varargin{k}
   case 'InFormatString'
    InFormat = varargin{k+1}; k=k+2;
   case 'OutFormatString'
    OutFormat = varargin{k+1}; k=k+2;
   case 'Lowpass'
    FilterArgs = varargin{k+1}; k=k+2;
   case 'Merge'
    Channel = 'merge'; k=k+1;
   case 'Resample'
    ResampleFs = varargin{k+1}; k=k+2;
  end
end

PreviousFs = NaN;
for idx=1:length(ConversationIds)
  File = sprintf(InFormat, ConversationIds{idx});
  fprintf('Processing %s\n', ConversationIds{idx});
  [pcm, info] = corReadAudio(File);
  
  if strcmp(Channel, 'merge')
    if size(pcm, 2) > 1
      pcm = mean(pcm, 2);
    end
  end
  
  if ~ isempty(FilterArgs)
    % Construct the low pass filter if needed
    if PreviousFs ~= info.SampleRate
      % New/changed sample rate
      PreviousFs = info.SampleRate;
      % Rebuild the filter
      LPFilter = BuildLowPass(info.SampleRate, FilterArgs);
    end
    
    % low pass filter the signal
    pcm = filter(LPFilter, 1, pcm);
  end
  
  if ~ isempty(ResampleFs)
    % Determine resampling ratio if needed
    if PreviousFs ~= info.SampleRate
      Denominator = gcd(info.SampleRate, ResampleFs);
      Old = info.SampleRate / Denominator;
      New = ResampleFs / Denominator;
    end
    pcm = resample(pcm, New, Old);
    TargetFs = ResampleFs;
  else
    TargetFs = info.SampleRate;
  end
  
  OutFile = sprintf(OutFormat, ConversationIds{idx});
  spWriteWav16(OutFile, pcm, TargetFs);
  
  previousFs = info.SampleRate;
end

  

function LPFilter = BuildLowPass(Fs, FilterArgs)
% BuildLowPass(Fs, FilterArgs)
% Construct a low pass filter
% Fs - SampleRate
% FilterArgs - [PassBandEnd, PassRippledB, StopBandStart,
%               StopRippledB]
% 

% Where does the pass band end and the stop band start?
EdgeFreqs = [FilterArgs(1), FilterArgs(3)];

% Sample rate
Nyquist = Fs / 2;

% Filter edges normalize to Nyquist.
NormEdgeFreqs = EdgeFreqs / Nyquist;

% How much ripple in each?
PassBand_dB = FilterArgs(2);
StopBand_dB = FilterArgs(4);

PassBand_deviation = (10^(PassBand_dB/20) - 1) / ...
    (10^(PassBand_dB/20) + 1);
StopBand_deviation = 10 ^ (-StopBand_dB / 20);

% Response
MagnitudeResponse = [1 0];

% Desgn low pass filter using Parks-McClellan/Remez
DesignParameters = firpmord(NormEdgeFreqs, MagnitudeResponse, ...
                            [PassBand_deviation, StopBand_deviation], ...
                            Fs, 'cell');
LPFilter = firpm(DesignParameters{:});

