function    [X,fs] = lookupcues(tag,cues,tframe,filt,DMON)
%
%   [X,fs] = lookupcues(tag,cues,tframe,[filt,DMON])
%   Extract multiple audio segments from a tag recording
%   tag is the name of the deployment (see tagcue)
%   wavbase is the path and name prefix of the wav file
%     e.g., '/tag/data/sw03/sw165a/sw165a'
%   cues is the vector of cues in seconds-since-tagon
%   tframe is the time window relative to each cue to extract,
%     e.g., tframe=[-0.01 0.25] will extract audio segments
%     starting 10ms before each cue and extending to 0.25s
%     after each cue. Both elements of tframe can be positive
%     or even negative if required but min(cues)+tframe(1) must 
%     be positive.
%   filt specifies the cut-off frequency in Hz of an optional 
%     6-pole Butterworth high-pass filter (if a scalar) or 
%     bandpass filter (if a 2-vector). filt can also be a structure
%     with elements filt.b, filt.a and filt.offset specifying the
%     b and a coefficients of a filter and the group delay in samples
%     (filt.offset).
%
%   X is a matrix of extracts with a column for each cue. If
%   the source is stereo, X is a 3-dimensional matrix with
%   dimensions n x 2 x m, where m is the number of cues.
%
%   mark johnson, WHOI
%   majohnson@whoi.edu
%   July, 2004

X = []; fs = [] ;

if nargin<3,
   help lookupcues
   return
end

if isempty(cues),
   return ;
end

[x,fs] = tagwavread(tag,cues(1),0.01) ;
if isempty(x),
   return ;
end

if length(tframe)<2,
   fprintf('lookupcues: TFRAME argument must have two elements\n')
   return
end

if nargin<4 | isempty(filt),
   offset = 0 ;
else
   if isstruct(filt),
      b = filt.b ;
      a = filt.a ;
      offset = filt.offset ;
   elseif length(filt)==1,
      [b a] = butter(6,filt/(fs/2),'high') ;
      offset = 10/filt ;
   else
      [b a] = butter(6,filt/(fs/2)) ;
      offset = 10/min([filt diff(filt)]) ;
   end
end

kind = round(offset*fs)+(1:round(diff(fs*tframe))) ;
len = diff(tframe)+2*offset+0.001 ;
starts = cues+tframe(1)-offset ;

% check number of channels in wav file
x = tagwavread(tag,starts(1),0.02) ;
X = zeros(length(kind),size(x,2),length(cues)) ;

for k=1:length(cues),
   x = tagwavread(tag,starts(k),len) ;
   if isempty(x),
      return
   end
   if size(x,2)==1 & nargin>4 & ~isempty(DMON),
      x = dmoncleanupblk(x) ;
   end

   if offset>0,
      x = filter(b,a,x) ;
   end
   X(:,:,k) = x(kind,:) ;
end

X = squeeze(X) ;     % squeeze out extra dimension if mono data
