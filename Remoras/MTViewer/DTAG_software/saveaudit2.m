function    saveaudit2(tag,R)
%
%    saveaudit2(tag,R)
%     save an audit structure, R, to a CSV audit file with appropriate
%     name for the specified tag.
%     See help loadaudit2 for details.
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     last modified: August 2008

if nargin<1,
   help saveaudit2
   return
end

% work up audio filename
global TAG_PATHS

if isempty(TAG_PATHS) | ~isfield(TAG_PATHS,'AUDIT'),
   fname = sprintf('%saud.csv',tag) ;
else
   fname = sprintf('%s/%saud.csv',TAG_PATHS.AUDIT,tag) ;
end

% read in audit form
F = auditform ;

rfields = fieldnames(R) ;
if isfield(R,'cue'),
   n = length(R.cue) ;
   [ss,I] = sort(R.cue) ;
else
   n = length(R.(rfields{1})) ;
   I = (1:n)' ;
end

S = cell(n,4) ;
for k=1:length(F.field),
    kk = find(strcmp(rfields,F.field{k}.name)) ;
    if ~isempty(kk),
        [xx,ss] = convtype(R.(F.field{k}.name),F.field{k},1) ;
        if length(ss)~=n,
           fprintf('Unequal number of fields in audit - unable to process\n') ;
        else
           [S{1:n,k}] = deal(ss{I}) ;
        end
    end
end

savecsv(fname,F,S) ;
