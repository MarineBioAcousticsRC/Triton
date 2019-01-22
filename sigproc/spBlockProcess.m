function Output = spBlockProcess(Operator, Input, Output, Transient, ...
                                 BlockSize)
%
%
% Transient - [Starting Ending] or [Both]
% N - Length of 

if nargin < 5
  BlockSize = 10000;
end

if max(Transient) > BlockSize
  error('BlockSize must be larger than Transient')
end

N = length(Input);

if isscalar(Transient)
  % length of starting & stopping transients
  TranStart = Transient;        
  TransEnd = Transient;
elseif prod(size(Transient)) ~= 2
  error('Transient must be scalar or 2 dim vector')
else
  TransStart = Transient(1);
  TransStop = Transient(2);
end  

SrcBegin = 1;           % input boundaries
SrcEnd = BlockSize + TransStop;
BlockBegin = 1;         % data to be stored in this range
BlockEnd = BlockSize;
SinkBegin = 1;          % output boundaries
SinkEnd = BlockSize;

progressbar(0)
WholeBlocks = floor(N / BlockSize);     % approximation for progress bar
LastPct = 0;

n=1;
while SrcEnd < N

  % perform operation on n'th block
  data = Operator(Input(SrcBegin:SrcEnd));
  
  % save block
  Output(SinkBegin:SinkEnd) = data(BlockBegin:BlockEnd);
  
  % set up next block
  SrcBegin = n*BlockSize - TransStart;
  SrcEnd = (n+1)*BlockSize + TransStop - 1;
  
  BlockBegin = TransStart(1)+1;
  BlockEnd = BlockBegin + BlockSize - 1;
  SinkBegin = n*BlockSize;
  SinkEnd = SinkBegin + BlockSize - 1;

  % update progress bar, but don't overdo it as
  % it can add significantly to run time
  Pct = n/WholeBlocks;
  if Pct - LastPct > .05
    progressbar(Pct)
    LastPct = Pct;
  end
    
  n=n+1;
end

% process last block
SinkEnd = N - TransStop;
data = Operator(Input(SrcBegin:end));
Output(SinkBegin:SinkEnd) = data(BlockBegin:(end - TransStop));

% zero out stopping transient
if SinkEnd < N
  Output(SinkEnd+1:end) = zeros(N-SinkEnd, 1);
end
  
progressbar(1);



