function    [A,CAL] = calacc(s,p,t,CAL,test)

%    [A,CAL] = calacc(s,p,t,CAL,[test])
%    Apply calibration constants to the raw accelerometer signal in
%    sensor matrix s. CAL is a structure of calibration constants
%    from a cal file (e.g., tag210.m or sw05_199a.m).
%    Optional argument test selects the type of alignnment that
%    is performed. Options are:
%     'none'   no test
%     'bias'   remove bias
%     'p'      compensate for pressure effects
%     't'      compensate for temperature effects
%     'sens'   adjust sensitivity of each axis
%     'cross'  compensate for cross-axis coupling
%     'norm'   normalize to unit mean norm
%    The default is none.
%    Returns:
%    Accelerometer result A is in g. 
%    CAL returns the revised calibrations.
%
%    Constants fields used are CAL.ACAL, CAL.AXC, CAL.APC, CAL.ATC.
%
%    mark johnson
%    majohnson@whoi.edu
%    last modified: 2 July 2009
%     added blanking of measurements during variable accelerations

A = [] ;

if nargin<4,
   help calacc
   return
end

if ~isstruct(CAL),
   fprintf(' Second argument must be a calibration structure\n') ;
end

OLDCAL = CAL ;                      % save old cal in case we need to back up

if ~isfield(CAL,'AK'),
   kk = 1:size(s,1) ;
else
   kk = 1:min(size(s,1),CAL.AK) ;
end

if nargin<5,
   test = 'none' ;
end

s = s(:,1:3) ;

% find relatively stable acceleration measurements 
ds = norm2(diff(s(kk,:)));
pp=1/4;
ds=filtfilt([pp 0],[1 -(1-pp)],ds);
thr = prctile(ds,25) ;
kk = find(ds<thr) ;

A = docalacc(s,p,t,CAL) ;            % implement initial calibration
vmold = sqrt(A(kk,:).^2*[1;1;1]) ;   % initial standard deviation
test = lower(test) ;

if strcmp(test,'none'),
   fprintf(' Gravitational field strength: %2.3f g (%2.3f RMS)\n',mean(vmold),std(vmold)) ;
   return
elseif strcmp(test,'norm'),
   sc = 1/mean(vmold) ;
   CAL.ACAL = sc*CAL.ACAL ;
   CAL.APC = sc*CAL.APC ;
   CAP.ATC = sc*CAL.ATC ;
   A = docalacc(s,p,t,CAL) ;            % implement initial calibration
   return
end

r = randn(length(kk),1) ;              % random vector in case it is needed

for k=1:2,
   % choose auxiliary variable
   switch test
      case 'bias'
         aux = [] ;
      case 'p'
         aux = p(kk)/1000 ;
      case 't'
         aux = t(kk)-CAL.TREF ;
      case 'cross'
         aux = A(kk,[3 1 2]) ;
      case 'sens'
         aux = [A(kk,1:2) r] ;
      otherwise
         fprintf(' Unknown test option %s\n', test) ;
   end

   v = minvar(A(kk,:),aux,'q') ;     % run least-squares fit
   if isempty(v), v=zeros(6,1) ; end   % in case minvar returns with an empty v because of poor condition

   % update the calibration
   CAL.ACAL(:,2) = CAL.ACAL(:,2) + v(1:3) ;

   switch test
      case 'p'
         CAL.APC = CAL.APC + v(4:6)'/1000 ;
      case 't'
         CAL.ATC = CAL.ATC + v(4:6)' ;
      case 'sens'
         CAL.ACAL(1,1) = CAL.ACAL(1,1)*(1+v(4)) ;
         CAL.ACAL(2,1) = CAL.ACAL(2,1)*(1+v(5)) ;
      case 'cross'
         CAL.AXC(1,3) = CAL.AXC(1,3)+v(4)/2 ;
         CAL.AXC(2,1) = CAL.AXC(2,1)+v(5)/2 ;
         CAL.AXC(2,3) = CAL.AXC(2,3)+v(6)/2 ;
         CAL.AXC = CAL.AXC.*[1 1 1;0 1 1;0 0 1]+CAL.AXC'.*[0 0 0;1 0 0;1 1 0] ;
      otherwise
   end

   A = docalacc(s,p,t,CAL) ;      % implement improved calibration
end

vm = sqrt(A(kk,:).^2*[1;1;1]) ;
scf = 1/mean(vm) ;               % normalize for mean of 1.0 g during low accelerations
CAL.ACAL = CAL.ACAL*scf ;
vm = vm*scf ;

if std(vm)>=std(vmold),
   fprintf('  No improvement possible with this test\n') ;
   ss = 'n' ;
else
   %fprintf('  Gravitational field strength after calibration: %2.3f g\n', mean(vm)) ;
   fprintf('  Standard deviation was: %4.3f g, improved to %4.3f g\n',...
      std(vmold), std(vm)) ;
   ss = input('  Accept new calibration y/n? ','s') ;
end

if lower(ss(1))~='y'
   fprintf('  Rejecting new calibration\n') ;
   CAL = OLDCAL ;
   A = docalacc(s,p,t,CAL) ;      % implement improved calibration
else
   CAL.LASTCAL = clock ;
end

return


function    A = docalacc(s,p,t,CAL)
% apply calibration
%
for k=1:3,
   A(:,k) = polyval(CAL.ACAL(k,:),s(:,k)) ;
end

A = A*CAL.AXC' + p*CAL.APC(:)' + (t-CAL.TREF)*CAL.ATC(:)' ;
return
