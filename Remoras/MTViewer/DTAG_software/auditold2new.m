function        R = auditold2new(tag)

%       R = auditold2new(tag)
%
%

% work up audio filename
global TAG_PATHS

if ~isempty(TAG_PATHS) & isfield(TAG_PATHS,'AUDIT'),
   cpath = pwd ;
   cd(TAG_PATHS.AUDIT) ;
end

eval(sprintf('%saud',tag)) ;
if exist('cpath','var')
   cd(cpath) ;
end

R.cue = [] ; R.duration = [] ; R.type = {} ;

if exist('CST','var'),
   n = size(CST,1) ;
   R.cue(end+(1:n)) = CST(:,1) ;
   R.duration(end+(1:n)) = CST(:,2) ;
   [R.type{(end+(1:n))}] = deal('bz') ;
   if size(CST,2)==3,
      k = find(CST(:,3)>0 & CST(:,3)<1000) ;
      n = length(k) ;
      if n>0,
         R.cue(end+(1:n)) = CST(k,1)+CST(k,2) ;
         R.duration(end+(1:n)) = CST(k,3) ;
         [R.type{(end+(1:n))}] = deal('p') ;
      end
   end
end

if exist('PSE','var'),
   PAUSES = PSE ;
end

if exist('PAUSES','var'),
   n = size(PAUSES,1) ;
   R.cue(end+(1:n)) = PAUSES(:,1) ;
   R.duration(end+(1:n)) = PAUSES(:,2) ;
   [R.type{(end+(1:n))}] = deal('p') ;
end

if exist('RASP','var'),
   n = size(RASP,1) ;
   R.cue(end+(1:n)) = RASP(:,1) ;
   R.duration(end+(1:n)) = RASP(:,2) ;
   [R.type{(end+(1:n))}] = deal('rsp') ;
   if size(RASP,2)==3,
      k = find(RASP(:,3)>0 & RASP(:,3)<1000) ;
      n = length(k) ;
      if n>0,
         R.cue(end+(1:n)) = RASP(k,1)+RASP(k,2) ;
         R.duration(end+(1:n)) = RASP(k,3) ;
         [R.type{(end+(1:n))}] = deal('p') ;
      end
   end
end

R.cue = R.cue(:) ;
R.duration = R.duration(:) ;
R.comment = cell(length(R.cue),1) ;

if nargout==0,
   saveaudit2(tag,R) ;
end
