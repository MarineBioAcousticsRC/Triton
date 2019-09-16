function handle = sp_io_openWav(filename)
% handle = ioOpenWav(filename)
% Return a handle to a wave file
% file may be closed using fclose(handle)
%

% Open as little endian binary file
handle = fopen(filename, 'rb', 'l');
