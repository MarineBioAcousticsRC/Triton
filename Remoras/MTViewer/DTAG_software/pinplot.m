function    pinplot(x,y,z,h,filled)
%
%    pinplot(x,y,z,h,filled)
%    Plot a vertical pin at each point {x,y,z} with height h.
%    Use z=[] for 2D plots.
%  
%    mark johnson, WHOI
%    majohnson@whoi.edu
%    23 January, 2007

if nargin<5,
   filled = 1 ;
end

if length(filled)<length(x),
   filled = filled(1)+0*x ;
end

kf = find(filled) ;
ko = find(~filled) ;

if isempty(z),
   hl = plot([x(:) x(:)]',[y(:) y(:)+h]','k-') ;
   hf = plot(x(kf),y(kf)+h,'ko') ;
   ho = plot(x(ko),y(ko)+h,'ko') ;
else
   hl = plot3([x(:) x(:)]',[y(:) y(:)]',[z(:) z(:)+h]','k-') ;
   hf = plot3(x(kf),y(kf),z(kf)+h,'ko') ;
   ho = plot3(x(ko),y(ko),z(ko)+h,'ko') ;
end

set(ho,'MarkerSize',5,'MarkerFaceColor','w')
set(hf,'MarkerSize',5,'MarkerFaceColor','k')
set(hl,'LineWidth',1)
