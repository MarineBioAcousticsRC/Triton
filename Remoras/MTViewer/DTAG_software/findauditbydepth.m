function    [cues,R,dsnd] = findauditbydepth(tag,stype,depth,dive)
%
%    [cues,R,dsnd] = findauditbydepth(tag,stype,depth,dive)
%     Find all entries in the audit of tag with sound type stype and that
%     occur at a depth deeper than 'depth'.
%
%    [cues,R,dsnd] = findauditbydepth(tag,stype,depth,'dive')
%     Find all entries in the audit of tag with sound type stype and that
%     occur in dives with maximum depth deeper than 'depth'.
% 
%     In both cases, stype maybe a string or a cell 
%     array of strings. If stype is a cell array then all cues with sound 
%     type matching one of the strings in stype will be
%     returned. 
%     If stype is blank (i.e., []), all cues with sufficient depth 
%     will be returned.
%     Example: find all the whistles and squeaks in dives with maximum depth
%        over 500m in pw04_299a:
%        [cues,R,dsnd] = findauditbydepth('pw04_299a',{'wsl','sq'},500,'dive') ;
%
%    Returns:
%     cues is a matrix of [cue,duration] of each sound that meets the 
%        criteria.
%     R is a subset of the audit structure containing just the sounds
%        meeting the criteria.
%     dsnd is a vector of depths with an entry for each accepted sound.
%        If dive=='dive', dsnd has a second column which is the maximum
%        depth of the dive in which the sound occurs.
%
%     See help on loadaudit for more details.
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     last modified: November 2007

cues = [] ;

if nargin<3,
   help findauditbydepth ;
   return
end

R = loadaudit(tag) ;
if isempty(R.cue),
   return
end

loadprh(tag,'p','fs') ;
dsnd = p(round(fs*R.cue(:,1))) ;
if nargin<4 | isempty(dive) | ~isequal(dive,'dive'),
   k = find(dsnd>depth) ;
   if ~isempty(k),
      dsnd = dsnd(k) ;
   end
else
   T = finddives(p,fs,depth) ;
   kpre = nearest(T(:,1),R.cue(:,1),NaN,-1) ;
   kpst = nearest(T(:,2),R.cue(:,1),NaN,1) ;
   k = find(~isnan(kpre) & kpre==kpst) ;
   if ~isempty(k),
      dsnd = [dsnd(k),T(kpre(k),3)] ;
   end
end

if isempty(k),
   R = [] ;
   dsnd = [] ;
   return
end

kkk = [] ;
if ~isempty(stype),
   for kk=1:size(k,1),
      if any(strcmp(strtok(R.stype{k(kk)}),stype)),
         kkk = [kkk;kk] ;
      end
   end
   k = k(kkk) ;
   dsnd = dsnd(kkk,:) ;
end

[cc,I] = sort(R.cue(k,1)) ;
k = k(I) ;
R.cue = R.cue(k,:) ;
R.stype = {R.stype{k}} ;
cues = R.cue ;
return
