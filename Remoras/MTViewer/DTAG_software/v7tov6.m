function       v7tov6(dirname)
%
%     v7tov6(dirname)
%     or
%     v7tov6
%

if nargin==1,
   dd = pwd ;
   cd(dirname) ;
end

if str2double(version('-release'))<14,
   fprintf('Need to use Matlab release 14 or greater to read V7 files\n') ;
   return
end

if ~exist('v6','dir'),
   mkdir('v6') ;
end

fnames = dir('*.mat') ;
fn = {fnames.name} ;
for k=1:length(fn),
   S = load(fn{k}) ;
   save(['v6\' fn{k}],'-V6','-STRUCT','S') ;
end

if nargin==1,
   cd(dd) ;
end
