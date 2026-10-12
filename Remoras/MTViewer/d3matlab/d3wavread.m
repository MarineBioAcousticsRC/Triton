function    [x,fs] = d3wavread(cues,recdir,prefix,suffix)
%
%     [x,fs] = d3wavread(cues,recdir,prefix,suffix)
%     cues = [start_cue end_cue], cues are in seconds with respect
%        to the ref_time associated with the recording (see d3getcues)
%     or
%     cues = [start_cue end_cue ref_time], cues are in seconds
%        with respect to a user-defined ref_time. ref_time must be in
%        UNIX seconds (fractional seconds are allowed). Use d3datevec
%        to convert a date-time vector to UNIX time.
%
%     MJ with help from DMW
%     markjohnson@st-andrews.ac.uk
%     Licensed as GPL, 2013


x = [] ; fs = [] ;
if nargin<3,
   help d3wavread
   return
end

if nargin<4 || isempty(suffix),
   suffix = 'wav' ;
end

[ct,ref_time,fs,fn,recdir] = d3getcues(recdir,prefix,suffix) ;

if isempty(ct),
   fprintf(' Unable to make cue file\n') ;
   return
end

% convert cues with a different time reference, if necessary
if length(cues)>2,
   cues = cues(1:2)+(cues(3)-ref_time) ;
end

k = find(ct(:,2)<=cues(1),1,'last') ;
if isempty(k),
   fprintf(' Cue is before the start of recording\n') ;
   return
end

% compute the number of samples to read
n = round(fs*(cues(2)-cues(1))) ;     
c = cues(1) ;
x = [] ;

while n>0,
   % find which block the next cue comes from
   bn = find(c>=ct(:,2),1,'last') ;    % find which block the current cue comes from
   fnum = ct(bn,1) ;
   bn1 = find(ct(:,1)==fnum,1,'first') ;  % find the first block of the file that the cue comes from

   % convert cue to samples wrt start of block
   st = round(fs*(c-ct(bn,2))) ;
   stb = round(fs*(c-ct(bn1,2))) ;

   % find out how many samples can be taken from this block
   len = min(n,ct(bn,3)-st) ;
   if len<n && bn==size(ct,1), 
      fprintf(' cue is beyond end of recording - truncating\n') ;
   elseif len<0,
      if bn<size(ct,1),    % if there are more blocks...
         fprintf(' Warning: possible gap between blocks\n') ;
         c = ct(bn+1,2) ; % skip to the next block
         continue
      else
         fprintf(' Warning: not enough samples in recording\n') ;
         break 
      end
   end

   % and read the samples
   fname = fn{ct(bn,1)} ;
   xx = wavread16([recdir fname,'.',suffix],stb+[1 len]) ;
   x = [x;xx] ;
   if size(xx,1)<len,
      fprintf(' error reading file %s - insufficient samples\n',fname) ;
      return
   end
   n = n-len ;
   c = c+(len+1)/fs ;
end
