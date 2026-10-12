function    [t,fs] = d3reclength(recdir,prefix)
%
%     [t,fs] = d3reclength(recdir,prefix)
%

t = [] ; fs = [] ;

if nargin<2,
   help d3reclength
   return
end

[ct,ref_time,fs] = d3getcues(recdir,prefix) ;
if ~isempty(ct),
   t = sum(ct(:,end))/fs ;
end
return
