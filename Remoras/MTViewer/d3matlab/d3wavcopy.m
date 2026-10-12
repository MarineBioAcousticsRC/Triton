function d3wavcopy(recdir,prefix,cues,wavefile,CH,g)
%
%   d3wavcopy(recdir,prefix,cues,wavefile,CH,g)
%   Copy a section of tag audio data into a new wav file
%
%   mark johnson
%   last modified: May 2013

if nargin<4 | length(cues)<2,
   help d3wavcopy
   return
end

% get sampling rate and number of channels
[y,fs] = d3wavread(cues(1)+[0 0.1],recdir,prefix) ;
if isempty(y),
   return
end

ch = size(y,2) ;
if nargin<5 | isempty(CH),
   CH = 1:ch ;
end

if nargin<6 | isempty(g),
   g = 1 ;
end

if any(CH)>ch,
   fprintf('Requested channels exceeds number of channels in data\n') ;
   return
end

if ~any(wavefile=='.'),
   wavefile = [wavefile '.wav'] ;
end

% create wav file
wavwrite(zeros(10,length(CH)),fs,16,wavefile) ;
f = fopen(wavefile,'r+','l') 

% move file cursor to start of data chunk
fseek(f,-10*2*length(CH),'eof') ;

N = 0 ;
nsamps = round(fs*diff(cues)) ;
cues = cues(1) ;

% copy the data, piece at a time
while N<nsamps,
   fprintf(' Copying second %3.1f of %3.1f\n',N/fs,nsamps/fs) ;
   n = min(1e7,nsamps) ;
   y = d3wavread(cues+[0 n/fs],recdir,prefix) ;
   if length(CH)~=ch,
      y = y(:,CH) ;
   end
   if g>1,
      m = mean(y) ;
      y = g*(y-repmat(m,size(y,1),1)) ;
   end
   fwrite(f,round(32768*reshape(y',n*length(CH),1)),'short') ;
   cues = cues+n/fs ;
   N = N+n ;
end

% adjust header of output wavfile
databytes = N*length(CH)*2 ;
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
