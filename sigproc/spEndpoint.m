function [FrameIndices, SampleIndices, EndpointedSignal] = ...
    spEndpoint(Signal, SampleRate, Method, varargin)
% [FrameIndices, SampleIndices, EndpointedSignal] = ...
%       spEndpoint(Signal, SampleRate, Method, OptArgs)
%
% Given a signal and an endpointing method, extract the speech portions
% of the signal.
% 
% Valid endpointers:
%	'none' - no endpointing (default)
%	'kubala' - use the NIST/Kubala endpointer
%	'raj/singh' - use the Raj/Singh CMU endpointer
%	'li' - use the Li, Zheng, Tsai & Zhou AT&T Labs endpointer
% 
% Method should contain either a string indicating which endpointer
% should be used or a cell array where the first argument is the
% endpointer name and the subsequent arguments are endpointer specific
% arguments detailed in the appoprriate endpoint functions.
%
% Optional arguments
%	'Framing' {AdvanceMS, LengthMS, Window} -
%		Frame advance in MS
%		Frame length in MS
%		Window operator applied to each frame.  See spWindow()
%			for details.
%		Default:  {10, 25, 'hamming'}
%
% This code is copyrighted 2003-2004 by Marie Roch.
% e-mail:  marie.roch@ieee.org
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 


SignalN = max(size(Signal));
Channels = min(size(Signal));

if Channels > 1
  error('Expected 1D vector for Signal');
end

error(nargchk(3, inf, nargin));

% set defaults
FrameAdvanceMS = 10;
FrameLengthMS = 25;
FrameWindowOperator = 'hamming';

n=1;
while n <= length(varargin)
  switch varargin{n}
   case 'Framing'
    [FrameAdvanceMS, FrameLengthMS, FrameWindowOperator] = ...
	deal(varargin{n+ 1}{:});
    n=n+2;
   otherwise
    error(sprintf('Bad optional argument: "%s"', varargin{n}));
  end
end

if iscell(Method)
  Endpoint = Method{1};
  EndpointArgs = Method{2:end};
else
  Endpoint = Method;
  EndpointArgs = {};
end

% Framing parameters
FrameAdvSamples = spMS2Sample(FrameAdvanceMS, SampleRate);
FrameLengthSamples = spMS2Sample(FrameLengthMS, SampleRate);
[FrameCountWhole, FrameCountPartial] = ...
    spFrameCount(SignalN, FrameAdvSamples, FrameLengthSamples);

switch Endpoint
 case 'none'
  % no action
  FrameIndices = [1 FrameCountWhole];
  
 case 'li'
  % Design a bandpass filter in the region likely 
  % contain speech energy
  
  EdgeFreqs = [100, 400, 3200, 3800];
  MagnitudeResponse = [0 1 0];
  PassBandRippledB = 15;
  StopBandAttenuationdB = 21;
  
  DeviationPB = ...
      (10^(PassBandRippledB/20)-1)/(10^(PassBandRippledB/20)+1);
  DeviationSB = 10^(-StopBandAttenuationdB/ 20);
  
  % Estimate the design parameters
  DesignParameters = remezord(EdgeFreqs, MagnitudeResponse, ...
			      [DeviationSB DeviationPB DeviationSB], ...
			      SampleRate, 'cell');
  BPFilter = remez(DesignParameters{:});
  BPSignal = filter(BPFilter, 1, Signal);
  
  BPEnergy = spEnergy(BPSignal, SampleRate, ...
		    FrameAdvanceMS, FrameLengthMS, 'Window', 'hamming');

  if length(EndpointArgs) == 0
    % fix contour problems and set more appropriate thresholds
    EndpointArgs = {'RepairContour', 1, 'Thresholds', [-3, 6.5], 'Gap', 25};
  end
  FrameIndices = spEndpointATT(BPEnergy, EndpointArgs{:});
  
 case 'raj/singh'
  if FrameAdvanceMS ~= 10
    error('Only FrameAdvanceMS = 10 currently supported for Raj/Singh endpointer');
  end
  
  FrameIndices = spEndpointCMU2(Signal, SampleRate, Channel);

  if isempty(FrameIndices)
    warning('Raj/Singh endpointer failed, invoking Kubala endpointer');
    FrameIndices = ...
	spEndpointKubala(int16(Signal), SampleRate, ...
                         [FrameAdvanceMS, FrameLengthMS]);
  end  
  
 case 'kubala'
  FrameIndices = ...
      spEndpointKubala(int16(Signal), SampleRate, ...
		       [FrameAdvanceMS, FrameLengthMS]);
  FrameIndices = FrameIndices + 1;	% C -> Matlab indices
  
 otherwise
  error('Unknown endpointing method')
end

if nargout > 1
  SampleIndices = FrameIndices * spMS2Sample(FrameAdvanceMS, SampleRate);

  if nargout > 2
    % Construct endpointed signal from indices
    switch Endpoint
     case 'none'
      EndpointedSignal = Signal;
     otherwise
      EndpointedSignal = spExtractFromIndices(SampleIndices, Signal);
    end
  end
end
