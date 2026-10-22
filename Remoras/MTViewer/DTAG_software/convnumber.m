function    [x,s] = convnumber(x,field,silent)
%
%    [x,s] = convnumber(s,field,silent)
%     Convert number strings to numbers
%     Returns x=NaN and s='' if the string cannot be parsed.
%
%    [x,s] = convnumber(x,field,silent)
%     Convert number values to strings.
%     Returns x=NaN and s='' if the string cannot be parsed.
%
%     Optional 3rd argument silent disables error messages if 1.
%

def.format = 6 ; def.min = NaN ; def.max = NaN ;
if nargin<2 | ~isstruct(field),
   field = struct ;
end

if nargin<3,
   silent = 0 ;
end

f = mergeopts(field,def) ;

if isempty(x), s=''; x = NaN; return, end

if isstr(x) | iscell(x),
   x = str2double(x) ;
end

x = x(:) ;
k = find(x<f.min | x>f.max) ;
x(k) = NaN ;
if ~isempty(k) & silent~=1,
   logtoolerror(sprintf('Value must be between %g and %g',f.min,f.max)) ;
end

s = cell(length(x),1) ;
for k=1:length(x),
   if isnan(x(k)),
      s{k} = '' ;
   else
      s{k} = num2str(x(k),f.format) ;
   end
end

if length(x)==1,
   s = s{1} ;
end
return
