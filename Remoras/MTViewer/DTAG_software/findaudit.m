function    [cues,R] = findaudit(R,stype,mincue,maxcue)
%
%    [cues,R] = findaudit(R,stype,mincue,maxcue)
%     Find all entries in an audit R with sound type stype. stype maybe a
%     string or a cell array of strings. If stype is a cell array then all
%     cues with sound type matching one of the strings in stype will be
%     returned. Optional mincue and maxcue limit the search to cues greater
%     than mincue and less than or equal to maxcue in seconds.
%     If stype is blank (i.e., []), all cues between mincue and maxcue
%     will be returned.
%     R can be either an audit structure read from a file using loadaudit
%     or maybe the name of a tag deployment as a string.
%
%     See help on loadaudit for more details.
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     last modified: September 2006

cues = [] ;

if nargin<2,
   help findaudit ;
   return
end

if nargin<3,
   mincue = [] ;
end

if nargin<4,
   maxcue = [] ;
end

if isstr(R),
   s = R ;
   R = loadaudit(s) ;
   if isempty(R.cue),
      return
   end
end

if isempty(mincue),
   mincue = 0 ;
end

if isempty(maxcue),
   maxcue = max(R.cue(:,1))+1 ;
end

k = find(R.cue(:,1)>mincue & R.cue(:,1)<=maxcue) ;
kkk = [] ;

if ~isempty(stype),
   for kk=1:size(k,1),
      if any(strcmp(strtok(R.stype{k(kk)}),stype)),
         kkk = [kkk;kk] ;
      end
   end
   k = k(kkk) ;
end

[cc,I] = sort(R.cue(k,1)) ;
k = k(I) ;
R.cue = R.cue(k,:) ;
R.stype = {R.stype{k}} ;
cues = R.cue ;

return

% below needs to be fixed to handle comments
% find associated comments
kc = find(R.commentcue==0) ;
ki = 0*kc ;
for kk=1:length(k),
   kkc = find(R.commentcue == k(kk)) ;
   if ~isempty(kkc),
      kc = [kc;kkc] ;
      ki = [ki;kk] ;
   end
end

R.comment = {R.comment{kc}} ;
R.commentcue = ki ;

