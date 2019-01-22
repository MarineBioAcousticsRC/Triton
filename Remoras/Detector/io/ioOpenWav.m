function handle = ioOpenWav(filename)
% handle = ioOpenWav(filename)
% Return a handle to a wave file
% file may be closed using fclose(handle)
%
% Do not modify the following line, maintained by CVS
% $Id% %Exp$

% Open as little endian binary file
handle = fopen(filename, 'rb', 'l');
