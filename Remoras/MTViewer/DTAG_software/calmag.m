function    [M,CAL,mb] = calmag(s,CAL,test)

%    [M,CAL,mb] = calmag(s,CAL,[test])
%    Apply calibration constants to the raw magnetometer signal in
%    sensor matrix s. CAL is a structure of calibration constants
%    from a cal file (e.g., tag210.m or sw05_199a.m).
%    Optional argument test selects the type of alignnment that
%    is performed. Options are:
%     'none'   no tests
%     'hard'   remove hard iron offsets
%     'mb'     compensate for temperature effects
%     'p'      compensate for pressure (or more likely, fast
%              temperature effects)
%     'sens'   adjust sensitivity of each axis
%     'soft'   compensate for soft iron offsets
%    The default is none.
%    Returns:
%    Magnetometer result M is in micro Teslas. mb is in volts
%    relative to its value at 20 degrees Celcius.
%    CAL returns the revised calibrations.
%
%    Constants fields used are CAL.MCAL, CAL.MXCAL, CAL.MMBC, and CAL.MPC.
%
%    mark johnson
%    majohnson@whoi.edu
%    last modified: 2 July 2009
%     added blanking of measurements during variable accelerations

M = [] ; mb = [] ;

if nargin<2,
   help calmag
   return
end

if ~isstruct(CAL),
   fprintf(' Second argument must be a calibration structure\n') ;
end

OLDCAL = CAL ;                      % save old cal in case we need to back up
if ~isempty(CAL.MB),
   mb = polyval(CAL.MB,s(:,11))-CAL.MBTREF ;      % extract bridge voltage
else
   mb = [] ;
end

if ~isempty(CAL.PCAL),
   p = calpressure(s,CAL) ;
else
   p = [] ;
end

if ~isfield(CAL,'MK'),
   kk = 1:size(s,1) ;
else
   kk = 1:min(size(s,1),CAL.MK) ;
end

% find relatively stable acceleration measurements 
ds = norm2(diff(s(kk,1:3)));
pp=1/4;
ds=filtfilt([pp 0],[1 -(1-pp)],ds);
thr = prctile(ds,75) ;
kk = find(ds<thr) ;

s = s(:,4:6) ;

if nargin<3,
   test = 'none' ;
end

M = docalmag(s,mb,p,CAL) ;               % implement initial calibration
vmold = sqrt(M(kk,:).^2*[1;1;1]) ;     % initial standard deviation
test = lower(test) ;

if strcmp(test,'none'),
   fprintf(' Magnetic field strength: %4.2f uT (%3.3f RMS)\n',mean(vmold),std(vmold)) ;
   return
end

r = randn(length(kk),1) ;              % random vector in case it is needed

for k=1:2,
   % choose auxiliary variable
   switch test
      case 'hard'
         aux = [] ;
      case 'mb'
         if isempty(mb),
            aux = [] ;
         else
            aux = mb(kk) ;
         end
      case 'p'
         if isempty(p),
            aux = [] ;
         else
            aux = p(kk)/1000 ;
         end
      case 'soft'
         aux = M(kk,[3 1 2]) ;

      case 'sens'
         aux = [M(kk,1:2) r] ;
      otherwise
         fprintf(' Unknown test option %s\n', test) ;
   end

   v = minvar(M(kk,:),aux,'q') ;      % run least-squares fit

   % update the calibration
   CAL.MCAL(:,2) = CAL.MCAL(:,2) + v(1:3) ;

   switch test
      case 'mb'
         if ~isempty(mb),
            CAL.MMBC = CAL.MMBC + v(4:6)' ;
         end
      case 'p'
         if ~isempty(p),
            CAL.MPC = CAL.MPC + v(4:6)'/1000 ;
         end
      case 'sens'
         CAL.MCAL(1,1) = CAL.MCAL(1,1)*(1+v(4)) ;
         CAL.MCAL(2,1) = CAL.MCAL(2,1)*(1+v(5)) ;
      case 'soft'
         CAL.MXC(1,3) = CAL.MXC(1,3)+v(4)/2 ;
         CAL.MXC(1,2) = CAL.MXC(2,1)+v(5)/2 ;
         CAL.MXC(2,3) = CAL.MXC(2,3)+v(6)/2 ;
         CAL.MXC = CAL.MXC.*[1 1 1;0 1 1;0 0 1]+CAL.MXC'.*[0 0 0;1 0 0;1 1 0] ;
      otherwise
   end

   M = docalmag(s,mb,p,CAL) ;      % implement improved calibration
end

vm = sqrt(M(kk,:).^2*[1;1;1]) ;
fprintf('  Mean Magnetic Field Intensity after calibration: %4.2f uT\n',mean(vm)) ;
fprintf('  Standard deviation was: %4.3f uT, improved to %4.3f\n',...
   std(vmold), std(vm)) ;
ss = input('  Accept new calibration y/n? ','s') ;
if lower(ss(1))~='y'
   fprintf('  Rejecting new calibration\n') ;
   CAL = OLDCAL ;
   M = docalmag(s,mb,p,CAL) ;      % implement improved calibration
else
   CAL.LASTCAL = clock ;
end

mb = mb+CAL.MBTREF ;
return


% apply calibration
function    M = docalmag(ms,mb,p,CAL)
%
for k=1:3,
   M(:,k) = polyval(CAL.MCAL(k,:),ms(:,k)) ;
end

if isempty(mb),
   M = M*CAL.MXC' ;
else
   M = M*CAL.MXC' + mb*CAL.MMBC(:)' + p*CAL.MPC(:)' ;
end
return
