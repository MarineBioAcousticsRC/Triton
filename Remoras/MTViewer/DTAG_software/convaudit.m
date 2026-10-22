function    R = convaudit(tag)

%   R = convaudit(tag)
%   Convert the audit for a tag to the new CSV format
%   If no output argument is given, the audit file is
%   automatically created
%

R = loadaudit(tag) ;
R.duration = R.cue(:,2) ;
R.cue = R.cue(:,1) ;
R.type = reshape(R.stype,length(R.cue),1) ;
comnt = cell(length(R.cue),1) ;
if ~isempty(R.comment),
   comnt{vertcat(R.commentcue{:})} = deal(R.comment{:}) ;
end
R.comment = comnt ;

R = rmfield(R,{'stype','commentcue'}) ;

if nargout==0,
   saveaudit2(tag,R) ;
end

