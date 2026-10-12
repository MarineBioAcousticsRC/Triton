function    saveraw(tag,s,fs)
%
%    saveraw(tag,s,fs)
%    Saves the raw sensor data to a correctly-named file in the
%     raw directory on the tag path.
%
%    mark johnson
%    majohnson@whoi.edu
%    last modified: 24 June 2006

if nargin<1,
   help saveraw
   return
end

% try to make filename
fname = makefname(tag,'RAW') ;
if isempty(fname),
   return
end

% save the variables to the file
save(fname,'s','fs') ;
