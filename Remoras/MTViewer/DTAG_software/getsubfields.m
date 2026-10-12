function    [fields,K] = getsubfields(c,field1,field2,value)
%
%    [val,k] = getsubfields(cellofstructs,fieldname)
%    [val,k] = getsubfields(cellofstructs,fieldname,otherfield)
%    [val,k] = getsubfields(cellofstructs,fieldname,otherfield,value)
%

if ~iscell(c),
   c = {c} ;
end

fields = {} ;
K = [] ;
for k=1:length(c),
   if isfield(c{k},field1),
      switch nargin,
         case 2,
            fields{end+1} = c{k}.(field1) ;
            K(end+1) = k ;
         case 3,
            if isfield(c{k},field2),
               fields{end+1} = c{k}.(field1) ;
               K(end+1) = k ;
            end
         case 4,
            if isfield(c{k},field2) & isequal(c{k}.(field2),value),
               fields{end+1} = c{k}.(field1) ;
               K(end+1) = k ;
            end
      end
   end
end

if length(K)==1,
   fields = fields{1} ;
end
