function wavdec(ifname,df,ofname)
%
%   wavdec(ifname,df,ofname)
%   Decimate audio data from wav file fname into a new wav file
%
%   mark johnson
%   majohnson@whoi.edu
%   last modified: November 2011

if nargin<3,
   help wavdec
   return
end

% get sampling rate and number of channels
[N,fs] = wavread16(ifname,'size') ;

% create wav file
wavwrite(zeros(10,N(2)),fs/df,16,ofname) ;
f = fopen(ofname,'r+','l') ;

% move file cursor to start of data chunk
fseek(f,-10*2*N(2),'eof') ;

% copy the data, piece at a time
cend = N(1) ;
curs = 1 ;
db = 0 ;

flen = 18*df ;
h = fir1(flen,0.9/df)' ;
z = zeros(length(h)-1,1) ;

while curs<cend,
   fprintf(' Copying minute %3.1f of %3.1f\n',curs/fs/60,cend/fs/60) ;
   n = min([1e7 cend-curs]) ;
   y = wavread16(ifname,[curs curs+n-1]) ;
   [y,z] = filter(h,1,y,z) ;
   y = y(1:df:end,:) ;
   fwrite(f,round(32768*reshape(y',[],1)),'short') ;
   curs = curs+n ;
   db = db+size(y,1) ;
end

% adjust header of output wavfile
db = db*2*N(2) ;
riff_size = 36+db ;

% Fix RIFF chunk size:
fseek(f,4,'bof') ;                % skip RIFF chunk header
fwrite(f,riff_size,'ulong');      % RIFF chunk size: 4 bytes 

% skip WAVE chunk (4 bytes)
% skip fmt chunk (8+16 bytes)
% skip data chunk header (4 bytes)

% Fix data chunk size
fseek(f,32,'cof') ;
fwrite(f,db,'ulong');      % data chunk size: 4 bytes 

% Close file:
fclose(f);
