function   [v,fout] = flownoise(tag,startcue,endcue)
%
%     [v,fs] = flownoise(tag,startcue,endcue)
%     Returns the time series of flow noise energy sampled at 25 Hz.
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     January, 2004
%

if nargin<3,
   help flownoise
   return
end

fint1 = 12000 ;            % 1st intermediate sampling rate for audio, Hz
fint2 = 1000 ;             % 2nd intermediate sampling rate for audio, Hz
fout = 25 ;                % output sampling rate, Hz
LEN = 10 ;                 % audio block length in secs

cue = startcue ;

% get the sampling frequency
[x fs] = tagwavread(tag,cue,0.1) ;

% work out the decimation factors
df1 = round(fs/fint1) ;
if abs(fs-df1*fint1)>0.05*fs,
   fprintf('unsuitable sampling rate - adjust decimation factors in the function\n') ;
end

df2 = round(fint1/fint2) ;    % 2nd decimation factor
df3 = round(fint2/fout) ;     % power averaging decimation factor

% process is:
%  1. acquire a block of audio
%  2. sum the channels if multi-channel 
%  3. decimate to a sampling-rate of 12kHz
%  4. decimate to 1kHz sampling-rate
%  5. compute instanteous power, p
%  6. decimate to 50Hz sampling

Z1 = df1 ;
Z2 = df2 ;
Z3 = df3 ;
v = [] ;
k = 0 ;

while cue<endcue,
   fprintf('Reading at cue %d\n', cue) ;
   len = min([LEN,endcue-cue]) ;
   x = tagwavread(tag,cue,len) ;
   cue = cue+len ;

   if size(x,2)>1,
      x = sum(x,2) ;
   end

   [y,Z1] = decz(x,Z1) ;        % 1. y is at fint1 (6kHz BW)
   [z,Z2] = decz(y,Z2) ;        % 2. z is at fint2 (500Hz BW)
   [p,Z3] = decz(z.^2,Z3) ;     % 3. p is at fout (25Hz BW)
   n = length(p) ;
   v(k+(1:n)) = sqrt(abs(p)) ;  % 4. v is at fout
   k = k+n ;
end
v = v(:) ;
return
