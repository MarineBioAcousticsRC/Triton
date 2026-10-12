function    h = plotdives(taglist)
%
%    h = plotdives(taglist)
%     Plot one or more dive profiles by hour-of day.
%     taglist is the name of a single tag deployment or a cell
%     array of names, e.g., {'sw03_253a','sw03_253b','sw03_253c'}
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     21 May, 2007

if nargin<1,
   help plotdives
   return
end

if ~iscell(taglist),
   tagl = taglist ;
   taglist = {} ;
   taglist{1} = tagl ;
end
taglist
figure(1),clf
h = zeros(length(taglist),1) ;

for k=1:length(taglist),
   [c ton] = tagcue(taglist{k}) ;
   ontime = ton(4:6)*[3600 60 1]' ;
   loadprh(taglist{k},'p','fs') ;
   h(k) = plot(((1:length(p))/fs+ontime)/3600,p) ;
   clist = get(gca,'ColorOrder') ;
   set(h(k),'Color',clist(rem(k-1,size(clist,1))+1,:)) ;
   grid on, hold on
end

set(gca,'YDir','reverse') ;

