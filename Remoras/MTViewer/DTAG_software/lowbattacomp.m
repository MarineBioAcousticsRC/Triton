function    [s,klimit] = lowbattacomp(s,p,CAL)
%
%     [s,klimit] = lowbattacomp(s,p,CAL)
%     Correct accelerometer readings for battery droop.
%     s is a tag sensor data record from swvread
%     p is the calibrated pressure signal
%     CAL is the calibration structure for the tag
%     Returns corrected s and the first sample at which
%     low battery correction was required (klimit).
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     last modified: 22 May 2006

if nargin<2,
   help lowbattacomp
   return
end

if isempty(CAL.VB),
   klimit = size(s,1) ;
   return
end

% compensate battery droop in A
bb = [0.266 -14e-6 0.125]' ;     % for tag 210 and 212
vb = polyval(CAL.VB,s(:,10)) ;
Vr = min([ones(length(s),1) [vb p ones(length(s),1)]*bb]')' ;
s(:,1:3) = (s(:,1:3)+1)./(Vr*ones(1,3))-1 ;

if nargout==2,
   klimit = min(find(Vr<1)) ;
   if isempty(klimit),
      klimit = size(s,1) ;
      return
   end
end
