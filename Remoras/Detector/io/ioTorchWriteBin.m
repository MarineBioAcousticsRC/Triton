function ioTorchWriteBin(Data, IOBinFile, Precision)
% ioTorchWriteBin(Data, IOBinFile) 
% Given a row oriented matrix of Data, write it in the 
% Torch machine learning library binary format.
% 
% Depending on how Torch was compiled, it will expect
% values to be either in single precision (use 'float32'
% or double precision 'float64').  Precision allows
% the caller to specify what precision is used.  If
% omitted, it is set to 'float32' (the Torch default
% compilation).
%
% Maintained by CVS, do not modify:
% %Ver%

[Examples, Dim] = size(Data);

% Use native endian scheme - limits portability, but 
% Torch does not store with a standard format
% NOTE that Torch uses platform dependent word sizes
% as well, and this could cause problems...
fhandle = fopen(IOBinFile, 'wb', 'native');

if nargin < 3
  Precision = 'float32';        % default
end

fwrite(fhandle, size(Data), 'int32');

% Torch expects things to be stored by row, Matlab organizes
% by column.  While we could transpose the data, it may be large,
% so we loop through each row instead and avoid the overhead of
% a matrix copy.
for r = 1:Examples
  fwrite(fhandle, Data(r,:), Precision);
end
fclose(fhandle);
