function   [ke,pk,dur] = findevents(x,thresh,blanking)
%
%     [ke,pk,dur] = findevents(x,thresh,blanking)
%     Returns the index of events where x>thresh and their duration.
%
%     mark johnson, WHOI
%     last modified January 2010

ke=[]; dur=[]; pk=[] ;

if nargin<3,
   help findevents ;
   return
end
    
dv = x>thresh ;
cc = [] ;
dxx = diff(dv) ;
cc = find(dxx>0) ;

if isempty(cc), return ; end

% eliminate detections which do not meet blanking criterion.
% blanking time is calculated after pulse returns below threshold

% first compute raw pulse endings
coff = find(dxx<0) ;    % find where dv returns below threshold
cend = length(dv)*ones(length(cc),1) ;
for k=1:length(cc),
   kends = find(coff>cc(k)) ;
   if ~isempty(kends),
      cend(k) = coff(min(kends)) ;
   end
end

% merge pulses that are within blanking distance
done = 0 ;
while ~done,
   kg = find(cc(2:end)-cend(1:end-1)>blanking) ;
   done = length(kg) == (length(cc)-1) ;
   cc = cc([1;kg+1]) ;
   cend = cend([kg;end]) ;
end

ke = cc ;
dur = cend-cc ;
pk = 0*cc ;

% find pk levels
for k=1:length(cc),
   pk(k) = max(x(cc(k):cend(k))) ;
end
