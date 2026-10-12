function       s = lowbattpcomp(s,CAL,klimit)
%
%     s = lowbattpcomp(s,CAL,[klimit])
%     Correct pressure reading for battery droop.
%     s is a tag sensor data record from swvread
%     CAL is the calibration structure for the tag
%     Optional third argument klimit defines the sample number
%        at the end of the constant current interval. If not
%        provided, the first sample for which vb-pb < 0.3
%        will be used.
%
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     last modified: 25 June 2008
%                    fixed error in klimit test

if nargin<2,
   help lowbattpcomp
   return
end

if isempty(CAL.PB) | isempty(CAL.VB) | isempty(CAL.Pi0) | isempty(CAL.Pr0),
   return
end

tempr = polyval(CAL.TCAL,s(:,8)) ;    % temperature sensor cal not affected by vb
pb = polyval(CAL.PB,s(:,12)) ;        % pbridge voltage cal not affected by vb

if nargin<3,
   vb = polyval(CAL.VB,s(:,10)) ;
   klimit = min(find(vb-pb<0.3)) ;
   if isempty(klimit),
      klimit = size(s,1) ;
      return
   elseif klimit<0.1*length(vb),
      fprintf(' Battery is low during more than 90%% of the recording. Cannot compensate\n') ;
      return
   end
else
   if klimit>size(s,1) ;
      klimit = size(s,1) ;
      return
   end
end

i0 = CAL.Pi0 ;                         % pressure bridge current
r0 = CAL.Pr0 ;                         % current sensing resistor
k = 1:klimit ; % select the early part of the data where the battery voltage is high

p = polyval(CAL.PCAL,s(:,7)) ;      % nominal pressure

% predict the bridge voltage in constant current mode
[bb bint rr] = regress(pb(k)/i0,[tempr(k) p(k)/1000 1+0*k']) ;
fprintf(' Pressure bridge %5.1f ohms, tempco %2.2f ohms/degree, psens %2.2f ohms/km, std %2.2f\n',...
   bb(3)-r0,bb(1),bb(2),std(rr)) ;              % check how good the fit is - ought to be about 5 or less

% now predict the bridge current outside of constant current mode
ihat = pb./(bb(3)+bb(1)*tempr+bb(2)*p/1000) ;

% and then correct the pressure
s(:,7) = (s(:,7)+1)*i0./ihat-1 ;
