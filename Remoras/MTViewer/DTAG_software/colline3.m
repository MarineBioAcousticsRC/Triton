function    h = colline3(x,y,z,c)

%     h = colline3(x,y,z,c)
%     Plot coloured line(s) in 3d
%

M = [size(x) size(y) size(z) size(c)] ;
if any(M)==1,
   x = x(:) ;
   y = y(:) ;
   z = z(:) ;
   c = c(:) ;
end

h = zeros(size(x,2),1) ;
for k=1:size(x,2),
   h(k) = patch('xdata',[x(:,k);NaN],'ydata',[y(:,k);NaN],'zdata',[z(:,k);NaN],...
          'cdata',[c(:,k);NaN],'linestyle','-','edgecolor','flat');
end
set(h,'LineWidth',3) ;
