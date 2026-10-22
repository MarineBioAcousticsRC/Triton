function    [x,s] = convdate(x,silent)
%
%    [x,s] = convdate(s,silent)
%     Convert date string or cell array of strings to a [yr mon day]
%     vector or matrix
%
%    [x,s] = convdate(x,silent)
%     Convert [yr mon day] vector or matrix to a date string or cell 
%     array of strings.
%
%     Returns x=[NaN NaN NaN] and s='' if a string cannot be parsed.
%     Optional 2nd argument turns off error messages if 1.
%

if nargin<2, silent = 0 ; end
if isempty(x), x=NaN*[1 1 1]; s=''; return, end

if isstr(x),
   x = {x} ;
end

if iscell(x),
   xx = NaN*ones(length(x),3) ;
   for k=1:length(x),
      xxx = sscanf(x{k},'%d/%d/%4d',3) ;
      if length(xxx)==3,
         xx(k,:) = xxx(end:-1:1)' ;
      end
   end
   x = xx ;
end

% from here on, x is a matrix of [yr mon day]
x = round(x) ;
if size(x,2)~=3,
   if silent~=1,
      logtoolerror('Date must be in dd/mm/yyyy format') ;
   end
   x = [] ; s = '' ;
   return
end

k = find(x(:,1)<2000 | x(:,2)<1 | x(:,3)<1 | x(:,1)>2100 | x(:,2)>12 | x(:,3)>31) ;
x(k,:) = NaN ;

bad = 0 ;
s = cell(size(x,1),1) ;
for k=1:size(x,1),
   if any(isnan(x(k,:))),
      s{k} = '' ;
      bad = 1 ;
   else
      s{k} = sprintf('%d/%d/%4d',x(k,3:-1:1)) ;
   end
end

if bad==1 & silent~=1,
  logtoolerror('Date must be in dd/mm/yyyy format') ;
end

if length(s)==1,
   s = s{1} ;
end
return
