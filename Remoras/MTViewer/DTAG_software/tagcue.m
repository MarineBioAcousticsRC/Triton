function      [c,t,s,ttype,fs,id,wavfname,ndigits]=tagcue(cue,tag,SILENT)
%
%      [c,t,s,ttype,fs,id,wavfname,ndigits]=tagcue(cue,tag,[SILENT])
%      Return cue information for a tag dataset:
%         tag  is the deployment name e.g., 'sw01_200'
%         cue is a 1 to 3 element vector interpreted as:
%             1-element: seconds since tag-on
%             2-element: data index in [chip,second]
%             3-element: time of day in [hour,min,sec]
%         SILENT if 1 inhibits any error messages to the screen
%      SUPPORTS TAG TYPES 1 AND 2
%
%      Output arguments are:
%         c = [chip,audio-sample-in-chip,raw-sensor-sample]
%         t = [year,month,day,hour,min,sec]
%         s = seconds since tag on
%		    ttype = {1,2} tag version
%         fs = [audio_sampling_rate,sensor_sampling_rate]
%         id = tag number that made the recording e.g., 210
%         wavfname = string containing the full name of the
%            wav file corresponding to the cue. Use tagpath.m
%            to set the paths of tag data.
%
%  mark johnson, WHOI
%  majohnson@whoi.edu
%  last modified: 13 May 2006

t = [] ; c = [] ; ttype = [] ; s = [] ; fs = [] ; id = [] ;
wavfname = '' ;

if isstr(cue),
   if nargin==1,
      tag = cue ;
      cue = [] ;
   else
      cc = tag ;     % swap arguments
      tag = cue ;
      cue = cc ;
   end
end

if nargin<1,
   help('tagcue') ; return
end

if isnan(cue), return, end

if nargin<3,
   SILENT = 0 ;
end

[c t s len fs id ndigits] = tag2cue(cue,tag,1) ;
if isempty(c),
   [c t s len fs id ndigits] = tag1cue(cue,tag,1) ;
   if isempty(id),
      if SILENT~=1,
         fprintf(' Not a valid tag1 or tag2 experiment - check name\n') ;
         return
      end
   else
      ttype = 1 ;
   end
else
   ttype = 2 ;
end

% work up audio filename
if nargout>=7,
   if ~isempty(c),
      wavfname = makefname(tag,'AUDIO',c(1),[],ndigits) ;
   else
      wavfname = [] ;
   end
end
