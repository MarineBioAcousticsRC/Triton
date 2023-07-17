function Energy = spEnergy(Signal, SampleRate, ...
			   FrameAdvanceMS, FrameLengthMS, varargin)
% Energy = spEnergy(Signal, SampleRate, FrameAdvanceMS, FrameLengthMS, ...
%		    Optional Arguments);
%
%
% Compute the energy in dB of each frame of the signal without windowing.
% Each frame is of duration FrameLengthMS and FrameAdvanceMS determine
% how far the window shifts between frames.
%
% Optional Arguments
%	'DCBiasRemoval', N 
%		If N ~= 0, remove mean of signal
%	'Window', String
%		Apply window to each frame.
%		Window Types:  'hamming', 'hanning', 'none'
%
% This code is copyrighted 2003 by Marie Roch.
% e-mail:  marie.roch@ieee.org
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 

if ~ utIsVector(Signal)
  error('Signal must be a vector');
end
  
SignalN = length(Signal);

% determine framing parameters
FrameAdvanceN = spMS2Sample(FrameAdvanceMS, SampleRate, 'Rounding', 'floor');
FrameLengthN = spMS2Sample(FrameLengthMS, SampleRate, 'Rounding', 'floor');

EndOfFrameOffset = FrameLengthN - 1;	% add to reach last sample in a frame

% Compute number of complete frames
FrameCount = fix((SignalN - FrameLengthN + FrameAdvanceN) / FrameAdvanceN);

% defaults
FloorValue = -100;	% Value to represent 0 energy
WindowType = 'none';
Windowing = 0;
DCBiasSubtraction = 0;

n=1;
while n < length(varargin)
  switch varargin{n}
   case 'DCBiasRemoval'
    DCBiasSubtraction = varargin{n+1}; n=n+2;
    if DCBiasSubtraction
      DCBias = mean(Signal);
    end
    
   case 'FloorValue'
    FloorValue = varargin{n+1}; n=n+2;

   case 'Window'
    WindowType = varargin{n+1}; n=n+2;
    Windowing = 1;
    switch WindowType
     case 'none'
      Windowing = 0;
     case 'hamming'
      Window = hamming(FrameLengthN);
     case 'hanning'
      Window = hanning(FrameLengthN);
     otherwise
      error(sprintf('Bad WindowType: "%s"', varargin{n}));
    end
    
   otherwise
    error(sprintf('Bad optional argument: "%s"', varargin{n}));
  end
end    


% Init
StartSample=1;
EndSample = StartSample + EndOfFrameOffset;
Energy = zeros(FrameCount, 1);

if DCBiasSubtraction
  Signal = Signal - DCBias;
end

for index=1:FrameCount

  if Windowing
    Sum = sum((Signal(StartSample:EndSample) .* Window) .^ 2);
  else
    Sum = sum(Signal(StartSample:EndSample) .^ 2);
  end

  if Sum
    Energy(index) = 10 * log10(Sum);
  else
    Energy(index) = FloorValue;
  end
  StartSample = StartSample + FrameAdvanceN;
  EndSample = EndSample + FrameAdvanceN;
end

  
