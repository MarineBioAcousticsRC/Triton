function    H = annotatedtrack(tag,lims,cues,NOTEXT)

%    annotatedtrack(tag,lims,cues)
%    Draw the horizontal track corresponding to deployment 'tag'
%    between times lims(1) and lims(2). Identify where the events
%    in the cues vector fall on the track
%
%    mark johnson, WHOI
%    majohnson@whoi.edu
%    24 April, 2007

if nargin<2,
   help annotatedtrack
   return
end

if nargin<4,
   NOTEXT = 0 ;
end

loadprh(tag,0,'p','fs','pitch','head','roll') ;
kk = round(fs*lims(1)):round(fs*lims(2)) ;
trk = ptrack(pitch(kk),head(kk),p(kk),fs,0.2) ;
%figure(2),clf
colline(trk(:,2),trk(:,1),p(kk)) ;

if nargin>=3 & ~isempty(cues),
   k = find(cues(:,1)>lims(1) & cues(:,1)<lims(2)) ;
   hold on
   S = {} ;
   for kkk=1:length(k),
      S{kkk} = sprintf(' %d',k(kkk)) ;
   end
   kst = round(fs*(cues(k,1)-lims(1))) ;
   H = plot(trk(kst,2),trk(kst,1),'ko') ;

   if ~NOTEXT,
      text(trk(kst,2),trk(kst,1),S) ;
   end

   if size(cues,2)>1,
      ked = round(fs*(cues(k,2)-lims(1))) ;
      plot(trk(ked,2),trk(ked,1),'k*') ;
      plot([trk(kst,2) trk(ked,2)]',[trk(kst,1) trk(ked,1)]','k') ;
   end
end

%plot(trk(kst-50,2),trk(kst-50,1),'ks') ;

% plot R radius circle at each cue point
%R = 20 ;
%ss = R*sin(0:pi/10:2*pi)' ;
%cc = R*cos(0:pi/10:2*pi)' ;
%for kkk=1:length(k),
%   plot(trk(ked(kkk),2)+ss,trk(ked(kkk),1)+cc,'k')
%end
%colorbar

