function    saveaudit(tag,R)
%
%    saveaudit(tag,R)
%     save an audit structure, R, to an audit file with appropriate
%     name for the specified tag.
%     See help loadaudit for details.
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     last modified: August 2008
%                    added sort of R.cue

if nargin<1,
   help saveaudit
   return
end

% work up audio filename
global TAG_PATHS

if isempty(TAG_PATHS) | ~isfield(TAG_PATHS,'AUDIT'),
   fname = sprintf('%saud.txt',tag) ;
else
   fname = sprintf('%s/%saud.txt',TAG_PATHS.AUDIT,tag) ;
end

f = fopen(fname,'wt') ;
if f<0,
   fprintf(' Unable to open file - check name\n') ;
   return
end

if ~isfield(R,'commentcue'),
   R.commentcue = [] ;
end

k = find(R.commentcue==0) ;
if ~isempty(k),
   fprintf(f,'%s\n',R.comment{k}) ;
end

[ss,I] = sort(R.cue(:,1)) ;

for k=1:size(R.cue,1),
   if ~isstr(R.stype{I(k)}),
      fprintf(f,' %5.2f\t%4.2f\tUNKNOWN\n',R.cue(I(k),:)) ;
   else
      fprintf(f,' %5.2f\t%4.2f\t%s\n',R.cue(I(k),:),R.stype{I(k)}) ;
   end
   kk = find(R.commentcue==I(k)) ;
   if ~isempty(kk),
      fprintf(f,'\t%s\n',R.comment{kk}) ;
   end
end

fclose(f) ;
