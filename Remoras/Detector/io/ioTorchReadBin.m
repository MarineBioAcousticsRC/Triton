function Data = ioTorchReadBin(IOBinFile, Precision)
% Data = ioTorchReadBin(IOBinFile, Precision)
% Read row oriented data from a Torch machine 
% library binary format file.
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

% Use native endian scheme - limits portability, but 
% Torch does not store with a standard format
% NOTE that Torch uses platform dependent word sizes
% as well, and this could cause problems...
fhandle = fopen(IOBinFile, 'rb', 'native');

if nargin < 2
  Precision = 'float32';        % default
end

Dim = fread(fhandle, 2, 'int32')';

% Torch expects row oriented data
Data = zeros(Dim);
for r=1:Dim(1)
  Data(r,:) = fread(fhandle, Dim(2), Precision)';
end

fclose(fhandle);


