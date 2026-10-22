function    [ltime,dv] = d3wavcues(cues,prefix,recdir,dirn)
%
%     [ltime,dv] = d3wavcues(cues,prefix,recdir,dirn)
%     Report the local time corresponding to consecutive wav cues
%     (i.e., second since start of recording). ltime is in second
%     of day. dv is the date vector of the start of the recording.
%     Usage:
%     ltime = d3wavcues(cues,prefix,recdir)
%     cues = d3wavcues(ltime,prefix,recdir,1)

ltime = [] ; dv = [] ;
if nargin<3,
   help d3wavcues
   return
end

c = recdir(end) ;
if ~ismember(recdir(end),'/\'),
   recdir(end+1) = '/' ;
end

cuefname = [recdir prefix '.mat'] ;
if isempty(cues) | ~exist(cuefname,'file')
   cuefname = makecuefile(recdir,prefix) ;
   if isempty(cues),
      return
   end
end

if isempty(cuefname),
   fprintf(' Unable to make cue file\n') ;
   return
end

C = load(cuefname) ;

if nargin==4 & ~isempty(dirn),
   ltime = cues-C.stime ;        % convert local times to cues
else
   ltime = C.stime+cues ;        % convert cues to local times
end
dv = C.dv ;
return
