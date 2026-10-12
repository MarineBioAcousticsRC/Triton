function    [K,J]=lowjerkfinder(s,fs,CAL,maxjerk,mintime)
%
%    [K,J] = lowjerkfinder(s,fs,CAL,maxjerk,mintime)
%    Find sample numbers for which the jerk is less than maxjerk and which are
%    at least mintime seconds from the nearest sample with jerk greater than maxjerk
%
%    mark johnson, majohnson@whoi.edu
%    WHOI, 1 Feb. 2008
%

if nargin<5,
   help lowjerkfinder
   return
end

[b,a] = butter(4,2/(fs/2)) ;           % low-pass filter at 2 Hz
mink = max(round(fs*mintime),1) ;
A = s(:,1:3).*(ones(size(s,1),1)*CAL.ACAL(:,1)') ;
J = norm2(filter(b,a,diff(A))*fs) ;    % compute norm of smoothed jerk
Jmax = max(buffer(J,mink*4,mink*2,'nodelay'))' ;
kk = find(Jmax<maxjerk) ;
K = 2*mink*(kk-1)*ones(1,2*mink)+ones(length(kk),1)*(mink:3*mink-1) ;
K = K(:) ;
