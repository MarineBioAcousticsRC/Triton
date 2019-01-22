function bool = ioRIFFCkBytesRemainingP(f_handle, Chunk, N)
% bool = ioRIFFCkBytesRemainingP(f_handle, Chunk, N)
% Predicate indicating whether or not N bytes still remain to be
% read in the current chunk.

posn = ftell(f_handle); % get current position
NextStart = Chunk.StartByte + Chunk.ChunkSize;
bool = posn + N <= NextStart;
