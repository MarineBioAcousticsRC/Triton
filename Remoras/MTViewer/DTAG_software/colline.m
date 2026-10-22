function    h = colline(x,y,c)

%     h = colline(x,y,c)
%     Plot coloured line(s)
%     If x,y,c are matrices, one line is drawn for each column
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     5 February 2007

M = [size(x) size(y) size(c)] ;
if any(M==1),
   x = x(:) ;
   y = y(:) ;
   c = c(:) ;
end

h = zeros(size(x,2),1) ;
for k=1:size(x,2),
   h(k) = patch('xdata',[x(:,k);NaN],'ydata',[y(:,k);NaN],'cdata',[c(:,k);NaN],...
          'linestyle','-','edgecolor','flat');
end
set(h,'LineWidth',3) ;
