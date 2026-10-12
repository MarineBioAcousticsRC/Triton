function    [M,CAL,fs,Mz] = d3calmag(X,CAL,test,mindepth)

%    [M,CAL,fsm,Mz] = d3calmag(X,CAL,test,mindepth)
%    Automatically performs a calibration sequence on the raw
%    magnetometer data in raw sensor structure X. If no test
%    is specified, a calibration using the current settings is made.
%    If test = 'full', all of the following tests are performed in
%    sequence. Otherwise, specify one of the following in test:
%     'hard'   remove bias
%     't'      compensate for temperature effects
%     'p'      compensate for pressure effects
%     'soft'  compensate for cross-axis coupling
%     'sens'   adjust sensitivity of each axis
%    Optional argument mindepth is used to exclude data at depths<mindepth
%     from automatic calibration. The output vector will still include this
%     data but the calibration will be performed only on the deeper data.

%    
%    mark johnson
%    markjohnson@st-andrews.ac.uk
%    last modified: July 2012

if nargin<2,
   help d3calmag
   return
end

if nargin<3,
   test = [] ;
end

FS = 5 ;             % target sampling rate for calibration

if ~isstruct(CAL),
   fprintf(' Second argument must be a calibration structure\n') ;
end

% find magnetometer and bridge channels in X
[ch_names,descr,ch_nums,type] = d3channames(X.cn) ;
km = find(strcmp(type,'mag')) ;
kb = find(strcmp(type,'mag.bridge')) ;

TEST = {'hard','t','sens','soft','p'} ;
TXT = {'Hard iron','Temperature','Gain','Soft iron','Pressure'} ;

if nargin>2 & ~isempty(test),
   switch test,
      case 'none'
         test = [] ;
         TEST = {} ;
      case 'full'
         % no action
      otherwise
         TEST = {test} ;
         TXT = {''} ;
   end
end

% if data-driven cal is not requested, just apply existing cal constants
% and return
if isempty(test),
   [M,fs,Mz] = full_rate_cal(X,CAL,km,kb) ;
   return
end

C = CAL.MAG ;
s = [X.x{km}] ;
fsin = X.fs(km(1)) ;
if length(km>3),
   [s,Mz,fsm] = interpmag(s,fsin) ;
   fsin = fsm(1) ;
end

% check the sampling rate
df = 1 ;
if fsin>FS, df = round(fsin/FS) ; end
fs = fsin/df ;
if df>1,
   fprintf('Decimating data for calibration\n') ;
   s = decdc(s,df) ;
end

kb = find(strcmp(type,'mag.bridge')) ;
t = apply_cal([X.x{kb}],CAL.MAG.BRIDGE) ;
t = t(:,2) ;
if df>1, t = decdc(t,df) ; end
if X.fs(kb(1))/df<fs,
   t = interp2length(t,X.fs(kb(1))/df,fs,size(s,1)) ;
end
[p,CAL,fsp] = d3calpressure(X,CAL,'none') ;
if df>1, p = decdc(p,df) ; end
if fsp/df<fs,
   p = interp2length(p,fsp/df,fs,size(s,1)) ;
end

if length(p)>size(s,1),
   p = p(1:size(s,1)) ;
elseif length(p)<size(s,1),
   p(end+(1:size(s,1)-length(p))) = p(end) ;
end

if nargin<4 | isempty(mindepth),
   mindepth = min(p) ;
end

% initial cal
M = apply_cal(s,C,p,t) ;
C = time_select(p,fs,C) ;
klims = round(fs*C.CALTIMESPAN) ;
ks = klims(1)+1:klims(2) ;
M = M(ks,:) ;

% exclude magnetometer measurements with high change rate
jj = norm2(diff(M)) ;
thr = prctile(jj,50) ;
kg = find(jj<thr) ;
kk = ks(kg) ;
M = M(kg,:) ;

% now perform test sequence
for k=1:length(TEST),
   if ~isempty(TXT{k}),
      fprintf(' %s calibration...\n',TXT{k}) ;
   end

    % hack to repair broken Cal File (JAH, ALLOYD)
   if ~isstruct(C.PC)
       C.PC = C.TC;
   end


   % check balance and calculate weights
   R = outerprod(M) ;
   [V,D]=eig(R) ;
   W = (abs(M*V)*(min(diag(D))./diag(D))).^2 ;
   [M,C]=mag_cal(s(kk,:),C,p(kk),t(kk),TEST{k},W);
end

fprintf('Axial balance of cal data: %1.3f\n',1/cond(R)) ;
vv = norm2(M) ;
mv = mean(vv) ; sv = std(vv) ;
fprintf('\n  Final Magnetic Field Intensity: %4.2f uT (%4.3f uT S.D.)\n',mv,sv) ;

% redo the cal at the original sampling rate
CAL = setfield(CAL,'MAG',C) ;
[M,fs,Mz] = full_rate_cal(X,CAL,km,kb) ;
return


function    [M,fsm,Mz] = full_rate_cal(X,CAL,km,kb)
%
%  Extract pressure and temperature from X and perform an accelerometer cal
%

s = [X.x{km}] ;
fsm = X.fs(km(1)) ;
Mz = [] ;
if length(km>3),
   [s,Mz,fsm] = interpmag(s,fsm) ;
end
fs = fsm(1) ;

t = apply_cal([X.x{kb}],CAL.MAG.BRIDGE) ;
t = t(:,2) ;
if X.fs(kb)<fs,
   t = interp2length(t,X.fs(kb(1)),fs,size(s,1)) ;
end
[p,CAL,fsp] = d3calpressure(X,CAL,'none') ; 
if fsp<fs,
   p = interp2length(p,fsp,fs,size(s,1)) ;
end

p = p(1:size(s,1)) ;    % hack in case p is bigger than s e.g., mn12_180a
M = apply_cal(s,CAL.MAG,p,t) ;
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

Tl = 5 ;             % don't cal in the first 5 seconds for magnetometer - there is a
                     % set-reset process then.
Tr = length(p)/fs ;
if isfield(CAL,'CALTIMESPAN'),
   Tl = min(Tr,max(Tl,CAL.CALTIMESPAN(1))) ;
   Tr = min(Tr,max(Tl,CAL.CALTIMESPAN(2))) ;
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

CAL.CALTIMESPAN = [Tl,Tr] ;
CAL.CALTIMESPANUNIT = 'seconds' ;
return


function    [M,CAL] = mag_cal(s,CAL,p,t,test,W)

OLDCAL = CAL ;                      % save old cal in case we need to back up
CAL.MAP = eye(3) ;         % cancel out the map while working with the physical axes
M = apply_cal(s,CAL,p,t) ;          % implement initial calibration
svold = std(norm2(M)) ;
test = lower(test) ;
for k=1:3,
   % choose auxiliary variable
   switch test
      case 'hard'
         aux = [] ;
      case 't'
         aux = t-CAL.TREF ;
      case 'p'
         aux = p/1000 ;
      case 'soft'
         aux = M(:,[3 1 2]) ;
      case 'sens'
         aux = [M(:,1:2) randn(size(M,1),1)] ;
      otherwise
         fprintf(' Unknown test option %s\n', test) ;
   end

   v = minvar(M,aux,'q') ;      % run least-squares fit
   if isempty(v), continue, end

   % update the calibration
   CAL.POLY(:,2) = CAL.POLY(:,2) + v(1:3) ;

   switch test
      case 't'
         CAL.TC.POLY(:,1) = CAL.TC.POLY(:,1) + v(4:6) ;
         CAL.TC.POLY(:,2) = 0 ;
         CAL.TC.SRC = 'bridge' ;
      case 'p'
         CAL.PC.POLY(:,1) = CAL.PC.POLY(:,1) + v(4:6)/1000 ;
         CAL.PC.POLY(:,2) = 0 ;
      case 'sens'
         CAL.POLY(1:2,1) = CAL.POLY(1:2,1).*(1+v(4:5)) ;
      case 'soft'
         CAL.XC(1,3) = CAL.XC(1,3)+v(4)/2 ;
         CAL.XC(2,1) = CAL.XC(2,1)+v(5)/2 ;
         CAL.XC(2,3) = CAL.XC(2,3)+v(6)/2 ;
         CAL.XC = triu(CAL.XC,0)+tril(CAL.XC',-1) ;
   end

   M = apply_cal(s,CAL,p,t) ;      % implement improved calibration
end

vv = norm2(M) ;
sv = std(vv) ;
mv = mean(vv) ;
if sv>=svold,
   fprintf('  No improvement\n') ;
   CAL = OLDCAL ;

else
   fprintf('  Mean Magnetic Field Intensity after calibration: %4.2f uT\n',mv) ;
   fprintf('  Standard deviation was: %4.3f uT, improved to %4.3f\n',...
   svold, sv) ;
   CAL.LASTCAL = clock ;
   CAL.METHOD = 'data' ;
   CAL.MAP = OLDCAL.MAP ;      % restore the map
end

M = apply_cal(s,CAL,p,t) ;      % implement original calibration
return
