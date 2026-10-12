function    [X,fs] = d3lookupcues(cues,recdir,prefix,suffix,tframe,filt,ref_time)
%
%   [X,fs] = d3lookupcues(cues,recdir,pref,suffix,tframe,filt,ref_time)
%   Extract multiple audio segments from a D3 recording.
%   cues is the vector of cues in seconds-since-ref_time where
%     ref_time is the standard or user-specified reference time.
%   recdir is the path of the directory where the audio files are located.
%   prefix is the file name prefix of the recording.
%   suffix is the file name suffix of the recording, e.g., 'wav'.
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
%   ref_time is an optional time reference for the cues. If it is not
%     specified, the standard time reference in the cue file is used.
%
%   X is a matrix of extracts with a column for each cue. If
%   the source is stereo, X is a 3-dimensional matrix with
%   dimensions n x 2 x m, where m is the number of cues.
%
%   mark johnson, WHOI
%   majohnson@whoi.edu
%   July, 2004

X = []; fs = [] ;

if nargin<4,
   help d3lookupcues
   return
end

if nargin<7,
   ref_time = [] ;
end

[x,fs] = d3wavread([cues(1)+[0 0.01] ref_time],recdir,prefix,suffix) ;
if isempty(x),
   return ;
end

if length(tframe)<2,
   fprintf('d3lookupcues: TFRAME argument must have two elements\n')
   return
end

if nargin<5 | isempty(filt),
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
X = zeros(length(kind),length(cues)) ;

for k=1:length(cues),
   x = d3wavread([starts(k)+[0 len] ref_time],recdir,prefix,suffix) ;
   if isempty(x),
      return
   end

   if offset>0,
      x = filter(b,a,x) ;
   end
   X(:,k) = x(kind,:) ;
end
