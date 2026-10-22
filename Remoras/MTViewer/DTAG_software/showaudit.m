function    showaudit(R)
%
%    showaudit(R)
%     show an audit structure in a readable format
%     See help for loadaudit for details
%
%     mark johnson, WHOI
%     majohnson@whoi.edu
%     last modified: March 2005

if nargin<1,
   help showaudit
   return
end

for k=1:size(R.cue,1),
   fprintf(' %5.1f\t%4.1f\t%s\n',R.cue(k,:),R.stype{k})
end
