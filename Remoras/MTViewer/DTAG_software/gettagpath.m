function    datapath = gettagpath(datatype)
%
%    datapath = gettagpath(datatype)
%    Prints the paths selected for tag data using settagpath.m
%
%    mark johnson
%    majohnson@whoi.edu
%    last modified: July 2012

global TAG_PATHS

if isempty(TAG_PATHS),
   fprintf(' No tag data paths currently selected\n') ;
end

fnames = fieldnames(TAG_PATHS) ;
if nargin>0 & isfield(TAG_PATHS,datatype),
   datapath = getfield(TAG_PATHS,datatype) ;
   return
end

for k=1:length(fnames),
   fprintf(' %s path set to %s\n', fnames{k},getfield(TAG_PATHS,fnames{k}))
end
