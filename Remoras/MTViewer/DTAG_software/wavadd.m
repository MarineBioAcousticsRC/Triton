function wavadd(x,wavefile)
%
%   wavadd(x,wavefile)
%   Add audio data to an existing 16-bit wav file
%
%   mark johnson, WHOI
%   majohnson@whoi.edu
%   last modified: Dec. 2007

if nargin<2,
   help wavadd
   return
end

n = size(x,1) ;
nsamps = wavread(wavefile,'size') ;    % get number of channels
if nsamps(2)~=size(x,2),
   fprintf('New data must have the same number of channels as the data in the wavefile\n') ;
   return
end

% open wav file
f = fopen(wavefile,'r+','l') ;

% move file cursor to end of data chunk
fseek(f,0,'eof') ;
fwrite(f,round(32768*reshape(x',n*nsamps(2),1)),'short') ;

% adjust header of output wavfile
databytes = (nsamps(1)+n)*nsamps(2)*2 ;
riff_size = 36+databytes ;

% Fix RIFF chunk size:
fseek(f,4,'bof') ;                % skip RIFF chunk header
fwrite(f,riff_size,'ulong');      % RIFF chunk size: 4 bytes 

% skip WAVE chunk (4 bytes)
% skip fmt chunk (8+16 bytes)
% skip data chunk header (4 bytes)

% Fix data chunk size
fseek(f,32,'cof') ;
fwrite(f,databytes,'ulong');      % data chunk size: 4 bytes 

% Close file:
fclose(f);
