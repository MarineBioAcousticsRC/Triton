function    S = readnmefiles(recdir,prefix,suffix)
%
%    S = readnmefiles(recdir,prefix,suffix)
%

if nargin<3 | isempty(suffix),
   suffix = 'nme' ;
end

[fn,dmon,recn,recdir] = getrecfnames(recdir,prefix) ;
S = {} ;
for k=1:length(fn),
   fname = [recdir,fn{k},'.',suffix] ;
   if ~exist(fname,'file'), continue, end
   s = csvproc(fname) ;
   [S{end+(1:size(s,1)),1:size(s,2)}] = deal(s{:}) ;
end
