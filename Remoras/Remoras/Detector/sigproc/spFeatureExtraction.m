function [Features, EndpointedSignal] = ...
    spFeatureExtraction(Signal, SampleRate, varargin)
% [Features, EndpointedSignal]  = 
% spFeatureExtraction(Signal, SampleRate, ParameterList)
%
% Given a matrix Signal where each column is one channel of an audio
% stream, generate a set of feature vectors.  Unless a specific channel
% is specified (see 'Channel' below), all channels are summed and the combined
% channel signal is processed.
% 
% The result of feature extraction is returned in Features.  If the
% caller wishes to manipulate the endpointed speech, the presence of
% output argument EndpointedSignal will result in the endpointed signal
% being returned as well.
%
% The following optional parameters are recognized:
%
%	'Channel', N - Select which channel to analyze
%		Channels are numbered starting from 0.
%		The special value of -1 means that all channels should
%		be combined (by addition) before feature extraction.
%	'Endpoint', String|Cell array - 
%		To use an endpointer with default arguments, simply
%		specify the name of the endpointer in string.  To pass
%		arguments to the endpointer, use a cell array 
%		with the first argument as the endpointer name and the 
%		subsequent arguments as arguments.  See individual 
%		endpointer functions for valid arguments.
%
%		Valid endpointers:
%		'none' - no endpointing (default)
%		'kubala' - use the NIST/Kubala endpointer
%		'raj/singh' - use the Raj/Singh CMU endpointer
%		'li' - use the Li, Zheng, Tsai & Zhou AT&T Labs endpointer
%
%	'Spectrum', SpectrumVarArgList - cell array of optional arguments
%		See spCepstrum for details.
%	'Cepstrum', CepstrumVarArgList - cell array of optional arguments
%		See spCepstrum for details.
%	'LowSNRThreshdB', N - Low energy threshold.  Frames with
%		SNR under N dB will be discarded.  Defaults to off (-Inf).
%	'MaxTime', N - Maximum time in seconds of speech data to process
%		from each file.  (default 30)
%	'Preemphasis', Alpha - Apply a first order preemphasis network
%		(low pass filter)  before computing the cepstrum.  Alpha
%		indicates the value of y[n] = x[n] - AlphA*x[n-1].
%	'Framing' {AdvanceMS, LengthMS, Window} -
%		Frame advance in MS
%		Frame length in MS
%		Window operator applied to each frame.  See spWindow()
%			for details.
%		Default:  {10, 25, 'hamming'}
%
% Example (note that that changes to spCepstrum could render
%	portions of this example incorrect):
%
%   [cepstrum pcmep] = ...
%	spFeatureExtraction(pcm, 8000, 'Endpoint', 'li', ...
%	'Framing', {10, 25, 'hamming'}, ...
%	'Spectrum', {'Method', 'dft', 'Points', 512} , 
%	'Cepstrum', {'Method', 'mel', 'Coefficients', 18, ...
%		     'Filters', 24, 'MelBand', [200, 3500]});
%
%	For a 8 kHz signal, endpoints with the Li et al. endpointer
%	and frames the signal with 25 MS window which advances every
%	10 MS.  Each frame is windowed by a Hamming function.  The
%	spectrum is computed with a 512 point dft, and a 18 MFCC
%	+ energy are extracted after the application of a 24 band
%	Mel filter which spans 200-3500 Hz.
%
% This code is copyrighted 1997-2004 by Marie Roch.
% e-mail:  marie.roch@ieee.org
%
% Contains contributions by Yanliang Cheng
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 

error(nargchk(2, inf, nargin));

% set defaults
MaxTimeSec = Inf;	% Maximum amount of time to process
FrameAdvanceMS = 10;
FrameLengthMS = 25;
FrameWindowOperator = 'hamming';
Alpha = 0;
Features.Attribute.Endpoint = 'none';
EndpointedFileDir = [];
CepstrumArgs = {};
SpectrumArgs = {};
Channel = -1;	% which channel to process?  (default all)
FilenameFormat = '%s';
LowSNRThresh = -Inf;	% drop frames -N db beneath the noise floor
EndpointArgs = {};
FrameCountThreshold = 2;

n=1;
while n <= length(varargin)
  switch varargin{n}
   case 'Channel'
    Channel = varargin{n+1}; n=n+2;
   case 'Spectrum'
        if ~ iscell(varargin{n+1})
      error(sprintf('Argument to %s must be a cell array', varargin{n}))
    end
    SpectrumArgs = {varargin{n}, varargin{n+1}}; n=n+2;
   case 'Cepstrum'
    if ~ iscell(varargin{n+1})
      error(sprintf('Argument to %s must be a cell array', varargin{n}))
    end
    CepstrumArgs = {varargin{n}, varargin{n+1}}; n=n+2;
   case 'Endpoint'
    Features.Attributes.Endpoint = varargin{n+1}; n=n+2;
   case 'FilenameFormat'
    FilenameFormat = varargin{n+1}; n=n+2;
   case 'LowSNRThreshdB'
    LowSNRThresh = varargin{n+1}; n=n+2;
   case 'MaxTime'
    MaxTimeSec = varargin{n+1}; n=n+2;
   case 'Framing'
    [FrameAdvanceMS, FrameLengthMS, FrameWindowOperator] = ...
	deal(varargin{n+ 1}{:});
    n=n+2;
   case 'Preemphasis'
    Alpha = varargin{n+1}; n=n+2;
   otherwise
    error(sprintf('Bad optional argument: "%s"', varargin{n}));
  end
end

MaxTimeSamples = MaxTimeSec * SampleRate;

FrameRate = 1000 / FrameAdvanceMS;

% Check for correct size signal
if size(Signal, 1) == 1
  warning('Signal with only one sample.  Did you transpose the matrix?');
end

if Channel == -1
  Signal = sum(Signal, 2);	% merge channels
  Features.Attribute.Source.Channel = 'all';
  Channel = 1;	% Merged signal in first & only channel 
else
  Features.Attribute.Source.Channel = char(Channel + 'A' - 1);
end
  
[SignalN, ChannelCount] = size(Signal);

% Preemphasize if requested
if Alpha
  Signal = spPreemphasis(Signal, Alpha);
end
    
% Framing parameters
FrameAdvSamples = spMS2Sample(FrameAdvanceMS, SampleRate);
FrameLengthSamples = spMS2Sample(FrameLengthMS, SampleRate);
[FrameCountWhole, FrameCountPartial] = ...
    spFrameCount(SignalN, FrameAdvSamples, FrameLengthSamples);

if FrameCountWhole < FrameCountThreshold
  % Too few frames to process.
  Features.Attribute.Failure = ...
      sprintf(['Only %d frames of data (%d required)'], ...
              FrameCountWhole, FrameCountThreshold);
  EndpointedSignal = [];
  return;
end

% Analyze signal and endpoint if needed
ChannelPcm16 = int16(Signal(:, Channel));

ChannelInfo = spEnergyLevels(ChannelPcm16, SampleRate, ...
			     FrameAdvanceMS, FrameLengthMS);


if nargout > 1
  [Indices, Samples, EndpointedSignal] = ...
      spEndpoint(Signal(:,Channel), SampleRate, ...
                 Features.Attribute.Endpoint, ...
                 'Framing', {FrameAdvanceMS, FrameLengthMS, FrameWindowOperator});
else
  [Indices, Samples] = ...
      spEndpoint(Signal(:,Channel), SampleRate, ...
                 Features.Attribute.Endpoint, ...
                 'Framing', {FrameAdvanceMS, FrameLengthMS, FrameWindowOperator});
end

% Extract endpointed signal if requested
if nargout > 1
  switch Endpoint
   case 'none'
    EndpointedSignal = Signal(:, Channel);
   otherwise
    EndpointedSignal = spExtractFromIndices(Indices, Signal(:, Channel));
  end
end

% Most of the endpointers are external programs and their frame counts
% may not always agree with ours if they use partial frames.  We'll
% extend the energy signal if necessary.  Currently, this is only
% an issue for the Raj/Singh CMU endpointer.
if (Indices(end, 2) > length(ChannelInfo.FrameEnergy)) 
  % extend by number of needed frames
  Needed = Indices(end, 2) - length(ChannelInfo.FrameEnergy) ;
  ChannelInfo.FrameEnergy(end+1:end+Needed) = ...
      repmat(ChannelInfo.FrameEnergy(end), Needed, 1);
end

SourceTime = (1:Indices(end,2))/FrameRate';
ChannelInfo.SourceTimeSecs = spExtractFromIndices(Indices, SourceTime);
ChannelInfo.SourceFrameIndices = Indices;
Features.Attribute = ChannelInfo;

FramedChanPcm = ...
    spExtractFromIndices(Indices, Signal(:, Channel), 'Frame', 1,  ...
			 'Framing', ...
			 [SampleRate, FrameAdvanceMS, FrameLengthMS]);

      
      
if ~ strcmp(FrameWindowOperator, 'none')
  FramedChanPcm = spWindow(FramedChanPcm, FrameWindowOperator);
end

% In addition, if energy information is available, drop any
% frames which fall under a low SNR estimate.  Note that as the
% energy estimator performs the estimate without DC bias but does
% not actualy remove the bias, it is possible to have a frame of all
% 0s with a non-zero energy estimate.
% 
% In most cases, frames of 0s will still fall beneath the low
% energy estimate and be discarded, but if the DC bias is
% significant enough to raise these zero frames above the noise 
% cutoff, zero index frames could be eliminated explicitly
% with the following statement:
%      ZeroIndices = find(sum(FramedChanPcm) == 0);
% ZeroIndices could then be unioned with with the LowEnergy
% frames.

% Drop any frames which fall below the low SNR estimate
% if the FrameEnergy is available.

if LowSNRThresh > -Inf
  
  if ~ isfield(ChannelInfo, 'FrameEnergy')
    error(['Energy fields not computed with extraction method' ...
	   ' specified.  Unable to discard LowSNRThreshdB frames'])
  end
  
  LowSNRIndices = ...
      find((ChannelInfo.FrameEnergy - ...
	    ChannelInfo.Noise) < LowSNRThresh);
  
  
  if (~ isempty(LowSNRIndices))
    fprintf([' Channel %d:  discarding %d frames with SNR ', ...
	     '< %d (%.1f%% of total)\n'], ...
	    Channel, length(LowSNRIndices), LowSNRThresh, ...
	    length(LowSNRIndices) / ...
	    length(ChannelInfo.FrameEnergy));
    FramedChanPcm(:,LowSNRIndices) = [];
    ChannelInfo.FrameEnergy(LowSNRIndices) = [];
    if isfield(ChannelInfo, 'SourceTimeSecs')
      ChannelInfo.SourceTimeSecs(LowSNRIndices) = [];
    end
  end
end

Features.Data{1} = spCepstrum(FramedChanPcm, ...
			      SpectrumArgs{:}, CepstrumArgs{:}, ...
			      'SampleRate', SampleRate);
Features.Data{1} = Features.Data{1}';

Features.Attribute = ChannelInfo;
if length(SpectrumArgs) > 1
  Features.Attribute.SpectrumArgs = SpectrumArgs{2};
end
if length(CepstrumArgs) > 1
  Features.Attribute.CepstrumArgs = CepstrumArgs{2};
end
Features.Attribute.Source.SampleRate = SampleRate;
Features.Attribute.PassBands = 1;
Features.Attribute.CepstralSpacingMS = FrameAdvanceMS;
Features.Attribute.CepstralLengthMS = FrameLengthMS;


