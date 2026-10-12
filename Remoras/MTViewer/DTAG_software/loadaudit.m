function    R=loadaudit(tag)
%
%    R=loadaudit(tag)
%     read an audit text file with name fname into an audit structure.
%     The text file must contain lines of the form:
%        cue duration type
%     Comments preceded by the symbol % will also be read in
%     Output:
%        R is a structure containing all of the audit cues, stypes and
%        comments.
%        Use findaudit, showaudit, tagaudit and saveaudit to handle R.
%     
%     Note: although it is possible to edit the audit file using a text
%     editor, the best way to visualize and edit the audit is using tagaudit.
%
%     Extras for experts:
%        R.cue is a nx2 matrix of [cue duration] in seconds since tag on
%        R.stype is a cell array of type strings matching each row of R.cue
%        R.comment is a cell array of comments
%        R.commentcue is a vector of indices in R.cue for the notes
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     last modified: March 2005
%     added note preservation

R.cue = [] ;
R.stype = [] ;
R.comment = [] ;
R.commentcue = [] ;

if nargin<1,
   help loadaudit
   return
end

% try to make filename
global TAG_PATHS
if ~isempty(TAG_PATHS) & isfield(TAG_PATHS,'AUDIT'),
   fname = sprintf('%s/%saud.txt',TAG_PATHS.AUDIT,tag) ;
else
   fname = sprintf('%saud.txt',tag) ;
end

% check if the file exists
if ~exist(fname,'file'),
   fprintf(' Unable to find audit file %s - check directory and settagpath\n',fname) ;
   return
end

f = fopen(fname,'rt') ;
done = 0 ;

while ~done,
   s = fgetl(f) ;
   if s==-1,
      return
   end

   k = min(find(s == '%')) ;
   if ~isempty(k),
      note = s(k:end) ;
      if k==1,
         s = [] ;
      else
         s = s(1:k-1) ;
      end
   else
      note = [] ;
   end

   if ~isempty(s),
      [cs s] = strtok(s) ;
      c = str2double(cs) ;
      [ds s] = strtok(s) ;
      d = str2double(ds) ;
      if all(~isnan([c d])),
         knext = size(R.cue,1)+1 ;
         R.cue(knext,:) = [c d] ;
         [ss s] = strtok(s) ;
         R.stype{knext} = [ss s] ;  % strip leading white space from remainder
      end
   end

   if ~isempty(note),
      knote = size(R.commentcue,1)+1 ;
      R.comment{knote} = note ;
      R.commentcue(knote,:) = size(R.cue,1) ;
   end
end

fclose(f) ;
