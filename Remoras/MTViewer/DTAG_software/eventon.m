function    [k,notk] = eventon(cue,t)
%
%   [k,notk] = eventon(cue,t)
%   k = 1 for points in t (time vector) when cue is on, 0 elsewhere.
%   cue is a list of events in the format: cue = [start_time,duration]
%   notk is the complement of k.

if nargin~=2,
   help eventon
   return
end

k = 0*t ;
cst = cue(:,1) ;
ce = cue(:,1)+cue(:,2) ;

for kk=1:size(cue,1),
   k = k | (t>=cst(kk) & t<ce(kk)) ;
end

notk = k==0 ;
