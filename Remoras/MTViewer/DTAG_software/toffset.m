function    s = toffset(cue2,tag2,cue1,tag1)
%
%     s = toffset(cue2,tag2,cue1,tag1)
%     or
%     s = toffset(cue2,tag,cue1)
%     Return the time difference in seconds between a cue on
%     tag1 and a cue on tag2. tag1 and tag2 are the deployment
%     names. cue1 and cue2 can be any cue format acceptable to
%     tagcue. See help on tagcue.
%
%     mark johnson
%     majohnson@whoi.edu
%     Last modified: May 2006

if nargin<3,
   help toffset
   s = [] ;
   return
end

if nargin==3,
   tag1 = tag2 ;
end

[c t1] = tagcue(cue1,tag1) ;
[c t2] = tagcue(cue2,tag2) ;
s = etime(t2,t1) ;

