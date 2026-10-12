function    s = num2strcell(x)
%
%    s = num2strcell(x)
%     Convert number array to cell array of strings for savecsv
%

s = cell(size(x)) ;
for k=1:length(x(:)),
   if isnan(x(k)),
      s{k} = '' ;
   else
      s{k} = num2str(x(k),6) ;
   end
end

if length(x)==1,
   s = s{1} ;
end
return
