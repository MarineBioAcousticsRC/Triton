function    [R,fork,fnames] = flatten(TBASE,attrib,index)
%
%    [R,fork,fnames] = flatten(TBASE,attrib,index)
%

fnames = fieldnames(TBASE) ;
R = [] ; fork = [] ;

if ~iscell(attrib),
   a = attrib ;
   attrib = cell(1) ;
   attrib{1} = a ;
end

for k=1:length(fnames),
   t = getfield(TBASE,fnames{k}) ;
   for kk=1:length(attrib),
      t = getfield(t,attrib{kk}) ;
   end
   R = [R;t] ;
   fork = [fork;k+0*t] ;
end

if nargin==3 & ~isempty(index),
   R = R(index,:) ;
   fork = fork(index) ;
end
