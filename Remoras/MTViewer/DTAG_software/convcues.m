function       C = convcues(tag,cue)
%
%   C = convcues(tag,cue)
%

C = [] ;
if nargin<2,
   help convcues
   return
end

gpsdir = '/tag/tag2/metadata/gps' ;

% load cue-utc lookup tables
fbase = [gpsdir '/' tag(1:end-1) '*gtx.mat'] ;     % replace letter designator with wild
fdir = dir(fbase) ;
T = cell(length(fdir),1) ;
for k=1:length(T),
   z = load([gpsdir '/' fdir(k).name]) ;
   fldnames = fieldnames(z) ;
   T{k} = z.(fldnames{1}) ;
end

if isempty(T),
   return
end

% extract tag names from filenames

tags = strvcat({fdir.name}) ;
C.tags = tags(:,1:length(tag)) ;
K = find(strcmp({tag},C.tags)) ;
if isempty(K),
   fprintf('cannot find gtx file for tag %s\n',tag) ;
   return
end

tk = nearest(T{K}.cuetime,cue) ;
% estimate local clock drift over the prior and following minute
k = tk+(-6:6) ;
k = k(k>0 & k<=length(T{K}.gpstime)) ;
if length(k)<2,
   fprintf('unable to measure clock drift for this cue\n') ;
   return
end
k = k([1 end]) ;
gpst = T{K}.gpstime(k) ;           % find corresponding GPS measurements
cuet = T{K}.cuetime(k) ;           % find corresponding cue measurements
drift = diff(gpst)/diff(cuet) ;
C.gpstime = T{K}.gpstime(tk)+(cue-T{K}.cuetime(tk))*drift ;           % find corresponding GPS measurements

% now find the corresponding cues in the other tags
C.cue = NaN*ones(length(cue),size(tags,1)) ;
C.cue(:,K) = cue ;
ko = setxor(1:size(tags,1),K) ;
for k=ko,
   tk = nearest(T{k}.gpstime,C.gpstime) ;
   % estimate local clock drift over the prior and following minute
   kk = tk+(-6:6) ;
   kk = kk(kk>0 & kk<=length(T{K}.gpstime)) ;
   kk = kk([1 end]) ;
   gpst = T{k}.gpstime(kk) ;           % find corresponding GPS measurements
   cuet = T{k}.cuetime(kk) ;           % find corresponding cue measurements
   drift = diff(cuet)/diff(gpst) ;
   C.cue(:,k) = T{k}.cuetime(tk)+(C.gpstime-T{k}.gpstime(tk))*drift ;           % find corresponding GPS measurements
end
return
