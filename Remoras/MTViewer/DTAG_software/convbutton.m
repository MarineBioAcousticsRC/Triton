function    [x,s] = convbutton(x)
%
%    [x,s] = convbutton(s,silent)
%     Convert string or a cell array of strings containing '0' or '1' 
%     to corresponding numbers
%
%    [x,s] = convbutton(x,silent)
%     Convert 0 or 1 numbers or a vector of these to corresponding strings.
%
%     Returns x=0 and s='0' if the string cannot be parsed.
%

if isempty(x), s='0'; x = 0; return, end

if isstr(x) | iscell(x),
   x = str2double(x) ;
end

x = x(:) ;
k = find(x~=1) ;
x(k) = 0 ;

s = cell(length(x),1) ;
for k=1:length(x),
   if x(k)==0,
      s{k} = '0' ;
   else
      s{k} = '1' ;
   end
end

if length(x)==1,
   s = s{1} ;
end
return
