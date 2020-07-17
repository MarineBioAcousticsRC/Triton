function result = dumbConv(array, kernel, vOffset)
% result = dumbConv(array, kernel, vOffset)
% Convolve, computing result only when kernel is all the way inside array.
% The vOffset arg is optional, and says how many cells to displace the
% kernel vertically (default 1).

if (nargin < 3); vOffset = 1; end

% no error checking!
w      = nCols(array) - nCols(kernel) + 1;  % this is number of steps for kernal mvmt
kc     = nCols(kernel);

result = zeros(1,w);
rRange = vOffset : vOffset+nRows(kernel)-1;

for i = 1:w
  result(i) = sum(sum(array(rRange, (i:i+kc-1)) .* kernel));
end
