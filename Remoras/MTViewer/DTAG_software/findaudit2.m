function    [cues,RR] = findaudit2(R,stype,mincue,maxcue)
%
%    [cues,R] = findaudit2(tag,stype,mincue,maxcue)
%     or
%    [cues,R] = findaudit2(R,stype,mincue,maxcue)
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
%     See help on loadaudit2 for more details.
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     last modified: August 2008

cues = [] ;

if nargin<2,
   help findaudit2 ;
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
   R = loadaudit2(s) ;
   if isempty(R.cue),       % no entries in the audit file
      return
   end
end

if isempty(mincue),
   mincue = 0 ;
end

if isempty(maxcue),
   maxcue = max(R.cue(:,1))+1 ;
end

% find cues within the acceptable range
k = find(R.cue(:,1)>mincue & R.cue(:,1)<=maxcue) ;

% find cues with the correct stype
if ~isempty(stype),
   % read the form
   F = auditform ;
   kk = find(strcmp(getsubfields(F.field,'name'),'type')) ;
   if ~isempty(kk),
      stype = convtype(stype,F.field{kk(1)}) ;
   end
   
   % get the first tokens of the sound type (this should change)
   S = cell(length(k),1) ;
   for kk=1:length(k),
      S{kk} = strtok(R.type{k(kk)}) ;
   end
   
   if ~iscell(stype), stype = {stype} ; end

   typematch = zeros(length(k),1) ;
   for kk=1:length(stype),
      typematch = typematch | strcmp(S,stype{kk}) ;
   end
   k = k(find(typematch)) ;
end

% order the cues that pass the test
[cc,I] = sort(R.cue(k,1)) ;
k = k(I) ;

% extract the corresponding entries from all of the fields in R
fnames = fieldnames(R) ;
RR = struct ;
for kk=1:length(fnames),
   if iscell(R.(fnames{kk})),   
      RR = setfield(RR,fnames{kk},{R.(fnames{kk}){k}}) ;
   else
      RR = setfield(RR,fnames{kk},R.(fnames{kk})(k)) ;
   end
end

cues = [RR.cue RR.duration] ;
return
