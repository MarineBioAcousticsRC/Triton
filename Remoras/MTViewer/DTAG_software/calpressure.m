function    [p,t,CAL] = calpressure(s,CAL,test)

%    [p,tempr,CAL] = calpressure(s,CAL,[test])
%    Apply calibration constants to the raw pressure signal in
%    sensor matrix s. CAL is a structure of calibration constants
%    from a cal file (e.g., tag210.m or sw05_199a.m).
%    test can be 'full', 'lowbat', 'tempr' or 'none' (the default is none).
%    A full test performs low battery compensation and characterizes
%    the temperature effect and the 0-pressure offset.
%    If a 'full extended' test is requested, a wider range of pressures
%    are analyzed for temperature effects. This is useful for data sets
%    with a wide range of temperature values.
%    If a 'full notemp' test is requested, no change is made to the current
%    temperature coefficient.
%
%    Pressure result p is in m H20 (salt) per degree Celsius. Temperature
%    result tempr is in degrees Celsius.
%
%    Constants fields used are CAL.TCAL, CAL.PCAL, and CAL.PTC.
%    If r is the raw pressure reading and t is the temperature, 
%    p = a*r^2 + b*r + c + tc*t for a 2nd order calibration.
%
%    mark johnson
%    majohnson@whoi.edu
%    last modified: 29 August 2008

p = [] ; t = [] ;
PRESSRANGE = 20 ;
NOTEMP = 0 ;

if nargin<2,
   help calpressure
   return
end

if ~isstruct(CAL),
   fprintf(' Second argument must be a calibration structure\n') ;
end

if nargin<3
   test = '' ;
end

[test,extnd] = strtok(lower(test)) ;
if strcmp(test,'full') | strcmp(test,'lowbat'),
   s = lowbattpcomp(s,CAL) ;        % repair any low battery effect
end

t = polyval(CAL.TCAL,s(:,8)) ;      % temperature calibration

if strcmp(test,'full') | strcmp(test,'tempr'),
   p = polyval(CAL.PCAL,s(:,7)) ;   % nominal pressure scaling
   ss = strtok(lower(extnd)) ;
   if strcmp(ss,'extended'),
      PRESSRANGE = PRESSRANGE * 2 ;
   elseif strcmp(ss,'notemp'),
      NOTEMP = 1 ;
   end
   CAL = calptc(p,t,CAL,PRESSRANGE,NOTEMP) ; % gui for temperature compensation
end

ptc = [CAL.PTC(:)' 0] ;
p = polyval(CAL.PCAL,s(:,7)) + polyval(ptc,t-CAL.TREF) ;
return


function    CAL = calptc(p,t,CAL,PRESSRANGE,NOTEMP)
%
%
PRESSDIFF = PRESSRANGE/1000 ;

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
fprintf(' Select points by enclosing in rectangles using the left mouse button\n') ;
fprintf(' Press any key to end\n')
zoom off

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

if NOTEMP==0,
   [ptc,S] = polyfit(tt(kk)-CAL.TREF,pp(kk),2) ;
   fprintf(' PTC 2nd order fit coefficients are %1.3f %1.3f\n', -ptc(1:2)) ;
   fprintf(' PTC 2nd order fitting error %1.3f m RMS\n', S.normr/sqrt(length(kk))) ;
else
   ptc = [0 mean(pp(kk))] ;
   fprintf(' PTC offset is %1.3f\n', -ptc(2)) ;
end

T = linspace(min(tt),max(tt),100) ;
plot(T,polyval(ptc,T-CAL.TREF),'r') ;

s = input('  Accept new calibration y/n? ','s') ;

if isempty(s) | lower(s(1))~='y'
   fprintf('  Rejecting new PTC calibration - using old values\n') ;
else
   ptc = [ptc(1:2) 0] ;
   CAL.PTC = -ptc(1:2) ;
   CAL.PCAL(end) = CAL.PCAL(end)-mean(pp(kk)-polyval(ptc,tt(kk)-CAL.TREF)) ;
   CAL.LASTCAL = clock ;
end

subplot(211),hold off
subplot(212),hold off
return
