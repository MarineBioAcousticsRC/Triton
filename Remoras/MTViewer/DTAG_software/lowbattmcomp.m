function    [s,klimit] = lowbattmcomp(s,CAL,klimit)
%
%     [s,klimit] = lowbattmcomp(s,CAL,[klimit])
%     Correct magnetometer readings for battery droop.
%     s is a tag sensor data record from swvread
%     Optional second argument klimit defines the sample number
%        at the end of the constant current interval. If not
%        provided, the first sample for which vb-pb < 0.5
%        will be used.
%
%     m is the corrected magnetometer records in ADC units.
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     last modified: 17 Nov. 2005

if nargin<2,
   help lowbattmcomp
   return
end

if isempty(CAL.MB) | isempty(CAL.VB),
   klimit = size(s,1) ;
   return
end

tempr = polyval(CAL.TCAL,s(:,8)) ;    % temperature sensor cal not affected by vb
mb = polyval(CAL.MB,s(:,11)) ;        % mbridge voltage cal not affected by vb

if nargin<3,
   vb = polyval(CAL.VB,s(:,10)) ;
   klimit = min(find(vb-mb<0.5)) ;
   if isempty(klimit),
      klimit = size(s,1) ;
      return
   end
else
   if klimit>size(s,1) ;
      klimit = size(s,1) ;
      return
   end
end

i0 = 7.58e-3 ;                % magnetometer bridge current
r0 = 15 ;                     % bridge current sense resistor
k = 1:klimit ;           

% predict the bridge voltage in constant current mode
[bb bint rr] = regress(mb(k)/i0,[tempr(k) 1+0*k']) ;
fprintf(' Magnetometer bridge %4.1f ohms, tempco %2.2f ohms/degree, std %3.1f\n',...
   bb(2)-r0,bb(1),std(rr)); % check how good the fit is - ought to be about 5 or less

% now predict the bridge current outside of constant current mode
ihat = mb./(bb(2)+bb(1)*tempr) ;

% correction factor
sens = i0./ihat ;

% fix magnetometer measurements
s(:,4:6) = s(:,4:6).*(sens*ones(1,3)) ;
