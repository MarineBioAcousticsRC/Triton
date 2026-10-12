function wavcopy(ifname,cues,ofname,CH)
%
%   wavcopy(ifname,cues,ofname,CH)
%   Copy a section of audio data from wav file fname into a new wav file
%
%   mark johnson
%   majohnson@whoi.edu
%   last modified: October 2010

if nargin<3 | length(cues)<2,
   help wavcopy
   return
end

% get sampling rate and number of channels
[y,fs] = wavread16(ifname,'size') ;
if isempty(y),
   return
end

ch = y(2) ;
if nargin<4 | isempty(CH),
   CH = 1:ch ;
end

if any(CH)>ch,
   fprintf('Requested channels exceeds number of channels in data\n') ;
   return
end

% create wav file
wavwrite(zeros(10,length(CH)),fs,16,ofname) ;
f = fopen(ofname,'r+','l') ;

% move file cursor to start of data chunk
fseek(f,-10*2*length(CH),'eof') ;

% copy the data, piece at a time
cend = round(fs*cues(2)) ;
curs = round(fs*cues(1)) ;
ns = 0 ;

while curs<cend,
   fprintf(' Copying minute %3.1f of %3.1f\n',curs/fs/60,cend/fs/60) ;
   n = min([1e7 cend-curs]) ;
   y = wavread16(ifname,curs+[1 n]) ;
   if length(CH)~=ch,
      y = y(:,CH) ;
   end
   fwrite(f,round(32768*reshape(y',n*length(CH),1)),'short') ;
   curs = curs+n ;
   ns = ns+n ;
end

% adjust header of output wavfile
databytes = ns*length(CH)*2 ;
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
