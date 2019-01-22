function filtered = spFilterMemMap(tf, InputWaveForm, FilteredFilename)

blockSize = 10000;
N = get(InputWaveForm, 'samples');

% Create output file & map it to memory
tic
h = fopen(FilteredFilename, 'wb');
zeroblock = zeros(blockSize, 1);
CompleteBlocks = floor(N/blockSize);
progressbar(0)
for n=1:CompleteBlocks
  progressbar(n/(2*CompleteBlocks))
  fwrite(h, zeroblock, 'single');
end
fwrite(h, zeros(N - CompleteBlocks*blockSize, 1), 'single');
fclose(h);
tock

filtered = memmapfile(FilteredFilename, 'format', 'single', ...
                      'writable', true);

block = 0;
transient = max(length(tf.den{1}), length(tf.num{1}));

start = transient;
last = start+blockSize+transient;

tic
while last <= N
  data = filter(tf.num{1}, tf.den{1}, ...
                wav(InputWaveForm, (start-transient+1):last));
  
  filtered.data(start:last) = data(transient:end);
  
  block = block + 1;
  start = start + blockSize;
  last = start+blockSize+transient;
  if start <= N & last > N
    last = N;
  end
  progressbar((CompleteBlocks+block)/(2*CompleteBlocks))
end
tock
progressbar(1)

