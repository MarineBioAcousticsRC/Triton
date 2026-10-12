function    imageirreg(x,y,R,vert)
%
%    imageirreg(x,y,R,vert)
%    Irregular grid image. x and y are the x-axis and y-axis values
%    for each pixel in R. x or y or both can be irregularly spaced.
%    Each pixel will be sized according to the corresponding values
%    of diff(x) and diff(y).
%
%    mark johnson, WHOI
%    majohnson@whoi.edu
%    12 December, 2006

if nargin<3,
   help imageirreg
   return
end

x = x(:)' ;
y = y(:)' ;
if length(x)~=size(R,1) | length(y)~=size(R,2),
   fprintf('R must be length(x) by length(y)\n')
   return
end

xdiff = [diff(x) x(end)-x(end-1)] ;
X = [0;0;1;1]*xdiff+ones(4,1)*x ;

Y = [0;1;1;0]*ones(1,length(x)) ;
ydiff = [diff(y) y(end)-y(end-1)] ;

for k=1:length(y),
   patch(X,ydiff(k)*Y+y(k),R(:,k)') ;
end

shading flat
axis tight
if nargin==4 & vert==1,
   set(gca,'YDir','reverse')
end
box on
