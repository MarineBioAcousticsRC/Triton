function    [fn,did,recn,recdir] = getrecfnames(recdir,prefix,silent)
%    [fn,devid,recn,recdir] = getrecfnames(recdir,prefix,silent)
%     Get the file names, D3 id numbers and recording numbers
%     of a set of recordings in a directory with path recdir
%
%     mark johnson
%     31 Oct. 2009
%     bug fix: FHJ 8 april 2014

fn = {} ; did = [] ; recn = [] ;

if nargin<1,
   help getrecfnames
   recdir = [] ;
   return
end

if nargin<3,
   silent = 0 ;
end

if ~exist(recdir,'dir'),
   if ~silent,
      fprintf(' No directory %s\n', recdir) ;
   end
   return
end

if length(recdir)>1 & ismember(recdir(end),['/','\']),
   recdir = recdir(1:end-1) ;
end

% recdir = [recdir,'/'] ;       % use / for MAC compatibility
% recdir(recdir=='\') = '/' ;
recdir = [recdir,'\'] ;
ff = dir([recdir,prefix,'*.xml']) ;

for k=1:length(ff),
   nm = ff(k).name ;
   fn{end+1} = strtok(nm,'.') ;
end

if isempty(fn),
   if ~silent,
      fprintf(' No recordings found in directory %s\n', recdir) ;
   end
   return
end

did = zeros(length(fn),1) ;
recn = did ;
for k=1:length(fn),
   fnm = [recdir fn{k}] ;
   id = getxmldevid(fnm) ;
   if ~isempty(id),
      did(k) = id ;
   end
   recn(k) = str2double(fn{k}(end+(-2:0))) ;
end

kk = find(did~=0) ;
recn = recn(kk) ;
fn = {fn{kk}} ;
did = did(kk) ;
