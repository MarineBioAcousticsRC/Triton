function    [p,CAL,fs] = d3calpressure(X,CAL,test)

%    [p,CAL,fs] = d3calpressure(X,CAL,[test])
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
FS = 5 ;             % target sampling rate for calibration

if nargin<2,
   help d3calpressure
   return
end

if ~isstruct(CAL),
   fprintf(' Second argument must be a calibration structure\n') ;
end

if nargin<3
   test = '' ;
end

[test,extnd] = strtok(lower(test)) ;

% find the pressure and pressure bridge channels
[ch_names,descr,ch_nums,cal] = d3channames(X.cn) ;
kp = find(strcmp(cal,'press')) ;
kb = find(strcmp(cal,'press.bridge')) ;

% check the sampling rate
fsin = X.fs(kp) ;
df = 1 ;
if fsin>FS, df = round(fsin/FS) ; end
fs = fsin/df ;
p = X.x{kp} ;
if df>1, p = decdc(p,df) ; end

% convert the bridge voltage to temperature
pbv = apply_cal([X.x{kb}],CAL.PRESS.BRIDGE) ;
if df>1, pbv = decdc(pbv,df) ; end
if X.fs(kb(1))/df<fs,
   t = interp2length(pbv(:,2),X.fs(kb(1))/df,fs,length(p)) ;
else
   t = pbv(:,2) ;
end

done = 0 ;
if strcmp(test,'full') || strcmp(test,'tempr'),
   p = apply_cal(p,CAL.PRESS,[],t) ;
   while ~done,
      CAL = time_select(p,fs,CAL) ;
      klims = round(fs*CAL.PRESS.CALTIMESPAN) ;
      k = klims(1)+1:klims(2) ;

      ss = strtok(lower(extnd)) ;
      if strcmp(ss,'extended'),
         PRESSRANGE = PRESSRANGE * 2 ;
      elseif strcmp(ss,'notemp'),
         NOTEMP = 1 ;
      end
      [CAL.PRESS,s] = calptc(p(k),t(k),CAL.PRESS,PRESSRANGE,NOTEMP) ; % gui for temperature compensation
      done = s~='r' ;
   end
end

pbv = apply_cal([X.x{kb}],CAL.PRESS.BRIDGE) ;
t = interp2length(pbv(:,2),X.fs(kb(1)),fsin,length(X.x{kp})) ;
p = apply_cal(X.x{kp},CAL.PRESS,[],t) ;
fs = fsin ;
return


function    CAL = time_select(p,fs,CAL)
%
%
figure(1),clf
plott(p,fs*3600)
xlabel('Time, hours')
zoom off
fprintf(' Select left and right limits in Fig 1 by positioning cursor and typing l or r\n') ;
fprintf(' Press any other key to end\n')

Tl = 0 ;
Tr = length(p)/fs ;
if isfield(CAL.PRESS,'CALTIMESPAN'),
   Tl = min(Tr,max(Tl,CAL.PRESS.CALTIMESPAN(1))) ;
   Tr = min(Tr,max(Tl,CAL.PRESS.CALTIMESPAN(2))) ;
end
hold on
hl = plot([1;1]*Tl/3600,get(gca,'YLim'),'g') ;
set(hl,'LineWidth',1.5) ;
hlm = plot(Tl/3600,mean(get(gca,'YLim')),'g>') ;
set(hlm,'MarkerSize',12,'MarkerFaceColor','g') ;

hr = plot([1;1]*Tr/3600,get(gca,'YLim'),'r') ;
set(hr,'LineWidth',1.5) ;
hrm = plot(Tr/3600,mean(get(gca,'YLim')),'r<') ;
set(hrm,'MarkerSize',12,'MarkerFaceColor','r') ;

done = 0 ;
while ~done,
   [x,y,s] = ginput(1) ;
   s = char(s) ;
   switch char(s),
      case 'l'
         Tl = min(Tr,max(0,x*3600)) ;
         set(hl,'XData',Tl/3600*[1 1]) ;
         set(hlm,'XData',Tl/3600) ;
      case 'r'
         Tr = min(length(p)/fs,max(Tl,x*3600)) ;
         set(hr,'XData',Tr/3600*[1 1]) ;
         set(hrm,'XData',Tr/3600) ;
      otherwise done = 1 ;
   end
end

CAL.PRESS.CALTIMESPAN = [Tl,Tr] ;
CAL.PRESS.CALTIMESPANUNIT = 'seconds' ;
return


function    [CAL,s] = calptc(p,t,CAL,PRESSRANGE,NOTEMP)
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
figure(2),clf
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

fprintf(' Select points in Fig 2 by enclosing in rectangles using the left mouse button\n') ;
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
   s = 'q' ;
   return
end

if NOTEMP==0,
   [ptc,S] = polyfit(tt(kk)-CAL.TREF,pp(kk),2) ;
   n = length(ptc)-length(CAL.TC.POLY) ;
   if n>0,
      CAL.TC.POLY = [zeros(1,n) CAL.TC.POLY] ;
   end
   ptc = ptc-CAL.TC.POLY ;
   fprintf(' PTC 2nd order fit coefficients are %1.3f %1.3f\n', -ptc(1:2)) ;
   fprintf(' PTC 2nd order fitting error %1.3f m RMS\n', S.normr/sqrt(length(kk))) ;
else
   ptc = [0 mean(pp(kk))] ;
   fprintf(' pressure offset is %1.3f\n', -ptc(2)) ;
end

T = linspace(min(tt),max(tt),100) ;
plot(T,polyval(ptc+CAL.TC.POLY,T-CAL.TREF),'r') ;

fprintf('  Accept new calibration, redo or quit? Type y, r, or q... ') ;
[x,y,s] = ginput(1) ;
s = char(s) ;
fprintf('\n') ;
if isempty(s) || ~ischar(s), s = 'q' ; end

if lower(s(1))~='y'
   fprintf('  Rejecting calibration\n') ;
else
   CAL.TC.POLY = [-ptc(1:2) 0] ;
   CAL.TC.SRC = 'bridge' ;
   CAL.POLY(end) = CAL.POLY(end)-ptc(3) ;
   CAL.LASTCAL = clock ;
   CAL.METHOD = 'surfacing' ;
end

subplot(211),hold off
subplot(212),hold off
return
