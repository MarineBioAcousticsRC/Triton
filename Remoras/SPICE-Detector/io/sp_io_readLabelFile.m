function [Starts, Stops] = sp_io_readLabelFile(Filename)

fileh = fopen(Filename, 'r', 'ieee-le');
if fileh < 1
    error('Unable to open %s', Filename);
end    

fseek(fileh, 0, 'eof');   % Find length of file
eofposn = ftell(fileh);
fseek(fileh, 0, 'bof');

Starts = [];
Stops = [];
% Loop through file, reading each line
moretoread = true;
while moretoread
    Start = fscanf(fileh, '%f', 1);
    Stop = fscanf(fileh, '%f ', 1);

  if ~ isempty(Start) && ~ isempty(Stop)
    Starts(end+1,1) = Start;
    Stops(end+1,1) = Stop;
  end
  
  moretoread = eofposn ~= ftell(fileh);
end