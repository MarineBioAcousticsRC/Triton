function s = spSignal(signal, SamplingRate)
% spSignal - Signal class constructor

if nargin == 0
  % Set 
  s.Signal = [];
  s.SampleRate = 1;
  s.FrameAdvanceMS = 0;
  s.FrameLengthMS = 0;
  s = class(s, 'spSignal');
elseif nargin == 1 && isa(varargin{1}, 'spSignal')
  s = varargin{1};      % Copy object
elseif isnumeric(vargin{1}) && nargin <= 2
  s.Signal = signal;
  if nargin > 1
    s.SampleRate = varargin{2};
  else
    s.SampleRate = 1;
  end
  s.FrameAdvanceMS = 0;
  s.FrameLengthMS = 0;
  s = class(s, 'spSignal');
else
  error('Bad arguments to constructor')
end

