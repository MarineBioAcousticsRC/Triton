function    [A,CAL,fs] = d3calacc(X,CAL,test,mindepth,ch)

%    [A,CAL,fs] = d3calacc(X,CAL,test,mindepth,ch)
%    Automatically performs a calibration sequence on the
%    accelerometer data in raw sensor structure X. If no test
%    is specified, a calibration using the current settings is made.
%    If test = 'full', all of the following tests are performed in
%    sequence. Otherwise, specify one of the following in test:
%     'bias'   remove bias
%     'p'      compensate for pressure effects
%     't'      compensate for temperature effects
%     'sens'   adjust sensitivity of each axis
%     'cross'  compensate for cross-axis coupling
%    Optional argument mindepth is used to exclude data at depths<mindepth
%     from automatic calibration. The output vector will still include this
%     data but the calibration will be performed only on the deeper data.
%    Optional argument ch is used to identify the calibration
%     field of the correct accelerometer if there are multiple triaxial
%     accelerometers in the sensor set. For example, to calibrate
%     the gyro accelerometers, put ch='GACC'.
%
%    mark johnson
%    markjohnson@st-andrews.ac.uk
%    last modified: July 2012

if nargin<2,
   help d3calacc
   return
end

FS = 5 ;             % target sampling rate for calibration

if nargin<5 | isempty(ch),
   ch = 'ACC' ;
end

if nargin<3,
   test = [] ;
end

if ~isstruct(CAL),
   fprintf(' Second argument must be a calibration structure\n') ;
end

[ch_names,descr,ch_nums,cal] = d3channames(X.cn) ;
ka = find(strcmp(cal,lower(ch))) ;     % find the accelerometer channels in X
kt = find(strcmp(cal,'tempr')) ;       % find the temperature channel in X

if length(ka)>3,
   fprintf(' Multiple accelerometers available. Calibrating %s...\n',ch_names{ka(1)}) ;
   ka = ka(1:3) ;
end

TEST = {'bias','p','t','sens','cross','norm'} ;
TXT = {'Bias','Pressure','Temperature','Gain','Cross-axis','Scaling'} ;

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
C = getfield(CAL,upper(ch)) ;
if isempty(test),
   [A,fs] = full_rate_cal(X,CAL,C,ka,kt) ;
   return
end

% decimate data to FS for calibration
s = [X.x{ka}] ;
fsin = X.fs(ka(1)) ;
df = round(fsin/FS) ;
fs = fsin/df ;

if df>1,
   fprintf('Decimating data for calibration\n') ;
   s = decdc(s,df) ;
end

t = apply_cal(X.x{kt},CAL.TEMPR) ;
if df>1, t = decdc(t,df) ; end
if X.fs(kt)/df<fs,
   t = interp2length(t,X.fs(kt)/df,fs,size(s,1)) ;
end

[p,CAL,fsp] = d3calpressure(X,CAL,'none') ; 
if df>1, p = decdc(p,df) ; end
if fsp/df<fs,
   p = interp2length(p,fsp/df,fs,size(s,1)) ;
end

% do initial cal at FS
A = apply_cal(s,C,p,t) ;

if nargin<4 | isempty(mindepth),
   mindepth = min(p) ;
end

C = time_select(p,fs,C) ;
klims = round(fs*C.CALTIMESPAN) ;
ks = klims(1)+1:klims(2) ;
A = A(ks,:) ;

% exclude acceleration measurements with high jerk
jj = norm2(diff(A)) ;
thr = prctile(jj,50) ;
kg = find(jj<thr) ;
kk = ks(kg) ;
A = A(kg,:) ;

% now perform test sequence
for k=1:length(TEST),
   if ~isempty(TXT{k}),
      fprintf(' %s calibration...\n',TXT{k}) ;
   end
   % check balance and calculate weights
   R = outerprod(A) ;
   [V,D]=eig(R) ;
   W = (abs(A*V)*(min(diag(D))./diag(D))).^2 ;
   [A,C]=acc_cal(s(kk,:),C,p(kk),t(kk),TEST{k},W);
end

fprintf('Axial balance of cal data: %1.3f\n',1/cond(R)) ;
CAL = setfield(CAL,upper(ch),C) ;

% implement cal at full rate
[A,fs] = full_rate_cal(X,CAL,C,ka,kt) ;
return


function    [A,fs] = full_rate_cal(X,CAL,C,ka,kt)
%
%  Extract pressure and temperature from X and perform an accelerometer cal
%

s = [X.x{ka}] ;
fs = X.fs(ka(1)) ;
t = apply_cal(X.x{kt},CAL.TEMPR) ;
if X.fs(kt)<fs,
   t = interp2length(t,X.fs(kt),fs,size(s,1)) ;
end

[p,CAL,fsp] = d3calpressure(X,CAL,'none') ; 
if fsp<fs,
   p = interp2length(p,fsp,fs,size(s,1)) ;
end

A = apply_cal(s,C,p,t) ;
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


function    [A,CAL] = acc_cal(s,CAL,p,t,test,W)

OLDCAL = CAL ;
A = apply_cal(s,CAL,p,t) ;       % implement initial calibration
v = norm2(A) ;               % initial standard deviation
mv = mean(v) ;
vmold = std(v) ;
test = lower(test) ;

if strcmp(test,'none'),
   return
elseif strcmp(test,'norm'),
   sc = 1/mv ;
   CAL.POLY = sc*CAL.POLY ;
   CAL.PC.POLY = sc*CAL.PC.POLY ;
   CAL.TC.POLY = sc*CAL.TC.POLY ;
   fprintf(' Adjusted field strength from %1.3f to 1.000\n',mv) ;
   return
end

CAL.MAP = eye(3) ;         % cancel out the map while working with the physical axes

for k=1:2,
   % choose auxiliary variable
   switch test
      case 'bias'
         aux = [] ;
      case 'p'
         aux = p/1000 ;
      case 't'
         aux = t-CAL.TREF ;
      case 'cross'
         aux = A(:,[3 1 2]) ;
      case 'sens'
         aux = [A(:,1:2) randn(size(A,1),1)] ;
      otherwise
         fprintf(' Unknown test option %s\n', test) ;
   end

   v = minvar(A,aux,'q') ;     % run least-squares fit
   if isempty(v), continue, end

   % update the calibration
   CAL.POLY(:,2) = CAL.POLY(:,2) + v(1:3) ;

   switch test
      case 'p'
         CAL.PC.POLY(:,1) = CAL.PC.POLY(:,1) + v(4:6)/1000 ;
         CAL.PC.POLY(:,2) = 0 ;
      case 't'
         CAL.TC.POLY(:,1) = CAL.TC.POLY(:,1) + v(4:6) ;
         CAL.TC.POLY(:,2) = 0 ;
      case 'sens'
         CAL.POLY(1:2,1) = CAL.POLY(1:2,1).*(1+v(4:5)) ;
      case 'cross'
         CAL.XC(1,3) = CAL.XC(1,3)+v(4)/2 ;
         CAL.XC(2,1) = CAL.XC(2,1)+v(5)/2 ;
         CAL.XC(2,3) = CAL.XC(2,3)+v(6)/2 ;
         CAL.XC = triu(CAL.XC,0)+tril(CAL.XC',-1) ;
   end

   A = apply_cal(s,CAL,p,t) ;      % implement improved calibration
end

vm = std(norm2(A)) ;
if vm>=vmold,
   fprintf('  No improvement, std %2.3f g\n', vmold) ;
   CAL = OLDCAL ;
else
   fprintf('  Standard deviation was: %2.3f g, improved to %2.3f g\n',...
      vmold,vm) ;

   CAL.MAP = OLDCAL.MAP ;        % restore map
   CAL.LASTCAL = clock ;
   CAL.METHOD = 'data' ;
end

A = apply_cal(s,CAL,p,t) ;      % implement final calibration
return
