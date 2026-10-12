function       x = parsecsv(F,csv)
%
%       x = parsecsv(F,csv)
%

if isempty(csv),
   x = [] ;
   return
end

if isstruct(csv),
   csv = struct2cell(csv)' ;
end

if size(csv,2)~=length(F.field),
   logtoolerror('Error: form has changed since last file was saved') ;
   x = [] ;
   return
end

for k=1:length(F.field),
   f = F.field{k} ;
   x.(f.tag) = convtype({csv{:,k}},f) ;
end
