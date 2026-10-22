function    p = fixpressure(p,t)
%
%    p = fixpressure(p,tempr)
%    Fix a 1st or 2nd order temperature effect in a pressure profile interactively.
%    Follow the screen instructions to select surfacing points for regression. The
%    output is the pressure vector with optimized surfacing points.
%    If no temperature vector is available, just call as fixpressure(p) and
%    a fake temperature vector will be made from the pressure vector. In
%    this case the result will be a little less reliable but the
%    temperature effects are usually quite small (<2m) so errors less than
%    this are likely.
%
%    mark johnson
%    majohnson@whoi.edu
%    last modified: 10 January 2010

PRESSRANGE = 20 ;
PRESSDIFF = PRESSRANGE/1000 ;
TREF = 20 ;
TC = 1/(5*90) ;

if nargin==1,       % no temperature
   % use a slowed down and scaled version of the pressure
   t = p*30/max(p) ;
   t = filter(TC,[1 -(1-TC)],t) ;
end

% select starting set
k = find(p<(min(p)+PRESSRANGE) & abs(diff([0;p]))<PRESSDIFF) ;  

if isempty(k),
   fprintf(' Unable to find suitable p values for temperature characterization - check cal values\n') ;
   return
end

tt = t(k) ; pp = p(k) ;
figure(1),clf
subplot(211)
plot((1:length(p))/1000,p),grid,hold on
hu = plot(k/1000,pp,'r.') ;
set(hu,'MarkerSize',5) ;
hg = plot(-100,0,'g.') ;        % dummy plot to make a handle
set(hg,'MarkerSize',5) ;
axis([0 length(p)/1000 (min(pp)-5)+[0 PRESSRANGE*1.5]])
xlabel('samples (x10^3)'),ylabel('nominal depth, m')
title('dive profile. red points are available for calibration') ;

subplot(212)
hp = plot(tt,pp,'.'); grid, hold on
set(hp,'MarkerSize',5) ;
axis([min(tt)-1 max(tt)+1 min(pp)-1 max(pp)+1]) ;
xlabel('temperature, degrees C'),ylabel('nominal depth')
title('depth vs temperature. select points for calibration') ;

done = 0 ;
kk = [] ;
h = plot(-100,0,'g.') ;        % dummy plot to make a handle
set(h,'MarkerSize',5) ;

fprintf('\n Characterizing temperature effects...\n') ;
fprintf(' Select points in the lower figure by enclosing in rectangles using the left mouse button\n') ;
fprintf(' Press any key to end\n')

while ~done,
   if(~waitforbuttonpress),
      pt1 = get(gca,'CurrentPoint') ;        % button down detected
      finalRect = rbbox ;                    % return figure units
      pt2 = get(gca,'CurrentPoint') ;        % button up detected
      q = sort([pt1(1,1:2);pt2(1,1:2)]) ;    % extract x and y
      kk = union(kk,find(tt>q(1,1) & tt<q(2,1) & pp>q(1,2) & pp<q(2,2))) ;
      set(h,'XData',tt(kk),'YData',pp(kk)) ;
      subplot(211)
      set(hg,'XData',k(kk)/1000,'YData',pp(kk)) ;
      subplot(212)
   else
      done = 1 ;
   end
end

if length(kk)<=2,
   return
end

[ptc,S] = polyfit(tt(kk)-TREF,pp(kk),2) ;
fprintf(' PTC 2nd order fit coefficients are %1.3f %1.3f\n', -ptc(1:2)) ;
fprintf(' PTC 2nd order fitting error %1.3f m RMS\n', S.normr/sqrt(length(kk))) ;

T = linspace(min(tt),max(tt),100) ;
plot(T,polyval(ptc,T-TREF),'r') ;
p = p - polyval(ptc,t-TREF) ;
return
