function    [x,s] = convtime(x,silent)
%
%    [x,s] = convtime(s,silent)
%     Convert time string or cell array of strings to a [hr min sec] 
%     vector or matrix.
%
%    [x,s] = convtime(x,silent)
%     Convert [hr min sec] vector or matrix to a time string or cell
%     array of strings.
%
%    Optional 2nd argument turns off error messages if 1.
%    Returns x=[NaN NaN NaN] and s='' for invalid input.
%

if nargin<2, silent = 0 ; end
if isempty(x), x=NaN*[1 1 1]; s=''; return, end

if isstr(x),
   x = {x} ;
end

if iscell(x),
   xx = NaN*ones(length(x),3) ;
   for k=1:length(x),
      if ~isempty(x{k}),
         xxx = sscanf(x{k},'%d:%d:%d',3) ;
         if length(xxx)==3,
            xx(k,:) = xxx' ;
         end
      end
   end
   x = xx ;
end

% from here on, x is a matrix of [hr min sec]
x = round(x) ;
if size(x,2)~=3,
   if silent~=1,
      logtoolerror('Time must be in hh:mm:ss format') ;
   end
   x = [] ; s = '' ;
   return
end

k = find(any(x'<0)' | x(:,1)>23 | x(:,2)>59 | x(:,3)>59) ;
if ~isempty(k),
   logtoolerror('Time must be in hh:mm:ss format') ;
   x(k,:) = NaN ;
end

s = cell(size(x,1),1) ;
for k=1:size(x,1),
   if any(isnan(x(k,:))),
      s{k} = '' ;
   else
      s{k} = sprintf('%02d:%02d:%02d',x(k,:)) ;
   end
end

if length(s)==1,
   s = s{1} ;
end
return
