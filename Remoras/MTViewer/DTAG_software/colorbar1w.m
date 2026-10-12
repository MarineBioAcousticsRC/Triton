function     hh = colorbar1w(c,h,ctitle,W)

%    h = colorbar1w(c,h,ctitle,W)
%    make a slender colorbar on the right of the current axes.
%    c is a vector of tick positions and values
%    h is an optional axis for the colorbar
%    h can also be a string chosen from 'lowerleft','lowerright'
%      'upperleft','upperright'.
%    ctitle puts an optional axis label on the colorbar.
%    W sets the width and height of the colorbar ([0.04 0.5] is the default)
%
%    mark johnson, WHOI
%    majohnson@whoi.edu
%    last modified: 10 January 2007

XGAP = 0.04 ;

if nargin<1,
   help colorbar1
   return
end

if nargin<4,
   W = [0.04 0.5] ;
end

oax = gca ;
colorbar('delete') ;

if nargin>=2 & isstr(h),
   bx = get(gca,'Position') ;
   switch h
      case 'upperleft'
         P = [bx(1)+W(1) bx(2)+bx(4)*(1-W(2))-W(1) W(1) bx(4)*W(2)] ;
      case 'upperright'
         P = [bx(1)+bx(3)-2*W(1) bx(2)+bx(4)*(1-W(2))-W(1) W(1) bx(4)*W(2)] ;
      case 'lowerleft'
         P = [bx(1)+W(1) bx(2)+W(1) W(1) bx(4)*W(2)] ;
      case 'lowerright'
         P = [bx(1)+bx(3)-2*W(1) bx(2)+W(1) W(1) bx(4)*W(2)] ;
      otherwise
         P = [bx(1)+bx(3)+W(1) bx(2)+bx(4)/2*(1-W(2)) W(1) bx(4)*W(2)] ;
   end
   h = axes('position',P) ;
         
elseif nargin==1,
   bx = get(gca,'Position') ;
   h = axes('position',[bx(1)+bx(3)+W(1) bx(2)+bx(4)/2*(1-W(2)) W(1) bx(4)*W(2)]) ;
end

colorbar(h) ;
set(h,'YTick',linspace(1,65,length(c))) ;
set(h,'YTickLabel',c) ;
set(h,'FontSize',11,'XColor','w','YColor','w') ;

if nargin>=3,
   hh = gca ;
   axis(h) ;
   ylabel(ctitle) ;
   axis(hh) ;
end

if nargout==1,
   hh = h ;
end

%axes(oax) ;
