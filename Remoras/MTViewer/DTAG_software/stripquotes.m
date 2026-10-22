function    s = stripquotes(s,nowhite)
%
%   s = stripquotes(s)
%     Remove bracketing double quotes from string or
%     cell array containing strings.
%

if nargin<2,
   nowhite = 0 ;
end

if isstr(s),
   if all(s([1 end])=='"'),
      s = s(2:end-1) ;
   end
   if nowhite,
      kk = strfind(s,' ') ;
      s(kk) = '_' ;
   end
   return
end

[m,n] = size(s) ;
for k=1:m*n,
   ss = s{k} ;
   if ~isempty(ss) & isstr(ss),
      if all(ss([1 end])=='"'),
         ss = ss(2:end-1) ;
      end
      if nowhite,
         kk = strfind(ss,' ') ;
         ss(kk) = '_' ;
      end
      s{k} = ss ;
   end
end
return
