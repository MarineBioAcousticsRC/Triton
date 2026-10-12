function    [x,ss] = convstring(x,f,silent)
%
%    [x,ss] = convstring(x,f,silent)
%

if ~iscell(x)
   x = {x} ;
end

if nargin>1 & isstruct(f) & isfield(f,'case') & isequal(lower(f.case),'upper'),
   upps = 1 ;
else
   upps = 0 ;
end

ss = cell(size(x)) ;
for k=1:length(x),
   xx = x{k} ;
   if ~isempty(xx),
      if upps,
         xx = upper(xx) ;
         x{k} = xx ;
      end
      if all(xx([1 end])=='"'),
         ss{k} = xx ;
         x{k} = xx(2:end-1) ;
      else
         ss{k} = ['"' xx '"'] ;
      end
   end
end

if iscell(x) & length(x)==1,
   x = x{1} ;
   ss = ss{1} ;
end
