function CreateFile(v, N)
% Create a file with N elements of the appropriate precision.

% open the file
fh = fopen(v.filename, 'wb');

% write N elements
BlockSize = 2^16;
Zeros = zeros(BlockSize, 1);

n = 1;
while n*BlockSize < N
  fwrite(fh, Zeros, v.precision);
  n=n+1;
end

% write last partial block
LastElementWritten = (n-1)*BlockSize;
RemainingElements = N - LastElementWritten;
if RemainingElements
  fwrite(fh, Zeros(1:RemainingElements), v.precision);
end

fclose(fh);

