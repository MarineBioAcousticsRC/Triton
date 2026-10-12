function    [y,ypk] = find1stpk(X,relth,absth)
%
%     y = find1stpk(X,relth,absth)
%     Find the first peak in each column of X with level greater 
%     than either relth*max(X) or absth.
%     y is the index of the first peak interpolated to sub-
%     sample resolution using quadratic interpolation.
%
%     mark johnson
%     majohnson@whoi.edu
%     Last modified: 13 June 2008
%                    fixed several bugs

y = [] ;

if nargin<2,
   help find1stpk
   return
end

D = diff(X) ;
y = NaN*ones(size(X,2),1) ;
p = NaN*ones(size(X,2),3) ;
if ~isempty(relth),
   mx = max(X) ;
   th = relth*mx' ;
   if nargin==3 & ~isempty(absth),
      th = max(th,absth) ;
   end
elseif nargin==3 & ~isempty(absth),
   if length(absth)==1,
      th = absth*ones(size(X,2),1) ;
   else
      th = absth ;
   end
else
   fprintf('Need to specify relth or absth in find1stpk\n') ;
   return
end


for k=1:size(X,2),        % find 1st peak higher than th
   yy = 1+min(find(X(2:end-1,k)>=th(k) & D(1:end-1,k)>=0 & D(2:end,k)<0)) ;
   if ~isempty(yy),
      if yy==1, y(k) = 2 ;
      elseif yy==size(X,1), y(k) = yy-1 ;
      else y(k) = yy ;
      end
      p(k,:) = X(y(k)+(-1:1),k)' ;
   end
end

% now refine the estimate with a quadratic fit
ym = 0.5*(p(:,1)-p(:,3))./(p(:,3)-2*p(:,2)+p(:,1)) ;
y = min([size(X,1)+0*y max([1+0*y real(y+ym)]')']')' ;
ypk = p(:,2)+real(ym).*(p(:,3)-p(:,1))/4 ;
