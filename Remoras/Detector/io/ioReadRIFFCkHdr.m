function RiffChunk = ioReadRIFFCkHdr(f_handle)
% RiffChunk = ioReadRIFFCkHdr(f_handle)
%
% Read the next Microsoft RIFF chunk header from an open file.  The file
% read pointer must be positioned at the first byte of the RIFF chunk.
% Returns a structure indicating the chunk identifier, size, and the
% current read position which is useful if the data is to be accessed
% multiple times.
%
% Modeled after Mathworks wavread'read_ckinfo
% Author:  Marie Roch
%

RiffChunk.StartByte = ftell(f_handle);  % beginning of chunk
[id, bytes] = fread(f_handle, 4, 'char');


if bytes < 4
  if feof(f_handle)
    RiffChunk.ID = 'EOF'; % end of file
    RiffChunk.Size = 0;
    RiffChunk.DataStart = 0;
    RiffChunk.DataSize = 0;
    RiffChunk.ChunkSize = 0;
    return
  else
    error('io:Bad RIFF id');
  end
end

RiffChunk.ID = deblank(char(id'));
% Read chunk size 
[DataSize, words] = fread(f_handle, 1, 'uint32');
HeaderSize = 8;  % Oy vay - Magic #!

if words ~= 1
  error('io:Bad RIFF chunk, could not read size');
else
  % Beginning of chunk data
  RiffChunk.DataStart = ftell(f_handle);
  RiffChunk.DataSize = DataSize;
  RiffChunk.ChunkSize = DataSize + HeaderSize;
end



