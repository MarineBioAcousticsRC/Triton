function     [x,afs,rcue]=tagwavread(tag,cue,secs)
%
%     [x,afs,rcue]=tagwavread(tag,cue,secs)
%     Read audio data from a sequence of wav files recorded by the DTAG
%     Supports tag1 and tag2.
%     tag is the full deployment name e.g. sw05_199a
%     cue is the time of the start of the desired extract. cue can be
%        in any of the acceptable time forms (see tagcue for a list).
%        Only one cue is allowed - for multiple cues use lookupcues.m
%     secs is the length of the extract in seconds. Can be a fraction
%        of a second.
%
%     Returns:
%     x is the signal vector or matrix (for multi-channel tag data) with 
%        a channel in each column.
%     afs is the audio sampling rate of the signal in x.
%     rcue is the seconds since tag-on at the start of the extract x.
%
%     Make sure the paths to tag data have been declared
%     using settagpath.m
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     Last modified: 5 June 2008
%                    added support for auxiliary wav files 

x = [] ;
afs = [] ;
rcue = [] ;

if nargin<3,
   help tagwavread
   return
end

[c,t,s,ttype,fs,id,wavf,ndigits] = tagcue(cue,tag) ;
if isempty(c), return, end
rcue = c(3) ;

% cue could start and end in the wav file wavf or in an extension file
% (wavx). Cue could end in the following chip's wav file without extension.

try
   [ss afs] = wavread16(wavf,'size') ;
catch
   fprintf('Unable to open file %s\n', wavf) ;
   return ;
end

if ss(1)<c(2),             % if the requested sample starts beyond the end of wavf
   wavf = [wavf 'x'] ;     % form the file name of the auxiliary wav file
   try                     % and try to open it
      c(2) = c(2)-ss(1) ;
      [ss afs] = wavread16(wavf,'size') ;
   catch
      fprintf('Unable to open file %s\n', wavf) ;
      return ;
   end
end

% we have identified the starting file
% prepare to read secs seconds or to end of file
smax = floor(min([c(2)+secs*afs+1 ss(1)])) ;

% actual number of seconds to read from 1st file
ns = (smax-c(2))/afs ;
x = wavread16(wavf,[round(c(2)) smax]) ;

if ns>=secs,
   return
end

% we need to read some more from the next file in the sequence.
% first see if this is an extension wav file

if wavf(end)~='x',
   wavf = [wavf 'x'] ;     % form the file name of the auxiliary wav file
   try                     % and try to open it
      [ss afs] = wavread16(wavf,'size') ;
      % read secs seconds or to end of file
      smax = floor(min([(secs-ns)*afs+1 ss(1)])) ;
      x = [x;wavread16(wavf,[1 smax])] ;
      % total number of seconds read so far
      ns = ns+smax/afs ;
   catch
   end
end

if ns>=secs,
   return
end

% any remaining data must be in the next chip's wav file
[c,t,s,ttype,fs,id,wavf] = tagcue(cue+secs,tag) ;     % fixed mj 20/aug/14
%wavf = makefname(tag,'AUDIO',c(1)+1,[],ndigits) ;    % was this which didn't work if
                                                      % file numbers were non-consecutive
try
   x = [x;wavread16(wavf,[1 round((secs-ns)*afs)])] ;
catch
   fprintf('Unable to open file %s, x is short\n', wavf) ;
end
