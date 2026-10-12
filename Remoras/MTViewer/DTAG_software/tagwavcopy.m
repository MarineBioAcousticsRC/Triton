function tagwavcopy(tag,cues,wavefile,CH)
%
%   tagwavcopy(tag,cues,wavefile,CH)
%   Copy a section of tag audio data into a new wav file
%
%   mark johnson, WHOI
%   majohnson@whoi.edu
%   last modified: 20 Feb. 2007

if nargin<3 | length(cues)<2,
   help tagwavcopy
   return
end

% get sampling rate and number of channels
[y,fs] = tagwavread(tag,cues(1),1) ;
if isempty(y),
   return
end

ch = size(y,2) ;
if nargin<4 | isempty(CH),
   CH = 1:ch ;
end

if any(CH)>ch,
   fprintf('Requested channels exceeds number of channels in data\n') ;
   return
end

%if diff(cues)<60,
%   [y,fs] = tagwavread(tag,cues(1),diff(cues)) ;
%   if length(CH)~=ch,
%      y = y(:,CH) ;
%  end
%   wavwrite(y,fs,16,wavefile) ;
%   return
%end

if ~any(wavefile=='.'),
   wavefile = [wavefile '.wav'] ;
end

% create wav file
wavwrite(zeros(10,length(CH)),fs,16,wavefile) ;
f = fopen(wavefile,'r+','l') 

% move file cursor to start of data chunk
fseek(f,-10*2*length(CH),'eof') ;

% get start and end positions
cst = tagcue(cues(1),tag) ;
ced = tagcue(cues(2),tag) ;
extfname = 0 ;

% for each chip involved
N = 0 ;
for k=cst(1):ced(1),
   % make a file name for the wav file
   iwavf = makefname(tag,'AUDIO',k) ;
   if extfname,
      iwavf = [iwavf(1:end-6) '0' iwavf(end-5:end)] ;
   end

   % read size of input wav file
   if k==ced(1),
      nsamps = ced(2) ;
   else
      try
         nsamps = wavread16(iwavf,'size')*[1;0] ;
      catch
         iwavf = [iwavf(1:end-6) '0' iwavf(end-5:end)] ;
         extfname = 1 ;
         nsamps = wavread16(iwavf,'size')*[1;0] ;
      end
   end

   if k==cst(1),
      curs = cst(2) ;
   else
      curs = 1 ;
   end

   % copy the data, piece at a time
   while curs<nsamps,
      fprintf(' Copying chip %d minute %3.1f of %3.1f\n', ...
         k,(curs-1)/fs/60,nsamps/fs/60) ;
      n = min([1e7 nsamps-curs]) ;
      y = wavread16(iwavf,[curs curs+n-1]) ;
      if length(CH)~=ch,
         y = y(:,CH) ;
      end
      fwrite(f,round(32768*reshape(y',n*length(CH),1)),'short') ;
      curs = curs+n ;
      N = N+n ;
   end
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
