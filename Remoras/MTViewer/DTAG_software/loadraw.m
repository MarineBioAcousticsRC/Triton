function    [s,fs] = loadraw(tag)
%
%    [s,fs] = loadraw(tag)
%    Load the raw sensor data file associated with a tag deployment.
%
%    mark johnson
%    majohnson@whoi.edu
%    last modified: 24 June 2006

s = [] ; fs = [] ;

if nargin<1,
   help loadraw
   return
end

fname = makefname(tag,'RAW') ;
if isempty(fname),
   return
end

% check if the file exists
if ~exist(fname,'file'),
   fprintf(' Unable to find raw file %s - check directory and settagpath\n',fname) ;
   return
end

% load the variables from the file
load(fname,'s','fs') ;
